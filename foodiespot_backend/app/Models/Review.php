<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'tempat_makan_id',
        'rating',
        'comment',
        'image_path',
        'reply',
    ];

    // Otomatis tambahkan full URL gambar ke response JSON
    protected $appends = ['image_url'];

    /**
     * Accessor: Ubah image_path menjadi full URL.
     * Jika tidak ada gambar, return null.
     */
    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image_path) return null;
        return asset('storage/' . $this->image_path);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function tempatMakan()
    {
        return $this->belongsTo(TempatMakan::class);
    }
}