<?php
// Test script to insert a prompt using the model directly
require 'backend/vendor/autoload.php';
require 'backend/app/Config/Constants.php';

// Mock the environment
define('ENVIRONMENT', 'development');

// Initialize CI4
$app = \Config\Services::codeigniter();
$app->initialize();

use App\Models\PromptModel;

$model = new PromptModel();
$data = [
    'title'    => 'Manual Test',
    'content'  => 'Testing from script',
    'category' => 'Test',
    'ai_model' => 'gemini-2.5-flash-lite'
];

if ($model->insert($data)) {
    echo "Insert successful\n";
} else {
    echo "Insert failed\n";
    print_r($model->errors());
}
?>
