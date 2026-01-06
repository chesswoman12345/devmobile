import 'package:flutter/material.dart';
import '../models/job_post.dart';
import '../services/api_service.dart';

class JobProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<JobPost> _jobs = [];
  bool _isLoading = false;

  List<JobPost> get jobs => _jobs;
  bool get isLoading => _isLoading;

  Future<void> fetchJobs({
    String? title,
    String? location,
    double? salaryMin,
    String? requirements,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (location != null && location.isNotEmpty) queryParams['location'] = location;
      if (salaryMin != null) queryParams['salary_min'] = salaryMin;
      if (requirements != null && requirements.isNotEmpty) queryParams['requirements'] = requirements;

      final response = await _apiService.dio.get('/jobs', queryParameters: queryParams);
      final data = response.data as List;
      _jobs = data.map((json) => JobPost.fromJson(json)).toList();
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJob(Map<String, dynamic> jobData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.post('/jobs', data: jobData);
      await fetchJobs(); // Refresh public list
      await fetchMyJobs(); // Refresh my list
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJob(int id, Map<String, dynamic> jobData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.put('/jobs/$id', data: jobData);
      await fetchJobs();
      await fetchMyJobs();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJob(int id) async {
    try {
      await _apiService.dio.delete('/jobs/$id');
      _jobs.removeWhere((j) => j.id == id);
      await fetchMyJobs();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<JobPost> _myJobs = [];
  List<JobPost> get myJobs => _myJobs;

  Future<void> fetchMyJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/jobs', queryParameters: {'my_jobs': 'true'});
      final data = response.data as List;
      _myJobs = data.map((json) => JobPost.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
