import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/notifications');
      final data = response.data as List;
      _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      // Handle error cleanly
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.dio.post('/notifications/$id/read');
      // Update locally
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        // Create new object with readAt set to now (approx)
        final old = _notifications[index];
        _notifications[index] = AppNotification(
          id: old.id,
          message: old.message,
          type: old.type,
          createdAt: old.createdAt,
          readAt: DateTime.now(),
          data: old.data,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }
}
