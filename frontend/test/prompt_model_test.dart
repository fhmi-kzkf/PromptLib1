import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/prompt_model.dart';

void main() {
  group('Prompt Model Tests', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': '1',
        'title': 'Test Title',
        'content': 'Test Content',
        'category': 'Test Category',
        'ai_model': 'gemini-2.5-flash',
        'user_id': '10',
        'created_at': '2026-04-18 10:00:00',
      };

      final prompt = Prompt.fromJson(json);

      expect(prompt.id, 1);
      expect(prompt.title, 'Test Title');
      expect(prompt.userId, 10);
      expect(prompt.aiModel, 'gemini-2.5-flash');
    });

    test('should convert to JSON correctly', () {
      final prompt = Prompt(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        category: 'Test Category',
        aiModel: 'gemini-2.5-flash',
        userId: 10,
      );

      final json = prompt.toJson();

      expect(json['title'], 'Test Title');
      expect(json['ai_model'], 'gemini-2.5-flash');
      expect(json['user_id'], 10);
    });
  });
}
