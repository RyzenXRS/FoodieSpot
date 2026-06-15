<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Photo extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'tempat_makan_id',
        'image_path',
    ];

    // Otomatis tambahkan full URL ke response JSON
    protected $appends = ['image_url'];

    /**
     * Accessor: Ubah image_path (path relatif) menjadi full URL yang bisa langsung dipakai Flutter.
     * Contoh hasil: http://10.0.2.2:8000/storage/tempat_makan_photos/abc.jpg
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