<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; 

class User extends Authenticatable
{
    // Tambahkan HasApiTokens di dalam block use ini
    use HasApiTokens, HasFactory, Notifiable;

    /**
     Relasi kolom database yang boleh diisi secara massal (Mass Assignable)
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',         
        'phone',         
        'photo_url',    
        'is_suspended', 
    ];

    /**
     Kolom yang disembunyikan saat Laravel mengembalikan response JSON ke Flutter
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     Konversi tipe data otomatis dari MySQL ke tipe data PHP/Dart
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_suspended' => 'boolean', // Dikonversi ke true/false asli, bukan 1/0 agar Flutter tidak bingung
        ];
    }
}