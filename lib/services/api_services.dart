import 'package:dio/dio.dart';

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
      return _cacheProfile;
    } on DioException catch (e) {
      final String errorMsg =
          e.response?.data?['message'] ??
          'Periksa kembali email dan password Anda.';
      throw Exception(errorMsg);
    } catch (e) {
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
      return _cacheJadwal;
    } on DioException catch (_) {
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
      return _cacheTugas;
    } on DioException catch (_) {
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
      return _cacheNotif;
    } on DioException catch (_) {
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
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      throw Exception('Gagal memuat data absensi.');
    }
  }

  // Logout / Clear Cache
  void clearAllCache() {
    _cacheProfile = null;
    _cacheJadwal = null;
    _cacheTugas = null;
    _cacheNotif = null;
  }
}
