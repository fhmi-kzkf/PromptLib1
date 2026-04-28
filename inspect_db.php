<?php
// Check what's in the database
$mysqli = new mysqli('localhost', 'root', '', 'promptlib');
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

echo "=== USERS ===\n";
$result = $mysqli->query('SELECT id, username, email, rank FROM users');
while ($row = $result->fetch_assoc()) {
    echo "  User #{$row['id']}: {$row['username']} ({$row['email']}) - {$row['rank']}\n";
}

echo "\n=== PROMPTS ===\n";
$result = $mysqli->query('SELECT id, title, category, user_id, ai_model, is_archived, image_url FROM prompts');
if ($result->num_rows === 0) {
    echo "  No prompts found.\n";
} else {
    while ($row = $result->fetch_assoc()) {
        echo "  Prompt #{$row['id']}: \"{$row['title']}\" | cat={$row['category']} | user_id={$row['user_id']} | model={$row['ai_model']} | archived={$row['is_archived']} | img=" . ($row['image_url'] ?? 'NULL') . "\n";
    }
}

echo "\n=== TABLE STRUCTURE: prompts ===\n";
$result = $mysqli->query('DESCRIBE prompts');
while ($row = $result->fetch_assoc()) {
    echo "  {$row['Field']} | {$row['Type']} | Null={$row['Null']} | Default={$row['Default']}\n";
}
