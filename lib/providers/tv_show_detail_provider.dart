import 'package:cineverse/services/tv_show_detail_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cineverse/models/tv_show_detail.dart';

enum TvShowDetailState { initial, loading, loaded, error }

class TvShowDetailProvider with ChangeNotifier {
  final TvShowDetailService _apiService = TvShowDetailService();

  TvShowDetail? _tvShowDetail;
  TvShowDetailState _state = TvShowDetailState.initial;
  String _errorMessage = '';

  TvShowDetail? get tvShowDetail => _tvShowDetail;
  TvShowDetailState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == TvShowDetailState.loading;
  bool get hasError => _state == TvShowDetailState.error;
  bool get hasData =>
      _state == TvShowDetailState.loaded && _tvShowDetail != null;

  Future<void> fetchTvShowDetail(int tvId) async {
    _state = TvShowDetailState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _tvShowDetail = await _apiService.getTvShowDetail(tvId);
      _state = TvShowDetailState.loaded;
    } catch (e) {
      _state = TvShowDetailState.error;
      _errorMessage = e.toString();
      _tvShowDetail = null;
    }
    notifyListeners();
  }

  void clearData() {
    _tvShowDetail = null;
    _state = TvShowDetailState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
