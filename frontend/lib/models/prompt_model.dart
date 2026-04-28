class Prompt {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String aiModel;
  final int? userId;
  final DateTime? createdAt;

  final bool isArchived;
  final String? imageUrl;
  final String? authorName;
  final int voteCount;
  final bool hasVoted;
  final int? competitionId;

  Prompt({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.aiModel,
    this.isArchived = false,
    this.imageUrl,
    this.authorName,
    this.userId,
    this.createdAt,
    this.voteCount = 0,
    this.hasVoted = false,
    this.competitionId,
  });


  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'] ?? 'UNTITLED_RECORD',
      content: json['content'] ?? 'NO_PAYLOAD',
      category: json['category'] ?? 'UNCLASSIFIED',
      aiModel: json['ai_model'] ?? 'SYSTEM_DEFAULT',
      isArchived: json['is_archived'] == 1 || json['is_archived'] == true,
      imageUrl: json['image_url'],
      authorName: json['author_name'],
      userId: json['user_id'] is String ? int.tryParse(json['user_id']) : json['user_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      voteCount: json['vote_count'] is String ? int.tryParse(json['vote_count']) ?? 0 : (json['vote_count'] ?? 0),
      hasVoted: json['has_voted'] == 1 || json['has_voted'] == '1' || json['has_voted'] == true,
      competitionId: json['competition_id'] is String ? int.tryParse(json['competition_id']) : json['competition_id'],
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
      if (imageUrl != null) 'image_url': imageUrl,
      if (userId != null) 'user_id': userId,
      if (competitionId != null) 'competition_id': competitionId,
    };
  }

}
