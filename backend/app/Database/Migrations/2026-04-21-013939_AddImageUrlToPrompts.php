<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddImageUrlToPrompts extends Migration
{
    public function up()
    {
        $fields = [
            'image_url' => [
                'type'       => 'TEXT',
                'null'       => true,
                'after'      => 'ai_model',
            ],
        ];
        $this->forge->addColumn('prompts', $fields);
    }

    public function down()
    {
        $this->forge->dropColumn('prompts', 'image_url');
    }

}
