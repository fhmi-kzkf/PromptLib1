<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class UploadController extends ResourceController
{
    protected $format = 'json';

    /**
     * Upload an image file (jpg, png, jpeg only).
     * Returns the public URL of the uploaded file.
     */
    public function image()
    {
        $file = $this->request->getFile('image');

        if (! $file || ! $file->isValid()) {
            return $this->fail('No valid image file provided.');
        }

        // Validate file type — only jpg, png, jpeg
        $allowed = ['jpg', 'jpeg', 'png'];
        $ext = strtolower($file->getClientExtension());

        if (! in_array($ext, $allowed)) {
            return $this->fail('Invalid file type. Allowed: jpg, jpeg, png.');
        }

        // Validate MIME type for security
        $allowedMimes = ['image/jpeg', 'image/png'];
        if (! in_array($file->getMimeType(), $allowedMimes)) {
            return $this->fail('Invalid MIME type. Only image files allowed.');
        }

        // Max 5MB
        if ($file->getSizeByUnit('mb') > 5) {
            return $this->fail('File too large. Maximum 5MB.');
        }

        // Generate unique filename
        $newName = $file->getRandomName();

        // Move to public/uploads/images
        $file->move(FCPATH . 'uploads' . DIRECTORY_SEPARATOR . 'images', $newName);

        // Build the public URL path
        $imageUrl = '/uploads/images/' . $newName;

        return $this->respond([
            'status'    => 200,
            'image_url' => $imageUrl,
            'message'   => 'Image uploaded successfully',
        ]);
    }
}
