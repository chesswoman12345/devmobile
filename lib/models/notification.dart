class AppNotification {
  final int id;
  final String message;
  final String type;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.message,
    required this.type,
    this.readAt,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  bool get isRead => readAt != null;
}
