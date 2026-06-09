<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Review;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    // --- 1. LIHAT SEMUA REVIEW DI SATU TEMPAT MAKAN ---
    public function index($tempatMakanId)
    {
        // Ambil review beserta nama user yang mereview
        $reviews = Review::with('user:id,name,photo_url')
                    ->where('tempat_makan_id', $tempatMakanId)
                    ->latest()
                    ->get();

        return response()->json([
            'status' => 'success',
            'data' => $reviews
        ], 200);
    }

    // --- 2. TAMBAH REVIEW BARU ---
    public function store(Request $request, $tempatMakanId)
    {
        // Pastikan hanya role 'user' yang bisa kasih review
        if ($request->user()->role !== 'user') {
            return response()->json(['status' => 'error', 'message' => 'Hanya pelanggan yang dapat memberikan review'], 403);
        }

        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        // Cek apakah user sudah pernah mereview tempat ini (Biar gak spam)
        $existingReview = Review::where('user_id', $request->user()->id)
                                ->where('tempat_makan_id', $tempatMakanId)
                                ->first();

        if ($existingReview) {
            return response()->json(['status' => 'error', 'message' => 'Anda sudah memberikan review untuk tempat ini'], 400);
        }

        // Simpan Review
        $review = Review::create([
            'user_id' => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        // Kalkulasi ulang rata-rata rating di tabel tempat_makan
        $this->updateAverageRating($tempatMakanId);

        // Load data user agar respons bisa langsung dipakai di UI Flutter
        $review->load('user:id,name,photo_url');

        return response()->json([
            'status' => 'success',
            'message' => 'Review berhasil ditambahkan',
            'data' => $review
        ], 201);
    }

    // --- 3. HAPUS REVIEW (Bisa oleh User yang nulis atau Admin) ---
    public function destroy(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        if ($review->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $tempatMakanId = $review->tempat_makan_id;
        $review->delete();

        // Hitung ulang rating setelah dihapus
        $this->updateAverageRating($tempatMakanId);

        return response()->json(['status' => 'success', 'message' => 'Review berhasil dihapus'], 200);
    }

    // --- FUNGSI HELPER: Kalkulasi Rata-rata Rating ---
    private function updateAverageRating($tempatMakanId)
    {
        $rataRata = Review::where('tempat_makan_id', $tempatMakanId)->avg('rating');
        
        // Update data rating di tabel tempat_makan
        TempatMakan::where('id', $tempatMakanId)->update([
            'rating' => round($rataRata ?? 0, 1) // Jika null (tidak ada review), set 0
        ]);
    }
}