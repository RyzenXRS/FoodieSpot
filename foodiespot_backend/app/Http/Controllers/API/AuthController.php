<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // --- FUNGSI REGISTER ---
    public function register(Request $request)
    {
        // 1. Validasi input dari Flutter
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role' => 'required|in:user,owner', // Admin tidak boleh didaftarkan lewat API biasa
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => $validator->errors()->first()
            ], 400);
        }

        // 2. Simpan user ke database
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        // 3. Generate Token (Biar user bisa langsung login setelah register)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil',
            'data' => $user,
            'token' => $token
        ], 201);
    }

    // --- FUNGSI LOGIN ---
    public function login(Request $request)
    {
        // 1. Cek email ada atau tidak
        $user = User::where('email', $request->email)->first();

        // 2. Validasi kredensial (Email salah ATAU Password salah)
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kredensial tidak valid. Email atau password salah.'
            ], 401);
        }

        // 3. Validasi Suspend (Penting untuk FoodieSpot)
        if ($user->is_suspended) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akun Anda telah ditangguhkan.'
            ], 403);
        }

        // 4. Buat Token baru
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil',
            'data' => $user,
            'token' => $token
        ], 200);
    }

    // --- FUNGSI LOGOUT ---
    public function logout(Request $request)
    {
        // Hapus token yang sedang digunakan saat ini
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Berhasil logout'
        ], 200);
    }
}