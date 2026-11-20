import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaspertemuan8/models/admin.dart';
import 'package:tugaspertemuan8/services/admin_service.dart';
import 'package:tugaspertemuan8/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Admin.fromJson converts all fields and supports string IDs', () {
    final admin = Admin.fromJson({
      'id': '871',
      'name': 'Admin Praktikum',
      'email': 'admin@example.com',
      'department': 'Teknologi Informasi',
    });

    expect(admin.id, 871);
    expect(admin.name, 'Admin Praktikum');
    expect(admin.department, 'Teknologi Informasi');
  });

  test('Admin service lists, retrieves, and deletes the NIM admin', () async {
    SharedPreferences.setMockInitialValues({});
    final admins = await AdminService.getAdmins();
    expect(admins.any((admin) => admin.id == AdminService.nimAdminId), isTrue);

    final admin = await AdminService.getAdmin(AdminService.nimAdminId);
    expect(admin.department, 'Teknologi Informasi');
    expect(await AdminService.deleteAdmin(admin.id), isTrue);
    expect(
      (await AdminService.getAdmins()).any((item) => item.id == admin.id),
      isFalse,
    );
    expect(await AdminService.deleteAdmin(admin.id), isFalse);
  });

  test('User POST assigns the NIM-derived ID', () async {
    SharedPreferences.setMockInitialValues({'users_json': jsonEncode([])});

    final user = await ApiService.createUser(
      'User Praktikum',
      'test@example.com',
    );

    expect(user['id'], ApiService.nimUserId);
    expect(user['name'], 'User Praktikum');
  });

  test('User PUT, PATCH, and DELETE update the selected User', () async {
    SharedPreferences.setMockInitialValues({
      'users_json': jsonEncode([
        {
          'id': 42,
          'name': 'Nama Awal',
          'email': 'awal@example.com',
          'address': {'city': 'Bandung'},
        },
      ]),
    });

    final updated = await ApiService.updateUser(
      42,
      'Nama PUT',
      'put@example.com',
    );
    expect(updated['name'], 'Nama PUT');
    expect(updated['email'], 'put@example.com');

    final patched = await ApiService.patchUser(
      42,
      '${updated['name']} - Flutter Developer',
    );
    expect(patched['name'], 'Nama PUT - Flutter Developer');

    expect(await ApiService.deleteUser(42), isTrue);
    await expectLater(ApiService.getUser(42), throwsException);
  });
}
