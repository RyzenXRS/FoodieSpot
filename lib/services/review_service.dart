import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/riview_model.dart';
import '../utils/constants.dart';

class ReviewService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. AMBIL DAFTAR REVIEW ---
  Future<List<ReviewModel>> getReviews(int tempatMakanId) async {
    String? token = await _getToken();

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/reviews',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => ReviewModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat review');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- 2. TAMBAH REVIEW BARU ---
  Future<void> addReview(int tempatMakanId, int rating, String comment) async {
    String? token = await _getToken();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/reviews'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'rating': rating.toString(), 'comment': comment},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 201) {
        throw Exception(responseData['message'] ?? 'Gagal mengirim review');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
