import 'package:flutter/foundation.dart';
import '../models/smartphone_model.dart';
import '../services/api_service.dart';

enum RecommendState { initial, loading, success, error }

class RecommendationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<SmartphoneModel> _recommendations = [];
  RecommendState _state = RecommendState.initial;
  String _errorMessage = '';
  int _lastMinHarga = 0;
  int _lastMaxHarga = 0;

  // --- Getters ---
  List<SmartphoneModel> get recommendations => _recommendations;
  RecommendState get state => _state;
  String get errorMessage => _errorMessage;
  int get lastMinHarga => _lastMinHarga;
  int get lastMaxHarga => _lastMaxHarga;

  /// Kirim request rekomendasi MABAC ke backend
  Future<void> fetchRecommendation(int minHarga, int maxHarga) async {
    _state = RecommendState.loading;
    _errorMessage = '';
    _recommendations = [];
    _lastMinHarga = minHarga;
    _lastMaxHarga = maxHarga;
    notifyListeners();

    try {
      _recommendations = await _apiService.fetchRecommendation(
        minHarga: minHarga,
        maxHarga: maxHarga,
      );
      _state = RecommendState.success;
    } catch (e) {
      _state = RecommendState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  /// Reset state (misalnya saat kembali ke halaman)
  void reset() {
    _recommendations = [];
    _state = RecommendState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
