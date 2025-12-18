import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';

import 'config/base_url.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/auth_gate.dart';
import 'screens/pengguna/Pembayaran/struk_page.dart';
import 'screens/pengguna/home/home_page.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthProvider();
  await auth.loadFromStorage();   // ← WAJIB!
  

  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('id', timeago.IdShortMessages());

  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;

  late AppLinks _appLinks;


  @override
  void initState() {
    super.initState();
  }

  /// ==============================
  /// 🔗 LISTENER UNTUK DEEP LINK
  /// ==============================


  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// ==============================
  /// 🧱 BUILD APP
  /// ==============================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/halaman_struk': (_) => const StrukPage(
              kodePemesanan: 'default',
              namaLayanan: 'default',
              alamat: 'default',
              tanggal: 'default',
              namaTeknisi: 'default',
              harga: 0,
            ),
        '/dashboard': (_) => const HomePage(),
      },
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});
  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  late Future<bool> loginFuture;

  @override
  void initState() {
    super.initState();
    loginFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    print("===== CHECK TOKEN (Splash) =====");
    print("Token from SecureStorage: $token");
    print("================================");

    await Future.delayed(const Duration(seconds: 2));
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: loginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }
        return const AuthGate();
      },
    );
  }
}
