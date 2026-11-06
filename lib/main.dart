import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'screens/login_page.dart'; // BARU
import 'screens/main_shell.dart';
import 'services/auth_service.dart'; // BARU
import 'services/profile_photo_store.dart';
import 'services/profile_store.dart';

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProfileStore.instance.load();
  await AuthService.instance.load(); // BARU: pulihkan sesi login
  ProfilePhotoStore.instance.load(); // tanpa await agar start tidak tertunda
  final prefs = await SharedPreferences.getInstance();
  themeMode.value =
      (prefs.getBool('dark') ?? false) ? ThemeMode.dark : ThemeMode.light;
  runApp(const PolijeApp());
}

class PolijeApp extends StatelessWidget {
  const PolijeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'POLIJE Student Portfolio',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: kPrimary, brightness: Brightness.dark),
        ),
        // BARU: belum login -> LoginPage, sudah login -> MainShell
        home: ValueListenableBuilder<AuthUser?>(
          valueListenable: AuthService.instance.user,
          builder: (_, u, __) =>
              u == null ? const LoginPage() : const MainShell(),
        ),
      ),
    );
  }
}
