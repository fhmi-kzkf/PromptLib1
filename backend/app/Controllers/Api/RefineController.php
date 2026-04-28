<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class RefineController extends ResourceController
{
    protected $format = 'json';

    public function create()
    {
        $prompt = $this->request->getVar('prompt');
        if (empty($prompt)) {
            return $this->fail('Prompt content is required');
        }

        $apiKey = env('gemini.api_key');
        // Fallback to a valid default if key is not set for testing
        if (empty($apiKey) || $apiKey === 'YOUR_GEMINI_API_KEY_HERE') {
            return $this->fail('Gemini API Key is not configured in .env', 500);
        }

        $model = env('gemini.model') ?? 'gemini-2.5-flash';

        // Note: The model name in the URL needs to be corrected if the user-provided one is invalid.
        // Assuming gemini-2.5-flash is the desired model or mapping it to the latest available.
        // For now, using the one from .env directly.
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}";

        $data = [
            'contents' => [
                [
                    'parts' => [
                        ['text' => "Refine this prompt to be more descriptive and effective for an AI model. Return ONLY the refined prompt text without any explanations or conversational filler: \n\n" . $prompt]
                    ]
                ]
            ]
        ];

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            return $this->fail('Failed to refine prompt: ' . $response, $httpCode);
        }

        $result = json_decode($response, true);
        $refinedText = $result['candidates'][0]['content']['parts'][0]['text'] ?? '';

        return $this->respond([
            'original' => $prompt,
            'refined' => trim($refinedText)
        ]);
    }
}
