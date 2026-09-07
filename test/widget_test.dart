import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vatandoshlar/core/localization/locale_provider.dart';
import 'package:vatandoshlar/data/api/api_client.dart';
import 'package:vatandoshlar/data/repositories/auth_repository.dart';
import 'package:vatandoshlar/presentation/features/auth/screens/login_screen.dart';
import 'package:vatandoshlar/presentation/features/auth/viewmodels/auth_viewmodel.dart';

void main() {
  testWidgets('login shell is the only initial feature screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(AuthRepository(ApiClient())),
          ),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Xush kelibsiz!'), findsOneWidget);
  });
}
