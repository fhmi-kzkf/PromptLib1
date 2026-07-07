<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\PromptModel;

class PromptController extends ResourceController
{
    protected $modelName = 'App\Models\PromptModel';
    protected $format    = 'json';

    /**
     * Return an array of resource objects, themselves in array format
     *
     * @return mixed
     */
    public function index()
    {
        $showArchived = $this->request->getGet('archived') === 'true';
        $currentUserId = $this->request->getGet('user_id');

        $db = \Config\Database::connect();
        $builder = $db->table('prompts');
        $builder->select('prompts.*, users.username as author_name');
        $builder->select('(SELECT COUNT(*) FROM votes WHERE votes.prompt_id = prompts.id) as vote_count');
        
        if ($currentUserId) {
            $builder->select("(SELECT COUNT(*) FROM votes WHERE votes.prompt_id = prompts.id AND votes.user_id = $currentUserId) as has_voted");
        } else {
            $builder->select("0 as has_voted");
        }

        $builder->join('users', 'users.id = prompts.user_id', 'left');
        
        if ($showArchived) {
            if ($currentUserId) {
                $builder->where('prompts.user_id', $currentUserId);
            } else {
                // If no user is logged in, return empty for archive
                $builder->where('prompts.user_id', -1);
            }
        } else {
            $builder->where('prompts.is_archived', 0);
        }
        
        $builder->where('prompts.competition_id IS NULL');
        $builder->orderBy('vote_count', 'DESC');
        $builder->orderBy('prompts.created_at', 'DESC');

        $prompts = $builder->get()->getResultArray();
            
        return $this->respond($prompts);
    }

    /**
     * Return the properties of a resource object
     *
     * @return mixed
     */
    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Prompt not found');
        }
        return $this->respond($data);
    }

    /**
     * Create a new resource object, from "posted" parameters
     *
     * @return mixed
     */
    public function create()
    {
        $rules = [
            'title'    => 'required|min_length[3]',
            'content'  => 'required',
            'category' => 'required'
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $data = [
            'title'    => $this->request->getVar('title'),
            'content'  => $this->request->getVar('content'),
            'category' => $this->request->getVar('category'),
            'ai_model' => $this->request->getVar('ai_model') ?? 'gemini-2.5-flash-lite',
            'user_id'  => $this->request->getVar('user_id'),
            'image_url' => $this->request->getVar('image_url'),
            'competition_id' => $this->request->getVar('competition_id'),
        ];

        $this->model->insert($data);
        $response = [
            'status'   => 201,
            'error'    => null,
            'messages' => [
                'success' => 'Prompt created successfully'
            ]
        ];
        return $this->respondCreated($response);
    }

    /**
     * Add or update a model resource, from "posted" properties
     *
     * @return mixed
     */
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (empty($data)) {
            $data = $this->request->getRawInput();
        }
        
        if (!$this->model->find($id)) {
            return $this->failNotFound('Prompt not found');
        }

        $this->model->update($id, $data);
        $response = [
            'status'   => 200,
            'error'    => null,
            'messages' => [
                'success' => 'Prompt updated successfully'
            ]
        ];
        return $this->respond($response);
    }

    /**
     * Delete the model resource object from the database
     *
     * @return mixed
     */
    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Prompt not found');
        }

        $this->model->delete($id);
        $response = [
            'status'   => 200,
            'error'    => null,
            'messages' => [
                'success' => 'Prompt deleted successfully'
            ]
        ];
        return $this->respondDeleted($response);
    }

    public function archive($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Prompt not found');
        }

        $this->model->update($id, ['is_archived' => 1]);
        return $this->respond([
            'status' => 200,
            'messages' => ['success' => 'Prompt archived successfully']
        ]);
    }

    public function restore($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Prompt not found');
        }

        $this->model->update($id, ['is_archived' => 0]);
        return $this->respond([
            'status' => 200,
            'messages' => ['success' => 'Prompt restored successfully']
        ]);
    }
}
