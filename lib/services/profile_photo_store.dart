import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/// CRUD foto profil ke MySQL lewat API (profile_photo.php).
/// photo.value berisi string base64, atau null jika belum ada foto.
class ProfilePhotoStore {
  ProfilePhotoStore._();
  static final ProfilePhotoStore instance = ProfilePhotoStore._();

  final ValueNotifier<String?> photo = ValueNotifier<String?>(null);

  static const _timeout = Duration(seconds: 10);
  Uri get _uri => Uri.parse('$kBaseUrl/profile_photo.php');

  dynamic _handle(http.Response r) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respons server tidak valid (HTTP ${r.statusCode})');
    }
    if (r.statusCode >= 400 || body['success'] == false) {
      throw Exception(body['message'] ?? 'Terjadi kesalahan (HTTP ${r.statusCode})');
    }
    return body['data'];
  }

  Future<dynamic> _run(Future<http.Response> Function() req) async {
    try {
      return _handle(await req().timeout(_timeout));
    } on http.ClientException {
      throw Exception('Tidak bisa terhubung ke server. Pastikan XAMPP menyala.');
    }
  }

  /// READ
  Future<void> load() async {
    try {
      final data = await _run(() => http.get(_uri));
      photo.value = data == null ? null : data['image'] as String?;
    } catch (_) {
      // server belum menyala -> tampilkan avatar inisial
    }
  }

  /// CREATE / UPDATE
  Future<void> save(String base64Image) async {
    await _run(() => http.put(_uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image})));
    photo.value = base64Image;
  }

  /// DELETE
  Future<void> remove() async {
    await _run(() => http.delete(_uri));
    photo.value = null;
  }
}
