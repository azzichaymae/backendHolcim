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
use App\Http\Controllers\Api\AlertController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\DocumentGenerationController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\ValidationController;

// ── Public routes ──────────────────────────────────────
Route::post('/auth/login', [AuthController::class, 'login']);
Route::get(
    '/validations/confirmer/{token}',
    [ValidationController::class, 'confirmer']
);
Route::get(
    '/validations/refuser/{token}',
    [ValidationController::class, 'refuser']
);
Route::get('/validations/info/{token}', [ValidationController::class, 'info']);

// routes/api.php
Route::post('/auth/request-password-reset', [AuthController::class, 'requestReset']); 
Route::post('/auth/rrh/reset-password/{userId}', [AuthController::class, 'rrhResetPassword'])
    ->middleware('auth:sanctum', 'role:RRH');
// ── Protected routes ───────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // ── Départements ───────────────────────────────────
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/departements', [DepartementController::class, 'index']);
        Route::get('/departements/{departement}', [DepartementController::class, 'show']);
    });
    Route::middleware('role:RRH')->group(function () {
        Route::post('/departements', [DepartementController::class, 'store']);
        Route::put('/departements/{departement}', [DepartementController::class, 'update']);
        Route::delete('/departements/{departement}', [DepartementController::class, 'destroy']);
    });

    // ── Volets ─────────────────────────────────────────
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/volets', [VoletController::class, 'index']);
        Route::get('/volets/{volet}', [VoletController::class, 'show']);
    });
    Route::middleware('role:RRH')->group(function () {
        Route::post('/volets', [VoletController::class, 'store']);
        Route::put('/volets/{volet}', [VoletController::class, 'update']);
        Route::delete('/volets/{volet}', [VoletController::class, 'destroy']);
    });

    // ── Habilitations ──────────────────────────────────
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/habilitations/volet/{volet_id}', [HabilitationController::class, 'getByVolet']);
        Route::get('/habilitations', [HabilitationController::class, 'index']);
        Route::get('/habilitations/{habilitation}', [HabilitationController::class, 'show']);
    });
    Route::middleware('role:RRH')->group(function () {
        Route::post('/habilitations', [HabilitationController::class, 'store']);
        Route::put('/habilitations/{habilitation}', [HabilitationController::class, 'update']);
        Route::delete('/habilitations/{habilitation}', [HabilitationController::class, 'destroy']);
    });

    // ── Employees ──────────────────────────────────────
    Route::middleware('role:RRH')->group(function () {
        Route::get('/employees/archived', [EmployeeController::class, 'archived']);
        Route::patch('/employees/{id}/restore', [EmployeeController::class, 'restore']);
        Route::delete('/employees/{id}/force', [EmployeeController::class, 'forceDelete']);
        Route::delete('/employees/{employee}', [EmployeeController::class, 'destroy']);
    });
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/employees', [EmployeeController::class, 'index']);
        Route::get('/employees/{employee}', [EmployeeController::class, 'show']);
    });
    Route::middleware('role:RRH,RH')->group(function () {
        Route::post('/employees/import', [EmployeeController::class, 'import']);
        Route::post('/employees', [EmployeeController::class, 'store']);
        Route::put('/employees/{employee}', [EmployeeController::class, 'update']);
    });


    // ── Employee Habilitations ─────────────────────────

    Route::middleware('role:RRH,RH,Manager')->group(function () {
        // Static routes first
        Route::get('/employee-habilitations/expiring', [EmployeeHabilitationController::class, 'expiring']);
        Route::get('/employee-habilitations/alertes', [EmployeeHabilitationController::class, 'alertes']);
        Route::post('/employee-habilitations/acknowledge-bulk', [EmployeeHabilitationController::class, 'acknowledgeBulk']);

        // Collection + item routes after
        Route::get('/employee-habilitations', [EmployeeHabilitationController::class, 'index']);
        Route::get('/employee-habilitations/{employeeHabilitation}', [EmployeeHabilitationController::class, 'show']);
        Route::patch('/employee-habilitations/{employeeHabilitation}/acknowledge', [EmployeeHabilitationController::class, 'acknowledge']);
    });

    Route::middleware('role:RRH,RH')->group(function () {
        Route::post('/employee-habilitations', [EmployeeHabilitationController::class, 'store']);
        Route::put('/employee-habilitations/{employeeHabilitation}', [EmployeeHabilitationController::class, 'update']);
        Route::delete('/employee-habilitations/{employeeHabilitation}', [EmployeeHabilitationController::class, 'destroy']);
    });

    // ── Services ───────────────────────────────────────
    Route::middleware('role:RRH,RH')->group(function () {
        Route::get('/services', [ServiceController::class, 'index']);
        Route::get('/services/{service}', [ServiceController::class, 'show']);
    });
    Route::middleware('role:RRH')->group(function () {
        Route::post('/services', [ServiceController::class, 'store']);
        Route::put('/services/{service}', [ServiceController::class, 'update']);
        Route::delete('/services/{service}', [ServiceController::class, 'destroy']);
    });

    // ── Documents ──────────────────────────────────────
 Route::middleware('role:RRH,RH,Manager')->group(function () {
    Route::get('/documents', [DocumentController::class, 'index']);
    Route::get('/documents/all', [DocumentController::class, 'getAllDocuments']);
    Route::get('/documents/download/{document}', [DocumentController::class, 'download']); 
Route::get('/documents/download-by-attribution/{employeeHabilitationId}', [DocumentController::class, 'downloadByAttribution']);
    Route::get('/documents/{document}', [DocumentController::class, 'show']);


});

Route::middleware('role:RRH,RH')->group(function () {
    Route::get('/documents/employees-par-habilitation/{habilitation}', [DocumentGenerationController::class, 'employeesParHabilitation']);
    Route::post('/documents/generate/individuelle', [DocumentGenerationController::class, 'generateIndividuelle']);
    Route::post('/documents/generate/note', [DocumentGenerationController::class, 'generateNote']);
    Route::post('/documents', [DocumentController::class, 'store']);
    Route::delete('/documents/{document}', [DocumentController::class, 'destroy']);
   
});

    // ── Alerts ─────────────────────────────────────────
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/alerts', [AlertController::class, 'index']);
        Route::get('/alerts/count', [AlertController::class, 'count']);

        Route::get('/alerts/{alert}', [AlertController::class, 'show']);
        Route::patch('/alerts/{alert}/vu', [AlertController::class, 'markAsViewed']);
        Route::post('/alerts/vu-grp', [AlertController::class, 'markManyAsViewed']);
        Route::delete('/alerts/{alert}', [AlertController::class, 'destroy']);
    });

    // ── Dashboard ──────────────────────────────────────
    Route::middleware('role:RRH,RH,Manager')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index']);
    });

    // ── Settings ───────────────────────────────────────
    Route::middleware('role:RRH')->group(function () {
        Route::get('/parametres', [SettingController::class, 'index']);
        Route::put('/parametres', [SettingController::class, 'update']);
    });

    // ── Auth ───────────────────────────────────────────
    Route::put('/auth/change-password', [AuthController::class, 'changePassword']);

    // ── Users ──────────────────────────────────────────
    Route::middleware('role:RRH')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::put('/users/{user}', [UserController::class, 'update']);
        Route::delete('/users/{user}', [UserController::class, 'destroy']);
    });
    Route::middleware(['auth:sanctum', 'role:Manager'])->group(function () {
        Route::get('/manager/mon-equipe', [UserController::class, 'monEquipe']);
        Route::get('/manager/recherche-habilitation', [UserController::class, 'rechercheHabilitation']);
    });
    Route::post(
        '/validations/initier/{employeeHabilitation}',
        [ValidationController::class, 'initier']
    );
    Route::get(
        '/validations/{employeeHabilitation}',
        [ValidationController::class, 'statut']
    );
});