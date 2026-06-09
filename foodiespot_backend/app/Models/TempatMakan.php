<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempatMakan extends Model
{
    use HasFactory;

    protected $table = 'tempat_makan'; 

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'address',
        'latitude',
        'longitude',
        'image_url',
        'rating',
    ];

    // Tambahkan relasi ini untuk mengambil semua review dari tempat makan ini
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }


    public function owner()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}