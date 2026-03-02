<?php

use App\Http\Controllers\Api\DepartementController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\VoletController;
use App\Http\Controllers\Api\HabilitationController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\EmployeeHabilitationController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\ServiceController;


// ── Public routes ──────────────────────────────────────
Route::post('/auth/login', [AuthController::class, 'login']);

// ── Protected routes ───────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/departements', [DepartementController::class, 'index']);
        Route::get('/departements/{departement}', [DepartementController::class, 'show']);
    });
    Route::middleware('role:RRH')->group(function () {
        Route::post('/departements', [DepartementController::class, 'store']);
        Route::put('/departements/{departement}', [DepartementController::class, 'update']);
        Route::delete('/departements/{departement}', [DepartementController::class, 'destroy']);
    });
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/volets', [VoletController::class, 'index']);
        Route::get('/volets/{volet}', [VoletController::class, 'show']);
    });

    // RRH only
    Route::middleware('role:RRH')->group(function () {
        Route::post('/volets', [VoletController::class, 'store']);
        Route::put('/volets/{volet}', [VoletController::class, 'update']);
        Route::delete('/volets/{volet}', [VoletController::class, 'destroy']);
    });
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/habilitations', [HabilitationController::class, 'index']);
        Route::get('/habilitations/{habilitation}', [HabilitationController::class, 'show']);
    });

    Route::middleware('role:RRH')->group(function () {
        Route::post('/habilitations', [HabilitationController::class, 'store']);
        Route::put('/habilitations/{habilitation}', [HabilitationController::class, 'update']);
        Route::delete('/habilitations/{habilitation}', [HabilitationController::class, 'destroy']);
    });
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/employees', [EmployeeController::class, 'index']);
        Route::get('/employees/{employee}', [EmployeeController::class, 'show']);
        Route::post('/employees', [EmployeeController::class, 'store']);
        Route::put('/employees/{employee}', [EmployeeController::class, 'update']);
    });

    Route::middleware('role:RRH')->group(function () {
        Route::delete('/employees/{employee}', [EmployeeController::class, 'destroy']);
    });

    // Static route first
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get(
            '/employee-habilitations/expiring',
            [EmployeeHabilitationController::class, 'expiring']
        );
    });

    // All three roles can access index and show
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get(
            '/employee-habilitations',
            [EmployeeHabilitationController::class, 'index']
        );
        Route::get(
            '/employee-habilitations/{employeeHabilitation}',
            [EmployeeHabilitationController::class, 'show']
        );
    });

    // Only RRH and RH can create, update, delete
    Route::middleware('role:RRH,RH')->group(function () {
        Route::post(
            '/employee-habilitations',
            [EmployeeHabilitationController::class, 'store']
        );
        Route::put(
            '/employee-habilitations/{employeeHabilitation}',
            [EmployeeHabilitationController::class, 'update']
        );
        Route::delete(
            '/employee-habilitations/{employeeHabilitation}',
            [EmployeeHabilitationController::class, 'destroy']
        );
    });

    // ── Services ───────────────────────────────────────────
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/services', [ServiceController::class, 'index']);
        Route::get('/services/{service}', [ServiceController::class, 'show']);
    });

    Route::middleware('role:RRH')->group(function () {
        Route::post('/services', [ServiceController::class, 'store']);
        Route::put('/services/{service}', [ServiceController::class, 'update']);
        Route::delete('/services/{service}', [ServiceController::class, 'destroy']);
    });

    // ── Documents ──────────────────────────────────────────
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/documents', [DocumentController::class, 'index']);
        Route::get('/documents/{document}', [DocumentController::class, 'show']);
        Route::get('/documents/{document}/download', [DocumentController::class, 'download']);
    });

    Route::middleware('role:RRH,RH')->group(function () {
        Route::post('/documents', [DocumentController::class, 'store']);
        Route::delete('/documents/{document}', [DocumentController::class, 'destroy']);
    });
});
