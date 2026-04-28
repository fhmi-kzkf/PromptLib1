<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

$routes->group('api', ['namespace' => 'App\Controllers\Api'], function($routes) {
    // Prompts
    $routes->resource('prompts', ['controller' => 'PromptController']);
    $routes->post('prompts/(:num)/archive', 'PromptController::archive/$1');
    $routes->post('prompts/(:num)/restore', 'PromptController::restore/$1');
    $routes->post('prompts/(:num)/vote', 'VoteController::toggle/$1');
    
    // Auth
    $routes->post('register', 'AuthController::register');
    $routes->post('login', 'AuthController::login');
    $routes->get('profile/(:num)', 'AuthController::profile/$1');

    // AI
    $routes->post('refine', 'RefineController::create');

    // Competitions
    $routes->get('competitions', 'CompetitionController::index');
    $routes->get('competitions/(:num)', 'CompetitionController::show/$1');
});
