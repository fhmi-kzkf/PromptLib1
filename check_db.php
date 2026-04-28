<?php
$mysqli = new mysqli('localhost', 'root', '', 'promptlib');
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}
echo 'Connected successfully to promptlib. Users: ' . $mysqli->query('SELECT COUNT(*) FROM users')->fetch_row()[0];
