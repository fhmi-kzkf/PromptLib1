<?php
$db = new mysqli('localhost', 'root', '', 'promptlib');

if ($db->connect_error) {
    die("Connection failed: " . $db->connect_error);
}

// URLs for the images (pointing to our backend server)
$img1 = "http://localhost:8080/uploads/ai_core.png";
$img2 = "http://localhost:8080/uploads/archives.png";

// Update the top 2 prompts with these images
// I'll pick prompts that don't have images yet
$sql1 = "UPDATE prompts SET image_url = '$img1' WHERE id = 17";
$sql2 = "UPDATE prompts SET image_url = '$img2' WHERE id = 21";

if ($db->query($sql1)) {
    echo "Prompt 17 updated with image.\n";
}
if ($db->query($sql2)) {
    echo "Prompt 21 updated with image.\n";
}

$db->close();
?>
