<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddFieldsToUsersAndPrompts extends Migration
{
    public function up()
    {
        // Update Users table
        // Note: rank and avatar_url might have been added in a previous failed run.
        // We will check if they exist or just try to add them.
        // To be safe, we'll only add what's missing.
        
        $db = \Config\Database::connect();
        
        if (!$db->fieldExists('rank', 'users')) {
            $this->forge->addColumn('users', [
                'rank' => [
                    'type'       => 'VARCHAR',
                    'constraint' => 50,
                    'default'    => 'JUNIOR ARCHIVIST',
                    'after'      => 'password',
                ],
            ]);
        }

        if (!$db->fieldExists('avatar_url', 'users')) {
            $this->forge->addColumn('users', [
                'avatar_url' => [
                    'type'       => 'VARCHAR',
                    'constraint' => 255,
                    'null'       => true,
                    'after'      => 'rank',
                ],
            ]);
        }

        // Update Prompts table
        if (!$db->fieldExists('is_archived', 'prompts')) {
            $this->forge->addColumn('prompts', [
                'is_archived' => [
                    'type'       => 'TINYINT',
                    'constraint' => 1,
                    'default'    => 0,
                    'after'      => 'ai_model',
                ],
            ]);
        }
        
        // category already exists in the initial migration, so we don't add it here.
    }

    public function down()
    {
        $db = \Config\Database::connect();
        if ($db->fieldExists('rank', 'users')) {
            $this->forge->dropColumn('users', 'rank');
        }
        if ($db->fieldExists('avatar_url', 'users')) {
            $this->forge->dropColumn('users', 'avatar_url');
        }
        if ($db->fieldExists('is_archived', 'prompts')) {
            $this->forge->dropColumn('prompts', 'is_archived');
        }
    }
}
