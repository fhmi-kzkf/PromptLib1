<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;

class WebApp extends BaseController
{
    /**
     * Redirect root to the Flutter app.
     */
    public function index(): ResponseInterface
    {
        return $this->response->redirect('/app/');
    }

    /**
     * Serve the Flutter web app's index.html.
     * All /app/* routes are caught here so Flutter handles client-side routing.
     */
    public function serve(): string
    {
        $indexPath = FCPATH . 'app' . DIRECTORY_SEPARATOR . 'index.html';

        if (! file_exists($indexPath)) {
            return '<h1>Flutter Web App Not Found</h1>'
                 . '<p>Please build the Flutter web app and deploy it.</p>'
                 . '<p>Run: <code>deploy_lan.bat</code> from the project root.</p>';
        }

        return file_get_contents($indexPath);
    }
}
