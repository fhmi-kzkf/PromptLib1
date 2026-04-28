<?php

namespace App\Models;

use CodeIgniter\Model;

class CompetitionModel extends Model
{
    protected $table            = 'competitions';
    protected $primaryKey       = 'id';
    protected $allowedFields    = ['title', 'description', 'deadline', 'status'];
    protected $useTimestamps    = true;
}
