import 'job_post.dart';
import 'user.dart';

class Application {
  final int id;
  final int userId;
  final int jobPostId;
  final String? coverLetter;
  final String status;
  final JobPost? jobPost;
  final User? user;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.userId,
    required this.jobPostId,
    this.coverLetter,
    required this.status,
    this.jobPost,
    this.user,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      userId: json['user_id'],
      jobPostId: json['job_post_id'],
      coverLetter: json['cover_letter'],
      status: json['status'],
      jobPost: json['job_post'] != null ? JobPost.fromJson(json['job_post']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
