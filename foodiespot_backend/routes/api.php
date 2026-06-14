<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\TempatMakanController;
use App\Http\Controllers\API\ReviewController; 
use App\Http\Controllers\API\PhotoController; 
use App\Http\Controllers\API\PengajuanOwnerController;
use App\Http\Controllers\API\AdminController;
use App\Http\Controllers\API\FavoriteController; 

// Route yang bebas diakses tanpa token (Publik)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Route yang WAJIB menyertakan Bearer Token dari login (Private)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::delete('/profile', [AuthController::class, 'deleteAccount']);
    
    // API Route untuk Tempat Makan
    // API Route untuk Tempat Makan
    Route::apiResource('tempat-makan', TempatMakanController::class);

    // --- ROUTE REVIEW INI ---
    Route::get('/tempat-makan/{id}/reviews', [ReviewController::class, 'index']);
    Route::post('/tempat-makan/{id}/reviews', [ReviewController::class, 'store']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

    Route::get('/tempat-makan/{id}/photos', [PhotoController::class, 'index']);
    Route::post('/tempat-makan/{id}/photos', [PhotoController::class, 'store']);
    Route::delete('/photos/{id}', [PhotoController::class, 'destroy']);

    // --- ROUTE PENGAJUAN OWNER ---
    Route::get('/pengajuan-owner', [PengajuanOwnerController::class, 'cekStatus']);
    Route::post('/pengajuan-owner', [PengajuanOwnerController::class, 'ajukan']);
    Route::delete('/pengajuan-owner', [PengajuanOwnerController::class, 'batalkan']);

    // --- ROUTE KHUSUS ADMIN ---
    Route::get('/admin/pengajuan', [AdminController::class, 'getPengajuan']);
    Route::post('/admin/pengajuan/{id}/approve', [AdminController::class, 'setujuiPengajuan']);
    Route::post('/admin/pengajuan/{id}/reject', [AdminController::class, 'tolakPengajuan']);

    Route::get('/owner/tempat-makan', [App\Http\Controllers\API\TempatMakanController::class, 'myTempatMakan']);
    Route::post('/reviews/{id}/reply', [App\Http\Controllers\API\ReviewController::class, 'reply']);


    // --- ROUTE FAVORIT ---
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::get('/tempat-makan/{id}/favorite', [FavoriteController::class, 'check']);
    Route::post('/tempat-makan/{id}/favorite', [FavoriteController::class, 'toggle']);
});