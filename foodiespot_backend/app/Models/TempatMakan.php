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

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function photos()
    {
        return $this->hasMany(Photo::class);
    }
    
    public function owner()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}