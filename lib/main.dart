import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config/base_url.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/auth_gate.dart';
import 'screens/pengguna/Pembayaran/struk_page.dart';
import 'screens/pengguna/home/home_page.dart';
import 'utils/ui_helper.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;




final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthProvider();
  await auth.loadFromStorage();   // ← WAJIB!

  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('id', timeago.IdShortMessages());



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth),
      ],
      child: MyApp(),
    ),
  );
}




/// 🔗 Listener deep link seperti: 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

        // Saat loading: tampilkan splash saja
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen(); // atau loading screen
        }

        // Jika sudah selesai:
        return const AuthGate();   // biarkan AuthGate yang menentukan login
      },
    );
  }
}

