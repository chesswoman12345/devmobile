import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../widgets/app_drawer.dart';

class JobApplicationsScreen extends StatefulWidget {
  final int jobId;

  const JobApplicationsScreen({super.key, required this.jobId});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchApplications(jobId: widget.jobId);
    });
  }

  void _updateStatus(int appId, String status) async {
    try {
      await context.read<ApplicationProvider>().updateStatus(appId, status);
      // Refresh list
      if (mounted) context.read<ApplicationProvider>().fetchApplications(jobId: widget.jobId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final apps = provider.applications;

    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      drawer: const AppDrawer(),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return ExpansionTile(
                  title: Text(app.user?.name ?? 'Unknown User'),
                  subtitle: Text(app.user?.email ?? ''),
                  trailing: Text(app.status.toUpperCase()),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Cover Letter:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(app.coverLetter ?? 'No cover letter'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => _updateStatus(app.id, 'accepted'),
                                child: const Text('Accept'),
                              ),
                              ElevatedButton(
                                onPressed: () => _updateStatus(app.id, 'rejected'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }
}
