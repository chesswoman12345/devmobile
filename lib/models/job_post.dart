class JobPost {
  final int id;
  final String title;
  final String description;
  final String location;
  final String? salary;
  final String? requirements;
  final int adminId;
  final List<dynamic> applications;

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.salary,
    this.requirements,
    required this.adminId,
    this.applications = const [],
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      salary: json['salary']?.toString(),
      requirements: json['requirements'],
      adminId: json['admin_id'],
      applications: json['applications'] ?? [],
    );
  }
}
