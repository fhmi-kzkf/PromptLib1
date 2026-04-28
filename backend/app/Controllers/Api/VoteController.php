<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\VoteModel;

class VoteController extends ResourceController
{
    protected $format = 'json';

    /**
     * Toggle vote (upvote/unvote) for a prompt.
     * POST /api/prompts/{id}/vote
     * Body: { "user_id": 3 }
     */
    public function toggle($promptId = null)
    {
        $userId = $this->request->getVar('user_id');

        if (!$userId || !$promptId) {
            return $this->fail('user_id and prompt_id are required.');
        }

        $voteModel = new VoteModel();

        // Check if vote already exists
        $existing = $voteModel
            ->where('user_id', $userId)
            ->where('prompt_id', $promptId)
            ->first();

        if ($existing) {
            // Remove vote (unvote)
            $voteModel->delete($existing['id']);
            $newCount = $voteModel->where('prompt_id', $promptId)->countAllResults();
            return $this->respond([
                'status'  => 200,
                'action'  => 'unvoted',
                'votes'   => $newCount,
                'message' => 'Vote removed successfully'
            ]);
        } else {
            // Add vote (upvote)
            $voteModel->insert([
                'user_id'   => $userId,
                'prompt_id' => $promptId,
            ]);
            $newCount = $voteModel->where('prompt_id', $promptId)->countAllResults();
            return $this->respondCreated([
                'status'  => 201,
                'action'  => 'voted',
                'votes'   => $newCount,
                'message' => 'Vote added successfully'
            ]);
        }
    }
}
