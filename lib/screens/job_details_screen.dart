import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/job_post.dart';
import '../providers/auth_provider.dart';
import '../providers/application_provider.dart';
import 'package:dio/dio.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobPost job;

  const JobDetailsScreen({super.key, required this.job});

  void _apply(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apply for Job'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Cover Letter'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ApplicationProvider>().applyJob(job.id, controller.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied successfully!')));
                }
              } catch (e) {
                String message = 'Failed to apply';
                if (e is DioException && e.response?.data != null) {
                  final data = e.response!.data;
                  if (data is Map && data.containsKey('message')) {
                    message = data['message'];
                  }
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    // Define teal colors (just constants, not changing logic)
    const primaryColor = Color(0xFF00897B);
    const darkColor = Color(0xFF004D40);
    const lightColor = Color(0xFFE0F2F1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: primaryColor, // Added teal color
        foregroundColor: Colors.white, // Added white text
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFFAFAFA), // Added light background
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original title with teal styling wrapper
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        job.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: darkColor, // Changed to dark teal
                            ),
                      ),
                    ),
                    // Location with teal styling wrapper
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: primaryColor), // Changed to teal
                          const SizedBox(width: 8),
                          Text(job.location, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    // Salary with teal styling wrapper
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: lightColor, // Changed to light teal
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)), // Changed to teal
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money, color: primaryColor), // Changed to teal
                            const SizedBox(width: 8),
                            Text(
                              job.salary ?? 'Competitive Salary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: darkColor // Changed to dark teal
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // About the Role with teal styling wrapper
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'About the Role', 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: darkColor // Changed to dark teal
                        )
                      ),
                    ),
                    // Description with teal styling wrapper
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lightColor), // Changed to light teal
                      ),
                      child: Text(
                        job.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5, 
                          color: Colors.grey[800]
                        ),
                      ),
                    ),
                    // Requirements section with teal styling wrapper
                    if (job.requirements != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Requirements', 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: darkColor // Changed to dark teal
                          )
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: lightColor), // Changed to light teal
                        ),
                        child: Text(
                          job.requirements!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Bottom action button with teal styling wrapper
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: isAdmin
                    ? ElevatedButton.icon(
                        onPressed: () => context.push('/jobs/${job.id}/applications'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor, // Changed to teal
                          foregroundColor: Colors.white, // Added white text
                        ),
                        icon: const Icon(Icons.people_outline),
                        label: const Text('View Applications'),
                      )
                    : ElevatedButton(
                        onPressed: () => _apply(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor, // Changed to teal
                          foregroundColor: Colors.white, // Added white text
                        ),
                        child: const Text('Apply Now'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}