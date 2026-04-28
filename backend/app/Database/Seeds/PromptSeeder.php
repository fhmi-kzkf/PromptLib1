<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;

class PromptSeeder extends Seeder
{
    public function run()
    {
        $data = [
            [
                'title'       => 'FLUTTER_NEO_BRUTALISM_APP',
                'content'     => 'Create a Flutter application with a focus on Neo-Brutalism design. Use bold black borders, high-contrast colors (yellow, pink, cyan), and Google Fonts Space Grotesk. Layout should involve Bento-style grids and industrial components.',
                'category'    => 'DEVELOPMENT',
                'ai_model'    => 'gemini-2.5-flash',
                'image_url'   => 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'CYBER_ARCHIVIST_VISUAL',
                'content'     => 'A cinematic shot of a futuristic cyborg archivist working in a high-tech concrete vault. Soft smoke in the air, glowing blue screens reflecting on metallic skin. Hyper-realistic, 8k, detailed textures.',
                'category'    => 'IMAGE_GEN',
                'ai_model'    => 'dall-e-3',
                'image_url'   => 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'AI_ARCH_IMPACT_RESEARCH',
                'content'     => 'Research the long-term impact of AI on brutalist architecture. Focus on structural optimization, generative design patterns, and sustainable concrete alternatives. Output a 5-page PDF summary.',
                'category'    => 'RESEARCH',
                'ai_model'    => 'gemini-1.5-pro',
                'image_url'   => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 1,
            ],
            [
                'title'       => 'SYSTEM_OPTIMIZATION_PROTOCOL',
                'content'     => 'Analyze the current database schema for PromptLib. Identify potential bottlenecks in prompt retrieval and suggest indexing strategies for the "is_archived" and "category" fields.',
                'category'    => 'SYSTEM',
                'ai_model'    => 'claude-3-opus',
                'image_url'   => 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'PYTHON_BACKEND_REFACTOR',
                'content'     => 'Refactor the existing Django authentication middleware to support JWT and OAuth2 simultaneously. Ensure all legacy cookie-based sessions still function during the transition phase.',
                'category'    => 'DEVELOPMENT',
                'ai_model'    => 'gpt-4-turbo',
                'image_url'   => 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'NEO_CONCRETE_INTERIOR',
                'content'     => 'Interior design prompt: A minimalist living room with raw concrete walls, a single bright yellow velvet sofa, and massive floor-to-ceiling windows showing a rainy cyberpunk cityscape. High contrast, sharp shadows.',
                'category'    => 'IMAGE_GEN',
                'ai_model'    => 'midjourney-v6',
                'image_url'   => 'https://images.unsplash.com/photo-1505691938895-1758d7eaa511?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'RUST_WASM_OPTIMIZATION',
                'content'     => 'Examine a Rust-based image processing algorithm for WebAssembly. Target performance improvements in the pixel-level kernel operations. Use SIMD instructions where possible.',
                'category'    => 'DEVELOPMENT',
                'ai_model'    => 'gemini-1.5-pro',
                'image_url'   => 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'MARKET_DEEP_DIVE_2024',
                'content'     => 'Comprehensive market analysis of the renewable energy sector in Southeast Asia. Include growth projections for solar and wind energy through 2030, and identify key regulatory challenges.',
                'category'    => 'RESEARCH',
                'ai_model'    => 'gpt-4o',
                'image_url'   => 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'CYBER_CITYSCAPE_AERIAL',
                'content'     => 'Aerial drone shot of a sprawling mega-city at night. Endless neon signs, flying vehicles moving in organized streams, and massive vertical farms that glow green in the dark.',
                'category'    => 'IMAGE_GEN',
                'ai_model'    => 'dall-e-3',
                'image_url'   => 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 0,
            ],
            [
                'title'       => 'QUANTUM_COMPUTING_BASICS',
                'content'     => 'Explain the concept of quantum superposition to a 10-year-old. Use an analogy involving a spinning coin and a secret box. Keep it fun and interactive.',
                'category'    => 'RESEARCH',
                'ai_model'    => 'gemini-2.5-flash',
                'image_url'   => 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?q=80&w=800&auto=format&fit=crop',
                'is_archived' => 1,
            ],
        ];


        // Using Query Builder
        $this->db->table('prompts')->insertBatch($data);
    }

}
