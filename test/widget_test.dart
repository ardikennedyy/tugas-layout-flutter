import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaspertemuan8/main.dart' show AdminListPage;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('displays the NIM Admin in the Admin list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminListPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Admin Praktikum'), findsOneWidget);
    expect(find.text('ID Admin untuk detail'), findsOneWidget);
  });
}
