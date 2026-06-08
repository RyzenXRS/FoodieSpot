<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;

class TempatMakanController extends Controller
{
    // 1. READ (Lihat Data)
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'owner') {
            $tempatMakan = TempatMakan::where('user_id', $user->id)->latest()->get();
        } else {
            $tempatMakan = TempatMakan::latest()->get();
        }

        return response()->json([
            'status' => 'success',
            'data' => $tempatMakan
        ], 200);
    }

    // 2. CREATE (Tambah Data)
    public function store(Request $request)
    {
        if ($request->user()->role !== 'owner' && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
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
            'user_id' => $request->user()->id,
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

    // 3. UPDATE (Edit Data)
    public function update(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki akses'], 403);
        }

        $tempatMakan->update($request->only(['name', 'description', 'address']));

        return response()->json([
            'status' => 'success',
            'message' => 'Tempat makan berhasil diperbarui',
            'data' => $tempatMakan
        ], 200);
    }

    // 4. DELETE (Hapus Data)
    public function destroy(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $tempatMakan->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Tempat makan berhasil dihapus'
        ], 200);
    }
}