<?php
$db = new mysqli('localhost', 'root', '', 'promptlib');

if ($db->connect_error) {
    die("Connection failed: " . $db->connect_error);
}

// Create votes table
$sql = "CREATE TABLE IF NOT EXISTS votes (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT(11) UNSIGNED NOT NULL,
    prompt_id INT(11) UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_vote (user_id, prompt_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

if ($db->query($sql)) {
    echo "Table 'votes' created successfully.\n";
} else {
    echo "Error creating table: " . $db->error . "\n";
}

// Seed some votes for existing prompts to make it look alive
$seedVotes = [
    [1, 17], [1, 18], [1, 19], [1, 20], [1, 21],
    [2, 17], [2, 19], [2, 22], [2, 25],
    [3, 18], [3, 20], [3, 23], [3, 24], [3, 26],
];

$stmt = $db->prepare("INSERT IGNORE INTO votes (user_id, prompt_id) VALUES (?, ?)");
$count = 0;
foreach ($seedVotes as $v) {
    $stmt->bind_param("ii", $v[0], $v[1]);
    if ($stmt->execute() && $stmt->affected_rows > 0) {
        $count++;
    }
}
echo "Seeded $count votes.\n";

$stmt->close();
$db->close();
?>
