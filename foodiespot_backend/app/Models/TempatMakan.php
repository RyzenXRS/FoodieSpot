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

    // Otomatis tambahkan full URL cover dan flag maps ke response JSON
    protected $appends = ['cover_url', 'maps_url'];

    /**
     * Accessor: Full URL gambar cover tempat makan.
     * Contoh hasil: http://10.0.2.2:8000/storage/tempat_makan_cover/abc.jpg
     */
    public function getCoverUrlAttribute(): ?string
    {
        if (!$this->image_url) return null;
        // Jika sudah berupa URL penuh (http...), kembalikan langsung
        if (str_starts_with($this->image_url, 'http')) return $this->image_url;
        return asset('storage/' . $this->image_url);
    }

    /**
     * Accessor: URL Google Maps untuk navigasi langsung dari Flutter.
     * Flutter tinggal buka URL ini dengan url_launcher → otomatis buka Google Maps.
     * Contoh: https://www.google.com/maps/dir/?api=1&destination=-6.200,106.816
     */
    public function getMapsUrlAttribute(): ?string
    {
        if (!$this->latitude || !$this->longitude) return null;
        return "https://www.google.com/maps/dir/?api=1&destination={$this->latitude},{$this->longitude}";
    }

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

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}