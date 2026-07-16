import 'package:flutter/foundation.dart';
import '../models/smartphone_model.dart';
import '../services/api_service.dart';

enum LoadState { initial, loading, success, error }

class SmartphoneProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<SmartphoneModel> _allSmartphones = [];
  List<SmartphoneModel> _filteredSmartphones = [];
  LoadState _state = LoadState.initial;
  String _errorMessage = '';

  // Filter harga lokal
  double _minFilter = 0;
  double _maxFilter = 20000000;
  static const double kMaxHarga = 20000000;

  // --- Getters ---
  List<SmartphoneModel> get smartphones => _filteredSmartphones;
  LoadState get state => _state;
  String get errorMessage => _errorMessage;
  double get minFilter => _minFilter;
  double get maxFilter => _maxFilter;

  /// Fetch semua smartphone dari API
  Future<void> fetchSmartphones() async {
    _state = LoadState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _allSmartphones = await _apiService.fetchSmartphones();
      _applyFilter();
      _state = LoadState.success;
    } catch (e) {
      _state = LoadState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  /// Update filter range harga dan terapkan secara lokal (tanpa API call)
  void updateFilter(double min, double max) {
    _minFilter = min;
    _maxFilter = max;
    _applyFilter();
    notifyListeners();
  }

  /// Reset filter ke default
  void resetFilter() {
    _minFilter = 0;
    _maxFilter = kMaxHarga;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filteredSmartphones = _allSmartphones.where((phone) {
      return phone.harga >= _minFilter && phone.harga <= _maxFilter;
    }).toList();
  }
}
