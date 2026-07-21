// This is a basic Flutter widget test for CleanStock.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_stock/main.dart';

void main() {
  testWidgets('CleanStock login screen load smoke test', (WidgetTester tester) async {
    // Set simulated screen size to a standard modern phone size
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    
    // Build our app and trigger a frame.
    // We pass idEmpleado as null to ensure it stays on the login page.
    await tester.pumpWidget(const MyApp(idEmpleado: null));

    // Verify that our login screen is loaded and shows CLEANSTOCK.
    expect(find.text('CLEANSTOCK'), findsOneWidget);
    expect(find.text('Inicio de sesión'), findsOneWidget);

    // Verify we have form fields for ID and Contraseña
    expect(find.text('ID empleado'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);

    // Reset views after test
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
