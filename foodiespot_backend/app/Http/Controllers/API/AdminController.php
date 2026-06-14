<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanOwner;
use App\Models\User;

class AdminController extends Controller
{
    // --- 1. LIHAT SEMUA PENGAJUAN (Khusus Admin) ---
    public function getPengajuan(Request $request)
    {
        // Pastikan hanya admin yang bisa akses
        if ($request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        // Ambil semua pengajuan yang statusnya 'pending', beserta nama dan email usernya
        $pengajuan = PengajuanOwner::with('user:id,name,email')
                                   ->where('status', 'pending')
                                   ->latest()
                                   ->get();

        return response()->json([
            'status' => 'success',
            'data' => $pengajuan
        ], 200);
    }

    // --- 2. SETUJUI PENGAJUAN ---
    public function setujuiPengajuan(Request $request, $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $pengajuan = PengajuanOwner::find($id);

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Data pengajuan tidak ditemukan.'], 404);
        }

        // 1. Ubah status pengajuan jadi approved
        $pengajuan->update(['status' => 'approved']);

        // 2. MAGIC: Ubah role User pemohon dari 'user' menjadi 'owner'
        $user = User::find($pengajuan->user_id);
        if ($user) {
            $user->update(['role' => 'owner']);
        }

        return response()->json([
            'status' => 'success',
            'message' => "Pengajuan toko '{$pengajuan->nama_toko}' berhasil disetujui. User sekarang adalah Owner!"
        ], 200);
    }

    // --- 3. TOLAK PENGAJUAN ---
    public function tolakPengajuan(Request $request, $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $pengajuan = PengajuanOwner::find($id);

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Data pengajuan tidak ditemukan.'], 404);
        }

        // Ubah status pengajuan jadi rejected (Ditolak)
        $pengajuan->update(['status' => 'rejected']);

        return response()->json([
            'status' => 'success',
            'message' => "Pengajuan toko '{$pengajuan->nama_toko}' telah ditolak."
        ], 200);
    }
}