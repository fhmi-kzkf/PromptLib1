<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Config\Services;

class Cors implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        if (is_cli()) {
            return;
        }

        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Headers: X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method, Authorization, X-Tunnel-Skip-AntiPhishing-Page');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE');

        if (strcasecmp($request->getMethod(), 'options') === 0) {
            $response = Services::response();
            $response->setStatusCode(200);
            $response->setBody('');
            return $response;
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        //
    }
}
