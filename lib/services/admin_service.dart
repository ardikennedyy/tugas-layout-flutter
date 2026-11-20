import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';

class AdminService {
  static const int nimAdminId = 871;
  static const String _storageKey = 'admins_json';

  static Future<List<Admin>> getAdmins() async {
    final data = await _readAdmins();
    return data.map(Admin.fromJson).toList();
  }

  static Future<Admin> getAdmin(int id) async {
    final data = await _readAdmins();
    final admin = data.where((item) => item['id'] == id);
    if (admin.isEmpty) {
      throw Exception('Data Admin dengan ID $id tidak ditemukan');
    }
    return Admin.fromJson(admin.first);
  }

  static Future<bool> deleteAdmin(int id) async {
    final data = await _readAdmins();
    final index = data.indexWhere((item) => item['id'] == id);
    if (index == -1) return false;

    data.removeAt(index);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(data));
    return true;
  }

  static Future<List<Map<String, dynamic>>> _readAdmins() async {
    final preferences = await SharedPreferences.getInstance();
    final storedJson = preferences.getString(_storageKey);
    if (storedJson != null) {
      final decoded = jsonDecode(storedJson);
      if (decoded is! List) {
        throw const FormatException('Format data Admin harus berupa daftar');
      }
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    final initialData = [
      {
        'id': nimAdminId,
        'name': 'Admin Praktikum',
        'email': 'admin.praktikum@example.com',
        'department': 'Teknologi Informasi',
      },
      {
        'id': 2,
        'name': 'Admin Akademik',
        'email': 'akademik@example.com',
        'department': 'Akademik',
      },
      {
        'id': 3,
        'name': 'Admin Keuangan',
        'email': 'keuangan@example.com',
        'department': 'Keuangan',
      },
    ];
    await preferences.setString(_storageKey, jsonEncode(initialData));
    return initialData;
  }
}
