<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\API\ResponseTrait;

class AuthController extends ResourceController
{
    use ResponseTrait;

    protected $modelName = 'App\Models\UserModel';
    protected $format    = 'json';

    public function register()
    {
        $rules = [
            'username' => 'required|min_length[3]|is_unique[users.username]',
            'email'    => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $data = [
            'username' => $this->request->getVar('username'),
            'email'    => $this->request->getVar('email'),
            'password' => password_hash($this->request->getVar('password'), PASSWORD_BCRYPT),
            'rank'     => 'JUNIOR ARCHIVIST', // Default rank
        ];

        $userId = $this->model->insert($data);

        if (!$userId) {
            return $this->fail('Failed to register user.');
        }

        $user = $this->model->find($userId);
        unset($user['password']);

        return $this->respondCreated([
            'status'  => 201,
            'message' => 'User registered successfully',
            'data'    => $user
        ]);
    }

    public function login()
    {
        $email    = $this->request->getVar('email');
        $password = $this->request->getVar('password');

        $user = $this->model->where('email', $email)->first();

        if (!$user || !password_verify($password, $user['password'])) {
            return $this->failUnauthorized('Invalid email or password');
        }

        unset($user['password']);

        return $this->respond([
            'status'  => 200,
            'message' => 'Login successful',
            'data'    => $user
        ]);
    }

    public function profile($id = null)
    {
        if (!$id) {
            return $this->fail('User ID is required');
        }

        $user = $this->model->find($id);

        if (!$user) {
            return $this->failNotFound('User not found');
        }

        unset($user['password']);

        return $this->respond([
            'status' => 200,
            'data'   => $user
        ]);
    }
}
