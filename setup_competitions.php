<?php
$db = new mysqli('localhost', 'root', '', 'promptlib');

if ($db->connect_error) {
    die("Connection failed: " . $db->connect_error);
}

// 1. Create competitions table
$sqlCompetitions = "CREATE TABLE IF NOT EXISTS competitions (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    deadline DATETIME NOT NULL,
    status ENUM('ACTIVE', 'CLOSED') DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

if ($db->query($sqlCompetitions)) {
    echo "Table 'competitions' created.\n";
}

// 2. Add competition_id to prompts table
$sqlAlterPrompts = "ALTER TABLE prompts ADD COLUMN competition_id INT(11) UNSIGNED DEFAULT NULL AFTER user_id;";
$db->query($sqlAlterPrompts); // Might fail if exists, ignoring error

// 3. Add Foreign Key
$sqlFK = "ALTER TABLE prompts ADD CONSTRAINT fk_competition FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE SET NULL;";
$db->query($sqlFK);

// 4. Seed an initial competition
$deadline = date('Y-m-d H:i:s', strtotime('+7 days'));
$title = "CYBER_BRUTALIST_CHALLENGE";
$desc = "Create the ultimate system prompt for a Neo-Brutalist design assistant. Focus on industrial aesthetics and bold instructions.";

$check = $db->query("SELECT id FROM competitions WHERE title = '$title'");
if ($check->num_rows == 0) {
    $db->query("INSERT INTO competitions (title, description, deadline) VALUES ('$title', '$desc', '$deadline')");
    echo "Initial competition seeded.\n";
}

$db->close();
?>
