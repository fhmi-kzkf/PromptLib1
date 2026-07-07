import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/prompt_model.dart';
import '../models/competition_model.dart';
import 'user_session.dart';

class ApiService {
  // Dynamically resolve the API base URL from the browser's current location.
  // When a friend opens http://192.168.1.66:8080 from their phone,
  // API calls will automatically target http://192.168.1.66:8080/api.
  static String _resolveBaseUrl() {
    if (kIsWeb) {
      // Use the exact origin of the current web page, and append /api
      return '${Uri.base.origin}/api';
    }
    return 'https://w3tqclq0-8080.asse.devtunnels.ms/api';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _resolveBaseUrl(),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bypass-Tunnel-Reminder': 'true',
    },
  ));

  // --- Singleton ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Public getter for the resolved base URL (used for constructing image URLs)
  String get baseUrl => _dio.options.baseUrl;

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
      final params = {'_t': DateTime.now().millisecondsSinceEpoch};
      final response = await _dio.get('/competitions/$id', queryParameters: params);
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

  // --- Upload ---

  /// Upload an image file. Returns the server-relative image URL.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : 'png';
      
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType('image', mimeType),
        ),
      });
      final response = await _dio.post(
        '/upload-image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data['image_url'];
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['messages']?['error'] ?? e.message);
      }
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
