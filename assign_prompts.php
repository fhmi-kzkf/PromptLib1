<?php
$mysqli = new mysqli('localhost', 'root', '', 'promptlib');
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

// Find the last inserted user (highest ID) as it's most likely the user's current testing account
$result = $mysqli->query('SELECT id, username FROM users ORDER BY id DESC LIMIT 1');
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    $userId = $user['id'];
    $username = $user['username'];
    
    echo "Updating prompts to belong to user: $username (ID: $userId)...\n";
    
    // Update all prompts that have no user_id or empty user_id to belong to this user
    $mysqli->query("UPDATE prompts SET user_id = $userId WHERE user_id IS NULL OR user_id = 0 OR user_id = ''");
    
    echo "Successfully assigned " . $mysqli->affected_rows . " prompts to $username.\n";
} else {
    echo "No users found in database.\n";
}
