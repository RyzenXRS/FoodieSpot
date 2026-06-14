<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Review;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    public function index($tempatMakanId)
    {
        // Ambil Review
        $reviews = Review::with('user:id,name,photo_url')
                    ->where('tempat_makan_id', $tempatMakanId)
                    ->latest()
                    ->get();

        return response()->json([
            'status' => 'success',
            'data' => $reviews
        ], 200);
    }

    // Tambah Review
    public function store(Request $request, $tempatMakanId)
    {
        if ($request->user()->role !== 'user') {
            return response()->json(['status' => 'error', 'message' => 'Hanya pelanggan yang dapat memberikan review'], 403);
        }

        // Validasi bisa menerima teks form data dan file gambar sekaligus
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Validasi foto
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $existingReview = Review::where('user_id', $request->user()->id)
                                ->where('tempat_makan_id', $tempatMakanId)->first();

        if ($existingReview) {
            return response()->json(['status' => 'error', 'message' => 'Anda sudah memberikan review untuk tempat ini'], 400);
        }

        $imagePath = null;

        // Jika user melampirkan foto saat review...
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('tempat_makan_photos', 'public');
            
            // --- TRIK MAGIS ---
            // Otomatis buat data di tabel Photos agar galeri foto tetap berfungsi!
            \App\Models\Photo::create([
                'user_id' => $request->user()->id,
                'tempat_makan_id' => $tempatMakanId,
                'image_path' => $imagePath,
            ]);
        }

        $review = Review::create([
            'user_id' => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'image_path' => $imagePath, // Simpan di review juga
        ]);

        $this->updateAverageRating($tempatMakanId);
        $review->load('user:id,name,photo_url');

        return response()->json([
            'status' => 'success',
            'message' => 'Review berhasil ditambahkan',
            'data' => $review
        ], 201);
    }

    // HAPUS REVIEW 
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

    //Kalkulasi Rata-rata Rating 
    private function updateAverageRating($tempatMakanId)
    {
        $rataRata = Review::where('tempat_makan_id', $tempatMakanId)->avg('rating');
        
        TempatMakan::where('id', $tempatMakanId)->update([
            'rating' => round($rataRata ?? 0, 1) // Jika null (tidak ada review), set 0
        ]);
    }

    // --- OWNER MEMBALAS REVIEW ---
    public function reply(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        // Cari data warungnya untuk ngecek siapa pemiliknya
        $tempatMakan = \App\Models\TempatMakan::find($review->tempat_makan_id);

        // Proteksi tingkat tinggi: Hanya PEMILIK WARUNG yang boleh membalas!
        if ($tempatMakan->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Hanya pemilik warung yang berhak membalas ulasan ini.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'reply' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $review->update(['reply' => $request->reply]);

        return response()->json([
            'status' => 'success',
            'message' => 'Berhasil membalas ulasan pelanggan',
            'data' => $review
        ], 200);
    }
}
// Test