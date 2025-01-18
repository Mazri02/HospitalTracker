<?php

use App\Http\Controllers\LocationController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/csrf-token', function (Request $request) {
    return response()->json(['csrf_token' => csrf_token()]);
});

Route::get('api/RegisterUser', [UserController::class,"RegisterUser"]);
Route::get('api/CheckUser', [UserController::class,"CheckUser"]);
Route::post('api/DeleteUser', [UserController::class,"DeleteUser"]);
Route::post('api/EditUser', [UserController::class,"EditUser"]);

Route::post('api/ViewAllLocation', [LocationController::class,"ViewAllLocation"]);
Route::post('api/RegisterLocation', [LocationController::class,"RegisterLocation"]);
Route::post('api/ViewLocationByID', [LocationController::class,"ViewLocationByID"]);
Route::post('api/DeleteLocation', [LocationController::class,"DeleteLocation"]);
Route::post('api/updateLocation', [LocationController::class,"updateLocation"]);
