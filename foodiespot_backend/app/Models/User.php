<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
        'photo_url',
        'is_suspended',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    // Otomatis tambahkan full URL foto profil ke response JSON
    protected $appends = ['photo_full_url'];

    /**
     * Accessor: Full URL foto profil user.
     * Contoh hasil: http://10.0.2.2:8000/storage/profile_photos/abc.jpg
     */
    public function getPhotoFullUrlAttribute(): ?string
    {
        if (!$this->photo_url) return null;
        // Jika sudah berupa URL penuh (dari social login, dll), kembalikan langsung
        if (str_starts_with($this->photo_url, 'http')) return $this->photo_url;
        return asset('storage/' . $this->photo_url);
    }

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
            'is_suspended'      => 'boolean',
        ];
    }
}