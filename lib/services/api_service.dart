import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/smartphone_model.dart';

class ApiService {
  // Timeout untuk setiap request
  static const _timeout = Duration(seconds: 1500);

  String _previewBody(String body) {
    final trimmed = body.trim();
    if (trimmed.length <= 200) {
      return trimmed;
    }
    return '${trimmed.substring(0, 200)}...';
  }

  List<dynamic> _extractDataArray(dynamic body) {
    if (body is List) {
      return body.cast<dynamic>();
    }

    if (body is Map) {
      final map = Map<String, dynamic>.from(body as Map);

      for (final key in [
        'data',
        'items',
        'results',
        'recommendations',
        'result',
        'list',
      ]) {
        final value = map[key];
        if (value is List) {
          return value.cast<dynamic>();
        }

        if (value is Map) {
          final nestedMap = Map<String, dynamic>.from(value as Map);
          for (final nestedKey in [
            'data',
            'items',
            'results',
            'recommendations',
            'result',
            'list',
          ]) {
            final nestedValue = nestedMap[nestedKey];
            if (nestedValue is List) {
              return nestedValue.cast<dynamic>();
            }
            if (nestedValue is Map) {
              return [nestedValue];
            }
          }

          if (nestedMap.containsKey('smartphone') ||
              nestedMap.containsKey('mabac_score')) {
            return [nestedMap];
          }
        }
      }

      if (map.containsKey('smartphone') || map.containsKey('mabac_score')) {
        return [map];
      }
    }

    return [];
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body as Map);
      for (final key in ['message', 'error', 'errors']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
        if (value is List && value.isNotEmpty) {
          return value.join(', ');
        }
      }
    }
    return null;
  }

  dynamic _decodeJsonResponse(http.Response response) {
    final body = response.body.trim();

    if (body.isEmpty) {
      throw Exception(
        'Server mengembalikan respons kosong. Status: ${response.statusCode}',
      );
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception(
        'Server mengembalikan respons bukan JSON. Status: ${response.statusCode}. Respons: ${_previewBody(body)}',
      );
    }
  }

  /// GET /api/public/smartphones
  /// Mengambil semua data katalog smartphone
  Future<List<SmartphoneModel>> fetchSmartphones() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.smartphones))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decodeJsonResponse(response);
        // Mendukung response dalam bentuk list langsung atau object {data: [...]} / {success: true, data: {data:[...]}}
        final List<dynamic> data = _extractDataArray(body);
        return data
            .map(
              (json) => SmartphoneModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        final body = _decodeJsonResponse(response);
        final message = body is Map<String, dynamic>
            ? body['message'] ?? 'Terjadi kesalahan'
            : 'Terjadi kesalahan';
        throw Exception(
          'Gagal memuat katalog (Status: ${response.statusCode}) - $message',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// POST /api/public/recommend
  /// Mengirim [minHarga] dan [maxHarga] lalu mendapat hasil rekomendasi MABAC
  Future<List<SmartphoneModel>> fetchRecommendation({
    required int minHarga,
    required int maxHarga,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.recommend),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'min_harga': minHarga, 'max_harga': maxHarga}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decodeJsonResponse(response);
        final List<dynamic> data = _extractDataArray(body);

        if (data.isEmpty) {
          final message =
              _extractMessage(body) ??
              'Backend mengembalikan respons tanpa data rekomendasi.';
          throw Exception(message);
        }

        return data.asMap().entries.map((entry) {
          final index = entry.key;
          final json = entry.value as Map<String, dynamic>;
          return SmartphoneModel.fromRecommendJson(json, index + 1);
        }).toList();
      } else {
        final body = _decodeJsonResponse(response);
        final message = body is Map<String, dynamic>
            ? body['message'] ?? 'Terjadi kesalahan'
            : 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan rekomendasi: $e');
    }
  }
}
