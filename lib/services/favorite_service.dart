import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tempat_makan_model.dart';
import '../utils/constants.dart';

class FavoriteService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. AMBIL SEMUA FAVORIT SAYA ---
  Future<List<TempatMakanModel>> getFavorites() async {
    String? token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/favorites'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => TempatMakanModel.fromJson(item)).toList();
      }
      throw Exception('Gagal memuat daftar favorit');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- 2. CEK STATUS FAVORIT SAAT BUKA DETAIL WARUNG ---
  Future<bool> checkFavorite(int tempatMakanId) async {
    String? token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/favorite',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body)['is_favorite'];
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 3. TOGGLE (KLIK UNTUK SIMPAN / HAPUS) ---
  Future<bool> toggleFavorite(int tempatMakanId) async {
    String? token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/favorite',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body)['is_favorite'];
      }
      throw Exception('Gagal memperbarui status favorit');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}
