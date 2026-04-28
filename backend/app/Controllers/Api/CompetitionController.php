<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class CompetitionController extends ResourceController
{
    protected $modelName = 'App\Models\CompetitionModel';
    protected $format    = 'json';

    public function index()
    {
        $db = \Config\Database::connect();
        $builder = $db->table('competitions');
        $builder->select('competitions.*');
        $builder->select('(SELECT COUNT(*) FROM prompts WHERE prompts.competition_id = competitions.id) as entry_count');
        $builder->orderBy('deadline', 'ASC');
        
        $data = $builder->get()->getResultArray();
        return $this->respond($data);
    }

    public function show($id = null)
    {
        $db = \Config\Database::connect();
        $comp = $db->table('competitions')->where('id', $id)->get()->getRowArray();
        
        if (!$comp) {
            return $this->failNotFound('Competition not found');
        }

        // Get prompts for this competition ordered by votes
        $builder = $db->table('prompts');
        $builder->select('prompts.*, users.username as author_name');
        $builder->select('(SELECT COUNT(*) FROM votes WHERE votes.prompt_id = prompts.id) as vote_count');
        $builder->join('users', 'users.id = prompts.user_id', 'left');
        $builder->where('prompts.competition_id', $id);
        $builder->orderBy('vote_count', 'DESC');
        
        $prompts = $builder->get()->getResultArray();
        $comp['entries'] = $prompts;

        return $this->respond($comp);
    }
}
