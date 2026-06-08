import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  // --- FUNGSI REGISTER ---
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        // Jika sukses, simpan token dan data user ke lokal HP
        String token = responseData['token'];
        Map<String, dynamic> userMap = responseData['data'];

        await _saveSession(token, userMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- FUNGSI LOGIN ---
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        body: {'email': email, 'password': password},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        String token = responseData['token'];
        Map<String, dynamic> userMap = responseData['data'];

        await _saveSession(token, userMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal login');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- FUNGSI LOGOUT ---
  // --- FUNGSI LOGOUT ---
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    print("DEBUG LOGOUT: Mencoba logout dengan token: $token");

    if (token != null && token.isNotEmpty) {
      try {
        // Tembak API logout ke Laravel dengan batas waktu (TIMEOUT)
        final response = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json', // WAJIB ada
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(
              const Duration(seconds: 5),
            ); // Batasi tunggu maksimal 5 detik

        print("DEBUG LOGOUT: Response Laravel Status: ${response.statusCode}");
      } catch (e) {
        // Kalau server mati atau timeout, abaikan saja dan lanjut hapus sesi lokal
        print("DEBUG LOGOUT: Error jaringan saat kontak server: $e");
      }
    }

    // WAJIB: Hapus data sesi dari HP terlepas dari API sukses atau gagal
    await prefs.remove('token');
    await prefs.remove('user_data');
    await prefs.clear();

    print("DEBUG LOGOUT: Sesi lokal berhasil dibersihkan.");
  }

  // --- HELPER: SIMPAN SESI KE HP ---
  Future<void> _saveSession(String token, Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_data', json.encode(userMap));
  }

  // --- HELPER: AMBIL DATA USER YANG SEDANG LOGIN ---
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      return UserModel.fromJson(json.decode(userDataString));
    }
    return null;
  }
}
