import 'prompt_model.dart';

class Competition {
  final int? id;
  final String title;
  final String description;
  final DateTime deadline;
  final String status;
  final int entryCount;
  final List<Prompt>? entries;

  Competition({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = 'ACTIVE',
    this.entryCount = 0,
    this.entries,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'],
      entryCount: json['entry_count'] is String ? int.tryParse(json['entry_count']) ?? 0 : (json['entry_count'] ?? 0),
      entries: json['entries'] != null
          ? (json['entries'] as List).map((e) => Prompt.fromJson(e)).toList()
          : null,
    );
  }
}
