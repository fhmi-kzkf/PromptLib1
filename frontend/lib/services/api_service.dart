import 'package:dio/dio.dart';
import '../models/prompt_model.dart';
import '../models/competition_model.dart';
import 'user_session.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api', // Default CI4 port
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // --- Singleton ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // --- Competitions ---

  Future<List<Competition>> getCompetitions() async {
    try {
      final response = await _dio.get('/competitions');
      return (response.data as List).map((c) => Competition.fromJson(c)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Competition> getCompetitionDetails(int id) async {
    try {
      final response = await _dio.get('/competitions/$id');
      return Competition.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // --- Prompts ---

  Future<List<Prompt>> getPrompts({bool archived = false}) async {
    try {
      final params = <String, dynamic>{'archived': archived};
      final userId = UserSession().userId;
      if (userId != null) {
        params['user_id'] = userId;
      }
      final response = await _dio.get('/prompts', queryParameters: params);
      return (response.data as List).map((p) => Prompt.fromJson(p)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPrompt(Prompt prompt) async {
    try {
      final data = prompt.toJson();
      data['user_id'] = UserSession().userId;
      await _dio.post('/prompts', data: data);
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

  // --- Votes ---

  Future<Map<String, dynamic>> toggleVote(int promptId) async {
    try {
      final response = await _dio.post('/prompts/$promptId/vote', data: {
        'user_id': UserSession().userId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- Auth ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {'email': email, 'password': password});
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        throw Exception(data['message'] ?? data['messages'] ?? e.message);
      }
      throw Exception(e.message ?? 'Unknown Login Error');
    } catch (e) {
      throw Exception(e.toString());
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
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        final msgs = data['messages'];
        String msg = data['message'] ?? '';
        if (msgs is Map && msgs.isNotEmpty) {
           msg = msgs.values.first.toString();
        } else if (msgs is String) {
           msg = msgs;
        }
        throw Exception(msg.isNotEmpty ? msg : e.message);
      }
      throw Exception(e.message ?? 'Unknown Register Error');
    } catch (e) {
      throw Exception(e.toString());
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
