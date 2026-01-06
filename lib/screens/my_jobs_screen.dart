import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/job_provider.dart';
import '../widgets/app_drawer.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchMyJobs();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<JobProvider>().deleteJob(id);
      if (mounted) context.read<JobProvider>().fetchMyJobs(); // Refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    final myJobs = provider.myJobs;

    // Add teal colors
    const primaryColor = Color(0xFF00897B);
    const lightColor = Color(0xFFE0F2F1);
    const darkColor = Color(0xFF004D40);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: provider.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your jobs...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : myJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 80,
                          color: lightColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs posted yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first job posting',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.push('/create-job').then((_) {
                              if (context.mounted) context.read<JobProvider>().fetchMyJobs();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Create Job'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await context.read<JobProvider>().fetchMyJobs();
                    },
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: myJobs.length,
                      itemBuilder: (context, index) {
                        final job = myJobs[index];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/jobs/${job.id}', extra: job),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: darkColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_outlined,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    job.location,
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: lightColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.work_outline,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: lightColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${job.applications.length} Applicant${job.applications.length == 1 ? '' : 's'}',
                                            style: TextStyle(
                                              color: darkColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                          onPressed: () {
                                            context.push('/create-job', extra: job).then((_) {
                                              // Refresh after edit
                                              if (context.mounted) context.read<JobProvider>().fetchMyJobs();
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                          onPressed: () => _confirmDelete(job.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-job').then((_) {
            if (context.mounted) context.read<JobProvider>().fetchMyJobs();
          });
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}