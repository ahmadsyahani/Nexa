import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EtholApiService {
  // --- SINGLETON PATTERN ---
  static final EtholApiService _instance = EtholApiService._internal();
  factory EtholApiService() => _instance;

  late final Dio _dio;

  // Constructor Internal
  EtholApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://pens-api.senophyx.id',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // --- STORAGE CACHE ---
  Map<String, dynamic>? _cacheProfile;
  Map<String, dynamic>? _cacheJadwal;
  Map<String, dynamic>? _cacheTugas;
  Map<String, dynamic>? _cacheNotif;

  // Helper body request
  Map<String, dynamic> _buildBody(String email, String password) {
    return {"email": email, "password": password};
  }

  // Helper to save to SharedPreferences
  Future<void> _saveToLocal(String key, String email, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${key}_$email', jsonEncode(data));
  }

  // Save offline password separately to allow offline login even after logout
  Future<void> _saveOfflinePassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_password_$email', password);
  }

  // Helper to get from SharedPreferences
  Future<dynamic> _getFromLocal(String key, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final offlinePassword = prefs.getString('offline_password_$email');
    
    // Only return offline data if credentials match the saved offline password
    if (offlinePassword != null && offlinePassword == password) {
      final dataString = prefs.getString('${key}_$email');
      if (dataString != null) {
        return jsonDecode(dataString);
      }
    }
    return null;
  }

  // 1. Fetch Profile
  Future<dynamic> getProfile(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    if (_cacheProfile != null && !refresh) return _cacheProfile;

    try {
      final response = await _dio.post(
        '/api/profile',
        data: _buildBody(email, password),
      );
      _cacheProfile = response.data;
      await _saveToLocal('offline_profile', email, response.data);
      await _saveOfflinePassword(email, password);
      return _cacheProfile;
    } on DioException catch (e) {
      final offlineData = await _getFromLocal('offline_profile', email, password);
      if (offlineData != null) {
        _cacheProfile = offlineData;
        return offlineData;
      }
      final String errorMsg =
          e.response?.data?['message'] ??
          'Periksa kembali email dan password Anda.';
      throw Exception(errorMsg);
    } catch (e) {
      final offlineData = await _getFromLocal('offline_profile', email, password);
      if (offlineData != null) {
        _cacheProfile = offlineData;
        return offlineData;
      }
      throw Exception('Terjadi kesalahan pada sistem.');
    }
  }

  // 2. Fetch Jadwal
  Future<dynamic> getJadwal(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    if (_cacheJadwal != null && !refresh) return _cacheJadwal;

    try {
      final response = await _dio.post(
        '/api/get-jadwal',
        data: _buildBody(email, password),
      );
      _cacheJadwal = response.data;
      await _saveToLocal('offline_jadwal', email, response.data);
      return _cacheJadwal;
    } on DioException catch (_) {
      final offlineData = await _getFromLocal('offline_jadwal', email, password);
      if (offlineData != null) {
        _cacheJadwal = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat jadwal kuliah.');
    } catch (_) {
      final offlineData = await _getFromLocal('offline_jadwal', email, password);
      if (offlineData != null) {
        _cacheJadwal = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat jadwal kuliah.');
    }
  }

  // 3. Fetch Tugas
  Future<dynamic> getTugas(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    if (_cacheTugas != null && !refresh) return _cacheTugas;

    try {
      final response = await _dio.post(
        '/api/get-tugas',
        data: _buildBody(email, password),
      );
      _cacheTugas = response.data;
      await _saveToLocal('offline_tugas', email, response.data);
      return _cacheTugas;
    } on DioException catch (_) {
      final offlineData = await _getFromLocal('offline_tugas', email, password);
      if (offlineData != null) {
        _cacheTugas = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat daftar tugas.');
    } catch (_) {
      final offlineData = await _getFromLocal('offline_tugas', email, password);
      if (offlineData != null) {
        _cacheTugas = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat daftar tugas.');
    }
  }

  // 4. Fetch Notifikasi
  Future<dynamic> getNotif(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    if (_cacheNotif != null && !refresh) return _cacheNotif;

    try {
      final response = await _dio.post(
        '/api/get-notif',
        data: _buildBody(email, password),
      );
      _cacheNotif = response.data;
      await _saveToLocal('offline_notif', email, response.data);
      return _cacheNotif;
    } on DioException catch (_) {
      final offlineData = await _getFromLocal('offline_notif', email, password);
      if (offlineData != null) {
        _cacheNotif = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat notifikasi.');
    } catch (_) {
      final offlineData = await _getFromLocal('offline_notif', email, password);
      if (offlineData != null) {
        _cacheNotif = offlineData;
        return offlineData;
      }
      throw Exception('Gagal memuat notifikasi.');
    }
  }

  // 5. Fetch Absen (Tanpa Cache)
  Future<dynamic> getAbsen(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/absen',
        data: _buildBody(email, password),
      );
      await _saveToLocal('offline_absen', email, response.data);
      return response.data;
    } on DioException catch (e) {
      final offlineData = await _getFromLocal('offline_absen', email, password);
      if (offlineData != null) return offlineData;

      if (e.response != null) return e.response!.data;
      throw Exception('Gagal memuat data absensi.');
    } catch (_) {
      final offlineData = await _getFromLocal('offline_absen', email, password);
      if (offlineData != null) return offlineData;

      throw Exception('Gagal memuat data absensi.');
    }
  }

  // Logout / Clear Cache (Only memory cache, keeping offline cache intact)
  Future<void> clearAllCache() async {
    _cacheProfile = null;
    _cacheJadwal = null;
    _cacheTugas = null;
    _cacheNotif = null;
  }
}
