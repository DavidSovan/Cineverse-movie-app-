import 'package:cineverse/core/config/api_config.dart';
import 'package:cineverse/features/persons/models/movie_credit_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/person_model.dart';

class PersonService {
  Future<Person> fetchPersonDetails(int personId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/person/$personId?api_key=${ApiConfig.apiKey}');

    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load person details');
    }
  }

  Future<List<MovieCredit>> fetchMovieCredits(int personId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/person/$personId/movie_credits?api_key=${ApiConfig.apiKey}');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final cast = data['cast'] as List;
      final crew = data['crew'] as List;

      final castCredits = cast.map((e) => MovieCredit.fromJson(e)).toList();
      final crewCredits = crew.map((e) => MovieCredit.fromJson(e)).toList();

      return [...castCredits, ...crewCredits];
    } else {
      throw Exception('Failed to load movie credits');
    }
  }
}
