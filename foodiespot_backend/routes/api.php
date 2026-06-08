<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;


// Route yang bebas diakses tanpa token (Publik)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Route yang WAJIB menyertakan Bearer Token dari login (Private)
Route::middleware('auth:sanctum')->group(function () {
    
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Nanti CRUD Warung dari Owner akan dimasukkan ke dalam sini
    // Route::post('/warungs', [WarungController::class, 'store']);
    // ...
});