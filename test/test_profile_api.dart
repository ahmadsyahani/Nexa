import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://pens-api.senophyx.id',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  print("==================================================");
  print("🧪 TESTING PENS API: POST /api/profile");
  print("==================================================");

  // Masukkan email dan password NetID jika ingin test langsung lewat CLI:
  // dart test/test_profile_api.dart
  const testEmail = "isi_email_kamu@it.student.pens.ac.id";
  const testPassword = "isi_password_kamu";

  try {
    final response = await dio.post(
      '/api/profile',
      data: {
        'email': testEmail,
        'password': testPassword,
      },
    );

    print("✅ STATUS CODE: ${response.statusCode}");
    print("📦 RAW JSON DATA:");
    print(const JsonEncoder.withIndent('  ').convert(response.data));

    final data = response.data['data'];
    if (data != null) {
      print("\n📋 FIELD YANG DITAMPILKAN DI DIGITAL CARD:");
      print("  1. Nama         : ${data['nama']}");
      print("  2. NRP          : ${data['nrp']}");
      print("  3. Semester     : ${data['semester']}");
      print("  4. Tahun Aktif  : ${data['tahun_aktif']}");
      print("  5. Tahun Ajaran : ${data['tahun_ajaran']}");
      print("  6. Hak Akses    : ${data['hak_akses']}");
    }
  } catch (e) {
    if (e is DioException) {
      print("❌ DioException: ${e.response?.statusCode} - ${e.response?.data}");
    } else {
      print("❌ Error: $e");
    }
  }
}
