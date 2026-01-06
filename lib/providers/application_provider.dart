import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Application> _applications = [];
  bool _isLoading = false;

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;

  Future<void> fetchApplications({int? jobId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {};
      if (jobId != null) queryParams['job_post_id'] = jobId;

      final response = await _apiService.dio.get('/applications', queryParameters: queryParams);
      final data = response.data as List;
      _applications = data.map((json) => Application.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyJob(int jobId, String coverLetter) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.post('/applications', data: {
        'job_post_id': jobId,
        'cover_letter': coverLetter,
      });
      // await fetchApplications(); // Refresh my applications if needed
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(int applicationId, String status) async {
    try {
      await _apiService.dio.patch('/applications/$applicationId/status', data: {
        'status': status,
      });
      // Optimistic update or refresh
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        // Refresh whole list ideally or update local logic (too complex for immutable list update here, just refresh)
        // For simplicity:
        // _applications[index] = ... 
      }
    } catch (e) {
      rethrow;
    }
  }
}
