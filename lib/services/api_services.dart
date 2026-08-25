import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtholApiService {
  // --- SINGLETON PATTERN ---
  static final EtholApiService _instance = EtholApiService._internal();
  factory EtholApiService() => _instance;

  late final Dio _dio;

  // --- RATE LIMITING & THROTTLING CONFIG ---
  // Minimal jeda waktu antar request paksa (refresh: true) ke server per-endpoint
  static const Duration _minRefreshCooldown = Duration(seconds: 15);

  // Pencatat waktu fetch terakhir per cache key
  final Map<String, DateTime> _lastFetchTimes = {};

  // In-flight request deduplication map
  final Map<String, Future<dynamic>> _inFlightRequests = {};

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

    // --- INTERCEPTOR (Rate Limit 429 & Error Logger) ---
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 429) {
            debugPrint(
              "⚠️ [EtholApiService] 429 Too Many Requests detected on ${e.requestOptions.path}. Throttling active.",
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  // --- STORAGE CACHE ---
  Map<String, dynamic>? _cacheProfile;
  Map<String, dynamic>? _cacheJadwal;
  Map<String, dynamic>? _cacheTugas;
  Map<String, dynamic>? _cacheNotif;
  Map<String, dynamic>? _cachePresensiRekap;

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

  // Helper to check if cooldown is currently active
  bool _isCooldownActive(String key) {
    final lastTime = _lastFetchTimes[key];
    if (lastTime == null) return false;
    return DateTime.now().difference(lastTime) < _minRefreshCooldown;
  }

  // 1. Fetch Profile
  Future<dynamic> getProfile(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    final cacheKey = 'profile_$email';

    // 1. Return in-memory cache if available and not explicitly refreshing
    if (_cacheProfile != null && !refresh) return _cacheProfile;

    // 2. Client-side Rate Limit Throttling: If refreshed too soon, reuse existing cache
    if (refresh && _cacheProfile != null && _isCooldownActive(cacheKey)) {
      debugPrint("🛡️ [RateLimiter] getProfile cooldown active. Returning cached data.");
      return _cacheProfile;
    }

    // 3. Request Deduplication: Await in-flight request if already running
    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await _dio.post(
          '/api/profile',
          data: _buildBody(email, password),
        );
        _cacheProfile = response.data;
        _lastFetchTimes[cacheKey] = DateTime.now();
        debugPrint("==================================================");
        debugPrint("🚀 [API /api/profile RESPONSE]:");
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
        debugPrint("==================================================");
        await _saveToLocal('offline_profile', email, response.data);
        await _saveOfflinePassword(email, password);
        return _cacheProfile;
      } on DioException catch (e) {
        final offlineData = await _getFromLocal('offline_profile', email, password);
        if (offlineData != null) {
          _cacheProfile = offlineData;
          return offlineData;
        }
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk (Too Many Requests). Silakan coba lagi beberapa saat.');
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
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // 2. Fetch Jadwal
  Future<dynamic> getJadwal(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    final cacheKey = 'jadwal_$email';

    if (_cacheJadwal != null && !refresh) return _cacheJadwal;

    if (refresh && _cacheJadwal != null && _isCooldownActive(cacheKey)) {
      debugPrint("🛡️ [RateLimiter] getJadwal cooldown active. Returning cached data.");
      return _cacheJadwal;
    }

    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await _dio.post(
          '/api/get-jadwal',
          data: _buildBody(email, password),
        );
        _cacheJadwal = response.data;
        _lastFetchTimes[cacheKey] = DateTime.now();
        await _saveToLocal('offline_jadwal', email, response.data);
        return _cacheJadwal;
      } on DioException catch (e) {
        final offlineData = await _getFromLocal('offline_jadwal', email, password);
        if (offlineData != null) {
          _cacheJadwal = offlineData;
          return offlineData;
        }
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk. Silakan coba lagi sebentar lagi.');
        }
        throw Exception('Gagal memuat jadwal kuliah.');
      } catch (_) {
        final offlineData = await _getFromLocal('offline_jadwal', email, password);
        if (offlineData != null) {
          _cacheJadwal = offlineData;
          return offlineData;
        }
        throw Exception('Gagal memuat jadwal kuliah.');
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // 3. Fetch Tugas
  Future<dynamic> getTugas(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    final cacheKey = 'tugas_$email';

    if (_cacheTugas != null && !refresh) return _cacheTugas;

    if (refresh && _cacheTugas != null && _isCooldownActive(cacheKey)) {
      debugPrint("🛡️ [RateLimiter] getTugas cooldown active. Returning cached data.");
      return _cacheTugas;
    }

    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await _dio.post(
          '/api/get-tugas',
          data: _buildBody(email, password),
        );
        _cacheTugas = response.data;
        _lastFetchTimes[cacheKey] = DateTime.now();
        await _saveToLocal('offline_tugas', email, response.data);
        return _cacheTugas;
      } on DioException catch (e) {
        final offlineData = await _getFromLocal('offline_tugas', email, password);
        if (offlineData != null) {
          _cacheTugas = offlineData;
          return offlineData;
        }
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk. Silakan coba lagi sebentar lagi.');
        }
        throw Exception('Gagal memuat daftar tugas.');
      } catch (_) {
        final offlineData = await _getFromLocal('offline_tugas', email, password);
        if (offlineData != null) {
          _cacheTugas = offlineData;
          return offlineData;
        }
        throw Exception('Gagal memuat daftar tugas.');
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // 4. Fetch Notifikasi
  Future<dynamic> getNotif(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    final cacheKey = 'notif_$email';

    if (_cacheNotif != null && !refresh) return _cacheNotif;

    if (refresh && _cacheNotif != null && _isCooldownActive(cacheKey)) {
      debugPrint("🛡️ [RateLimiter] getNotif cooldown active. Returning cached data.");
      return _cacheNotif;
    }

    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await _dio.post(
          '/api/get-notif',
          data: _buildBody(email, password),
        );
        _cacheNotif = response.data;
        _lastFetchTimes[cacheKey] = DateTime.now();
        await _saveToLocal('offline_notif', email, response.data);
        return _cacheNotif;
      } on DioException catch (e) {
        final offlineData = await _getFromLocal('offline_notif', email, password);
        if (offlineData != null) {
          _cacheNotif = offlineData;
          return offlineData;
        }
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk. Silakan coba lagi sebentar lagi.');
        }
        throw Exception('Gagal memuat notifikasi.');
      } catch (_) {
        final offlineData = await _getFromLocal('offline_notif', email, password);
        if (offlineData != null) {
          _cacheNotif = offlineData;
          return offlineData;
        }
        throw Exception('Gagal memuat notifikasi.');
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // 5. Fetch Absen (Tanpa Cache, tapi dengan Cooldown 5 detik untuk mencegah double submit)
  Future<dynamic> getAbsen(String email, String password) async {
    final cacheKey = 'absen_$email';

    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
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
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk. Silakan coba presensi kembali.');
        }
        throw Exception('Gagal memuat data absensi.');
      } catch (_) {
        final offlineData = await _getFromLocal('offline_absen', email, password);
        if (offlineData != null) return offlineData;

        throw Exception('Gagal memuat data absensi.');
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // 6. Fetch Rekap Presensi Online-MIS (16 Minggu)
  Future<dynamic> getPresensiRekap(
    String email,
    String password, {
    bool refresh = false,
  }) async {
    final cacheKey = 'presensi_rekap_$email';

    if (_cachePresensiRekap != null && !refresh) return _cachePresensiRekap;

    if (refresh && _cachePresensiRekap != null && _isCooldownActive(cacheKey)) {
      debugPrint("🛡️ [RateLimiter] getPresensiRekap cooldown active. Returning cached data.");
      return _cachePresensiRekap;
    }

    if (_inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await _dio.post(
          '/api/presensi',
          data: _buildBody(email, password),
        );
        _cachePresensiRekap = response.data;
        _lastFetchTimes[cacheKey] = DateTime.now();
        await _saveToLocal('offline_presensi_rekap', email, response.data);
        return _cachePresensiRekap;
      } on DioException catch (e) {
        final offlineData = await _getFromLocal(
          'offline_presensi_rekap',
          email,
          password,
        );
        if (offlineData != null) {
          _cachePresensiRekap = offlineData;
          return offlineData;
        }
        if (e.response?.statusCode == 429) {
          throw Exception('Server sedang sibuk. Silakan coba lagi beberapa saat.');
        }
        throw Exception('Gagal memuat rekap presensi Online-MIS.');
      } catch (_) {
        final offlineData = await _getFromLocal(
          'offline_presensi_rekap',
          email,
          password,
        );
        if (offlineData != null) {
          _cachePresensiRekap = offlineData;
          return offlineData;
        }
        throw Exception('Gagal memuat rekap presensi Online-MIS.');
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return await future;
  }

  // Logout / Clear Cache (Only memory cache, keeping offline cache intact)
  Future<void> clearAllCache() async {
    _cacheProfile = null;
    _cacheJadwal = null;
    _cacheTugas = null;
    _cacheNotif = null;
    _cachePresensiRekap = null;
    _lastFetchTimes.clear();
    _inFlightRequests.clear();
  }
}
