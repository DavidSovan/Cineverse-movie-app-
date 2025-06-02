import 'dart:convert';
import 'package:cineverse/config/api_config.dart';
import 'package:cineverse/models/tv_show_detail.dart';
import 'package:http/http.dart' as http;

class TvShowDetailService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<TvShowDetail> getTvShowDetail(int tvId) async {
    try {
      final url = ApiConfig.tvShowDetail(tvId);
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TvShowDetail.fromJson(data);
      } else {
        throw Exception(
            'Failed to load TV show details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV show details: $e');
    }
  }
}
