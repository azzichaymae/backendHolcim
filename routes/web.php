<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ValidationController;
 
// All routes handled by Vue Router
Route::get('/{any}', function () {
    return view('app');
})->where('any', '.*');
// routes/web.php
Route::get('/validation/confirmer/{token}', [ValidationController::class, 'confirmer'])->name('validation.confirm');
Route::get('/validation/refuser/{token}', [ValidationController::class, 'refuser'])->name('validation.refuse');
Route::get('/validation-confirmer', [ValidationController::class, 'confirmationPage'])->name('validation.confirmation');
Route::get('/validation-refuser', [ValidationController::class, 'refusPage'])->name('validation.refus');