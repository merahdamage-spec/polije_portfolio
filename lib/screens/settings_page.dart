import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../services/auth_service.dart';
import '../main.dart' show themeMode;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _resetData(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Portofolio?'),
        content: const Text('Seluruh data karya akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus Semua')),
        ],
      ),
    );
    if (ok != true) return;
    String msg = 'Semua data dihapus';
    try {
      await DbHelper.instance.deleteAll();
    } catch (e) {
      msg = 'Gagal: ${e.toString().replaceFirst('Exception: ', '')}';
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, size: 32),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk lagi untuk memakai aplikasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok != true) return;
    nav.popUntil((r) => r.isFirst); // tutup halaman Pengaturan
    await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        foregroundColor: Colors.white,
        flexibleSpace:
            Container(decoration: const BoxDecoration(gradient: kGradient)),
      ),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (_, mode, __) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Mode Gelap'),
              value: mode == ThemeMode.dark,
              onChanged: (v) async {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                final p = await SharedPreferences.getInstance();
                await p.setBool('dark', v);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Hapus Semua Portofolio'),
            subtitle: const Text('Mengosongkan database karya'),
            onTap: () => _resetData(context),
          ),
          const Divider(),
          ValueListenableBuilder<AuthUser?>(
            valueListenable: AuthService.instance.user,
            builder: (_, u, __) => ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(u?.name ?? '-'),
              subtitle: Text(u?.username ?? ''),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () => _logout(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('POLIJE Student Portfolio'),
            subtitle: Text('Versi 1.0.0 • Flutter + PHP + MySQL'),
          ),
        ],
      ),
    );
  }
}
