import 'package:dio/dio.dart';
import '../models/prompt_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api', // Default CI4 port
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // --- Prompts ---

  Future<List<Prompt>> getPrompts({bool archived = false}) async {
    try {
      final response = await _dio.get('/prompts', queryParameters: {'archived': archived});
      return (response.data as List).map((p) => Prompt.fromJson(p)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPrompt(Prompt prompt) async {
    try {
      await _dio.post('/prompts', data: prompt.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePrompt(Prompt prompt) async {
    try {
      await _dio.put('/prompts/${prompt.id}', data: prompt.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePrompt(int id) async {
    try {
      await _dio.delete('/prompts/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> archivePrompt(int id) async {
    try {
      await _dio.post('/prompts/$id/archive');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePrompt(int id) async {
    try {
      await _dio.post('/prompts/$id/restore');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Auth ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {'email': email, 'password': password});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'username': username,
        'email': email,
        'password': password
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- AI ---

  Future<String> refinePrompt(String content) async {
    try {
      final response = await _dio.post('/refine', data: {'prompt': content});
      return response.data['refined'];
    } catch (e) {
      rethrow;
    }
  }
}
