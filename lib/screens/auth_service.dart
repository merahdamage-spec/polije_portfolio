import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class AuthUser {
  final String name, email, token;
  const AuthUser({required this.name, required this.email, required this.token});
}

/// Login / registrasi / logout melalui auth.php (MySQL tabel users).
/// user.value == null berarti belum login.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ValueNotifier<AuthUser?> user = ValueNotifier<AuthUser?>(null);
  static const _timeout = Duration(seconds: 10);

  /// Pulihkan sesi yang tersimpan di perangkat.
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final token = p.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      user.value = AuthUser(
        name: p.getString('auth_name') ?? '',
        email: p.getString('auth_email') ?? '',
        token: token,
      );
    }
  }

  Future<AuthUser> login(String email, String password) =>
      _auth('login', {'email': email, 'password': password});

  Future<AuthUser> register(String name, String email, String password) =>
      _auth('register', {'name': name, 'email': email, 'password': password});

  Future<AuthUser> _auth(String action, Map<String, String> body) async {
    http.Response r;
    try {
      r = await http
          .post(Uri.parse('$kBaseUrl/auth.php?action=$action'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(_timeout);
    } on http.ClientException {
      throw Exception('Tidak bisa terhubung ke server. Pastikan XAMPP (Apache & MySQL) menyala.');
    } on TimeoutException {
      throw Exception('Server tidak merespons. Coba lagi.');
    }

    Map<String, dynamic> res;
    try {
      res = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respons server tidak valid (HTTP ${r.statusCode})');
    }
    if (r.statusCode >= 400 || res['success'] == false) {
      throw Exception(res['message'] ?? 'Terjadi kesalahan (HTTP ${r.statusCode})');
    }

    final d = res['data'] as Map<String, dynamic>;
    final u = AuthUser(
        name: d['name'] as String, email: d['email'] as String, token: d['token'] as String);
    final p = await SharedPreferences.getInstance();
    await p.setString('auth_token', u.token);
    await p.setString('auth_name', u.name);
    await p.setString('auth_email', u.email);
    user.value = u; // main.dart otomatis berpindah ke halaman utama
    return u;
  }

  Future<void> logout() async {
    final token = user.value?.token;
    if (token != null) {
      try {
        await http
            .post(Uri.parse('$kBaseUrl/auth.php?action=logout'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'token': token}))
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // tetap logout di perangkat walau server tidak terjangkau
      }
    }
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('auth_name');
    await p.remove('auth_email');
    user.value = null;
  }
}
