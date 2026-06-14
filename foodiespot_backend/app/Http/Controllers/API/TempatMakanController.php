<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;

class TempatMakanController extends Controller
{
    // --- 1. READ (Lihat Semua Data - Untuk Beranda Aplikasi) ---
    public function index(Request $request)
    {
        // Menampilkan SEMUA tempat makan agar User dan Owner bisa melihat-lihat
        $tempatMakan = TempatMakan::latest()->get();

        return response()->json([
            'status' => 'success',
            'data' => $tempatMakan
        ], 200);
    }

    // --- 2. KHUSUS OWNER (Lihat Warung Milik Sendiri) ---
    public function myTempatMakan(Request $request)
    {
        if ($request->user()->role !== 'owner') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Mitra/Owner.'], 403);
        }

        // Mengambil data warung khusus milik user yang sedang login
        $tempatMakan = TempatMakan::where('user_id', $request->user()->id)->latest()->get();

        return response()->json([
            'status' => 'success',
            'data' => $tempatMakan
        ], 200);
    }

    // --- 3. CREATE (Buka Warung Baru) ---
    public function store(Request $request)
    {
        if ($request->user()->role !== 'owner' && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Hanya Owner atau Admin yang bisa menambah tempat makan'], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'address' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $tempatMakan = TempatMakan::create([
            'user_id' => $request->user()->id, // Otomatis disangkutkan ke Owner yang login
            'name' => $request->name,
            'description' => $request->description,
            'address' => $request->address,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Tempat makan berhasil ditambahkan',
            'data' => $tempatMakan
        ], 201);
    }

    // --- 4. UPDATE (Edit Informasi Warung) ---
    public function update(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        // Proteksi: Hanya PEMILIK ASLI atau ADMIN yang boleh mengedit
        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki akses untuk mengedit warung ini'], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'address' => 'sometimes|required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $tempatMakan->update($request->only(['name', 'description', 'address']));

        return response()->json([
            'status' => 'success',
            'message' => 'Tempat makan berhasil diperbarui',
            'data' => $tempatMakan
        ], 200);
    }

    // --- 5. DELETE (Tutup Warung Permanen) ---
    public function destroy(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        // Proteksi: Hanya PEMILIK ASLI atau ADMIN yang boleh menghapus
        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak untuk menghapus warung ini'], 403);
        }

        $tempatMakan->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Tempat makan berhasil dihapus'
        ], 200);
    }
}