import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/routes/app_router.dart';
import 'core/services/location_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/api/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/features/auth/screens/login_screen.dart';
import 'presentation/features/auth/viewmodels/auth_viewmodel.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showRemoteNotification(message);
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Future.wait([
      init(),
      NotificationService.initialize(),
      LocationSyncService.instance.initialize(),
    ]);
    FirebaseMessaging.onMessage.listen(
      NotificationService.showRemoteNotification,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      NotificationService.handleRemoteNotificationTap,
    );
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      final context = AppRouter.navigatorKey.currentContext;
      context?.read<AuthViewModel>().syncDeviceToken();
    });
  } catch (error, stackTrace) {
    debugPrint('Optional service initialization failed: $error\n$stackTrace');
  }

  final apiClient = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository(apiClient)),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const VatandoshlarApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

class VatandoshlarApp extends StatefulWidget {
  const VatandoshlarApp({super.key});

  @override
  State<VatandoshlarApp> createState() => _VatandoshlarAppState();
}

class _VatandoshlarAppState extends State<VatandoshlarApp>
    with WidgetsBindingObserver {
  bool? _lastAuthenticatedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LocationSyncService.instance.handleAppLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final authViewModel = context.watch<AuthViewModel>();
    final isAuthenticated = authViewModel.status == AuthStatus.authenticated;

    if (_lastAuthenticatedState != isAuthenticated) {
      _lastAuthenticatedState = isAuthenticated;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LocationSyncService.instance.updateTrackingState(
          isAuthenticated: isAuthenticated,
        );
        if (isAuthenticated) {
          NotificationService.requestPermissions();
          authViewModel.syncDeviceToken();
        }
      });
    }

    return MaterialApp(
      title: 'Vatandoshlar',
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('uz'),
        Locale('ru'),
        Locale('ko'),
        Locale('tr'),
        Locale('ar'),
        Locale('de'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildInitialScreen(authViewModel),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }

  Widget _buildInitialScreen(AuthViewModel authViewModel) {
    if (authViewModel.status == AuthStatus.initial ||
        authViewModel.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const LoginScreen();
  }
}
