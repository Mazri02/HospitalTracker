<?php

use App\Http\Controllers\LocationController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\CorsMiddleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\URL;

URL::forceScheme('https');

Route::get('/', function () {
    return view('welcome');
});

Route::get('api/RegisterLocation', [LocationController::class, 'RegisterLocation']);

Route::middleware([CorsMiddleware::class])->group(function () {
    Route::get('/csrf-token', function (Request $request) {
        return response()->json(['csrf_token' => csrf_token()]);
    });

    //Route::get('api/RegisterUser', [UserController::class, 'RegisterUser']);
    Route::get('api/CheckUser', [UserController::class, 'CheckUser']);
    Route::get('api/DeleteUser', [UserController::class, 'DeleteUser']);
    Route::get('api/EditUser', [UserController::class, 'EditUser']);

    Route::get('api/ViewAllLocation', [LocationController::class, 'ViewAllLocation']);
    Route::get('api/ViewLocationByID', [LocationController::class, 'ViewLocationByID']);
    Route::get('api/RegisterLocation', [LocationController::class, 'RegisterLocation']);
    Route::get('api/DeleteLocation', [LocationController::class, 'DeleteLocation']);
    Route::get('api/updateLocation', [LocationController::class, 'updateLocation']);
});
