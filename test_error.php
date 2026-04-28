<?php
$ch = curl_init('http://localhost:8080/api/register');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'username' => '',
    'email' => '',
    'password' => ''
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$resp = curl_exec($ch);
echo "Response: " . $resp . "\n";
