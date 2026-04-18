class Prompt {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String aiModel;
  final int? userId;
  final DateTime? createdAt;

  final bool isArchived;

  Prompt({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.aiModel,
    this.isArchived = false,
    this.userId,
    this.createdAt,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'] ?? 'UNTITLED_RECORD',
      content: json['content'] ?? 'NO_PAYLOAD',
      category: json['category'] ?? 'UNCLASSIFIED',
      aiModel: json['ai_model'] ?? 'SYSTEM_DEFAULT',
      isArchived: json['is_archived'] == 1 || json['is_archived'] == true,
      userId: json['user_id'] is String ? int.tryParse(json['user_id']) : json['user_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'category': category,
      'ai_model': aiModel,
      'is_archived': isArchived ? 1 : 0,
      if (userId != null) 'user_id': userId,
    };
  }
}
