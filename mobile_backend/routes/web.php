<?php

use App\Http\Controllers\LocationController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\CorsMiddleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\URL;

Route::get('/', function () {
    return view('welcome');
})->name('login');