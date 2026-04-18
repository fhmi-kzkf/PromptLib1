<?php
$mysqli = new mysqli('localhost', 'root', '');
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}
if (!$mysqli->query('CREATE DATABASE IF NOT EXISTS promptlib')) {
    die('Error creating database: ' . $mysqli->error);
}
echo "Database promptlib created successfully\n";
$mysqli->close();
?>
