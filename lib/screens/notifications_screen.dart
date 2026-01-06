import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    // Add the teal color constants
    const primaryColor = Color(0xFF00897B);
    const lightColor = Color(0xFFE0F2F1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: provider.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading notifications...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re all caught up!',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(16),
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
                    child: ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (ctx, i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 1,
                        color: Colors.grey[100],
                      ),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        
                        // Custom ListTile with enhanced design
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: notification.isRead ? Colors.white : lightColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: notification.isRead 
                                ? null 
                                : Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (!notification.isRead) {
                                  context.read<NotificationProvider>().markAsRead(notification.id);
                                }

                                // Redirection Logic
                                if (notification.data != null && notification.data!.containsKey('job_id')) {
                                  final jobId = notification.data!['job_id'];
                                  
                                  if (notification.type == 'application_received') {
                                     // Admin: Go to Job Applications
                                     context.push('/jobs/$jobId/applications');
                                  } else if (notification.type == 'status_change') {
                                     // Candidate: Go to My Applications with highlight
                                     if (notification.data!.containsKey('application_id')) {
                                       final appId = notification.data!['application_id'];
                                       context.push('/applications?id=$appId');
                                     } else {
                                       context.push('/applications');
                                     }
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: notification.isRead 
                                            ? Colors.grey[100] 
                                            : primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        notification.type == 'status_change'
                                            ? Icons.info_outline
                                            : Icons.mark_email_unread,
                                        color: notification.isRead 
                                            ? Colors.grey[600] 
                                            : primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.message,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: notification.isRead 
                                                  ? FontWeight.normal 
                                                  : FontWeight.w600,
                                              color: notification.isRead 
                                                  ? Colors.grey[800] 
                                                  : const Color(0xFF004D40),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_outlined,
                                                size: 12,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${notification.createdAt.day}/${notification.createdAt.month} ${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!notification.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
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
}