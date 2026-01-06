import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../widgets/app_drawer.dart';

class MyApplicationsScreen extends StatefulWidget {
  final int? highlightId;
  const MyApplicationsScreen({super.key, this.highlightId});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchApplications();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'refused':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final applications = provider.applications;

    // Add teal colors
    const primaryColor = Color(0xFF00897B);
    const lightColor = Color(0xFFE0F2F1);
    const darkColor = Color(0xFF004D40);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
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
                      'Loading applications...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : applications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 80,
                          color: lightColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No applications yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Apply to jobs to see them here',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ApplicationProvider>().fetchApplications();
                    },
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final app = applications[index];
                        final dateStr = DateFormat('yyyy-MM-dd').format(app.createdAt);
                        final isHighlighted = widget.highlightId != null && app.id == widget.highlightId;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isHighlighted ? lightColor : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isHighlighted 
                                ? Border.all(color: primaryColor, width: 2)
                                : Border.all(color: Colors.grey[100]!, width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // You could add navigation to application details here
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status Icon
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(app.status).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.work_outline,
                                        color: _getStatusColor(app.status),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Application Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.jobPost?.title ?? 'Unknown Job',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: darkColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Applied date
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Applied: $dateStr',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          // Status Chip
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(app.status).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(app.status),
                                                  size: 12,
                                                  color: _getStatusColor(app.status),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  app.status.toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getStatusColor(app.status),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Highlight indicator
                                    if (isHighlighted)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
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
    );
  }

  // Helper method for status icons
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
      case 'refused':
        return Icons.cancel_outlined;
      case 'pending':
        return Icons.access_time_outlined;
      default:
        return Icons.help_outline;
    }
  }
}