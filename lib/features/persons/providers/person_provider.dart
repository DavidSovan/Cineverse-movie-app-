import 'package:cineverse/features/persons/models/movie_credit_model.dart';
import 'package:cineverse/features/persons/services/person_service.dart';
import 'package:flutter/material.dart';
import '../models/person_model.dart';

class PersonProvider extends ChangeNotifier {
  final _service = PersonService();
  Person? person;
  bool isLoading = false;
  String? error;
  List<MovieCredit> actingCredits = [];
  List<MovieCredit> productionCredits = [];
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadPerson(int personId) async {
    if (_disposed) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      person = await _service.fetchPersonDetails(personId);
    } catch (e) {
      if (_disposed) return;
      error = e.toString();
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMovieCredits(int personId) async {
    if (_disposed) return;

    try {
      final credits = await _service.fetchMovieCredits(personId);
      if (_disposed) return;

      actingCredits = credits.where((c) => c.character != null).toList();
      productionCredits = credits.where((c) => c.job != null).toList();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      error = e.toString();
      notifyListeners();
    }
  }
}
