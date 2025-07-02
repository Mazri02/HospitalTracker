<?php

use App\Http\Controllers\HospitalController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\DoctorController;
use App\Http\Middleware\CorsMiddleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\URL;

Route::post('/LoginDoctor', [DoctorController::class, 'LoginDoctor']);
Route::post('/RegisterDoctor', [DoctorController::class, 'RegisterDoctor']);
Route::post('/RegisterUser', [UserController::class, 'RegisterUser']);
Route::post('/LoginUser', [UserController::class, 'LoginUser']);
Route::post('/logout/{id}', [UserController::class, 'logout']);

Route::middleware('auth:sanctum')->group(function () {
    Route::delete('/DeleteUser/{id}/{type}', [UserController::class, 'DeleteUser']);
    Route::get('/GetUserData/{id}/{type}', [UserController::class, 'GetUserData']);
    Route::post('/EditUser/{id}/{type}', [UserController::class, 'EditUser']);
    
    Route::get('/AllHospital', [HospitalController::class, 'allHospital']);
    Route::get('/ViewHospital/{id}', [HospitalController::class, 'ViewHospital']);
    
    Route::delete('/DeleteHospital/{id}', [HospitalController::class, 'DeleteHospital']);
    Route::post('/RegisterHospital', [HospitalController::class, 'RegisterLocation']);
    Route::post('/AssignHospital/{id}/{hostid}', [DoctorController::class, 'assignHospital']);
    Route::post('/LeaveHospital/{id}/{hostid}', [DoctorController::class, 'leaveHospital']);

    Route::post('/BookAppointment/{id}/{assignid}', [UserController::class, 'bookAppointment']);
    Route::delete('/CancelAppointment/{appointid}', [UserController::class, 'cancelAppointment']);
    Route::get('/AllAppointment/{hostid}', [HospitalController::class, 'allAppointment']);
    Route::get('/SelectAppointment/{hostid}/{id}', [HospitalController::class, 'selectAppointment']);
    Route::post('/UpdateAppointment/{id}/{status}', [DoctorController::class, 'updateAppointment']);

    Route::post('/SubmitReview/{id}', [UserController::class, 'submitReview']);
    Route::delete('/DeleteReview/{id}', [UserController::class, 'deleteReview']);
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});