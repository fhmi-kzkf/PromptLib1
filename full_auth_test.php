<?php
function logTest($name, $result, $data = null) {
    echo "[$name] " . ($result ? "✅ SUCCESS" : "❌ FAILED") . "\n";
    if ($data) echo "Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
    echo "-----------------------------------\n";
}

$baseUrl = 'http://localhost:8080/api';
$testEmail = 'test_' . time() . '@auth.io';
$testUser = 'tester_' . time();
$testPass = 'password123';

// 1. REGISTER
echo "Starting Auth Flow Test...\n\n";

$ch = curl_init("$baseUrl/register");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'username' => $testUser,
    'email' => $testEmail,
    'password' => $testPass
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$resp = json_decode(curl_exec($ch), true);
logTest("REGISTER", ($resp['status'] ?? 0) == 201, $resp);

if (($resp['status'] ?? 0) != 201) exit("Tests aborted due to registration failure.\n");

// 2. LOGIN
$ch = curl_init("$baseUrl/login");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'email' => $testEmail,
    'password' => $testPass
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$resp = json_decode(curl_exec($ch), true);
logTest("LOGIN", ($resp['status'] ?? 0) == 200, $resp);

$userId = $resp['data']['id'] ?? null;

// 3. PROFILE
if ($userId) {
    $ch = curl_init("$baseUrl/profile/$userId");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $resp = json_decode(curl_exec($ch), true);
    logTest("PROFILE FETCH", ($resp['status'] ?? 0) == 200, $resp);
}

echo "\nBackend Testing Complete.\n";
