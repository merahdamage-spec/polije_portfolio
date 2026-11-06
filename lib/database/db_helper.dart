import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/portfolio.dart';

/// Akses data ke MySQL melalui REST API PHP (backend/polije_api).
/// Nama method dipertahankan agar semua halaman tetap bisa dipakai.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  /// Dinotifikasi setiap ada perubahan data agar halaman lain refresh.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static const _timeout = Duration(seconds: 10);
  static const _headers = {'Content-Type': 'application/json'};

  Uri _uri([Map<String, String>? query]) =>
      Uri.parse('$kBaseUrl/portfolios.php').replace(queryParameters: query);

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

  Future<dynamic> _run(Future<http.Response> Function() request) async {
    try {
      return _handle(await request().timeout(_timeout));
    } on http.ClientException {
      throw Exception('Tidak bisa terhubung ke server. Pastikan XAMPP (Apache & MySQL) menyala.');
    }
  }

  // ===================== CRUD =====================

  /// CREATE
  Future<int> insert(Portfolio p) async {
    final data = await _run(
        () => http.post(_uri(), headers: _headers, body: jsonEncode(p.toMap())));
    changes.value++;
    return data as int;
  }

  /// READ (semua, dengan filter kategori & pencarian opsional)
  Future<List<Portfolio>> getAll({String? category, String? keyword}) async {
    final q = <String, String>{};
    if (category != null && category != 'Semua') q['category'] = category;
    if (keyword != null && keyword.trim().isNotEmpty) q['keyword'] = keyword.trim();
    final data = await _run(() => http.get(_uri(q.isEmpty ? null : q)));
    return (data as List)
        .map((e) => Portfolio.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// READ (satu data)
  Future<Portfolio?> getById(int id) async {
    try {
      final data = await _run(() => http.get(_uri({'id': '$id'})));
      return Portfolio.fromMap(Map<String, dynamic>.from(data));
    } on Exception catch (e) {
      if (e.toString().contains('tidak ditemukan')) return null;
      rethrow;
    }
  }

  /// UPDATE
  Future<int> update(Portfolio p) async {
    await _run(() => http.put(_uri({'id': '${p.id}'}),
        headers: _headers, body: jsonEncode(p.toMap())));
    changes.value++;
    return 1;
  }

  /// DELETE
  Future<int> delete(int id) async {
    await _run(() => http.delete(_uri({'id': '$id'})));
    changes.value++;
    return 1;
  }

  Future<void> deleteAll() async {
    await _run(() => http.delete(_uri({'all': '1'})));
    changes.value++;
  }
}
