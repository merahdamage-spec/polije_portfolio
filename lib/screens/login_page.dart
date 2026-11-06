import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/auth_service.dart';
import '../services/profile_store.dart';

/// Halaman Masuk / Daftar (satu halaman, bisa berganti mode).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController(); // GANTI: sebelumnya _email
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _hide = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose(); // GANTI
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // GANTI: memakai username (huruf kecil), bukan email
      final u = _register
          ? await AuthService.instance.register(_name.text.trim(),
              _username.text.trim().toLowerCase(), _pass.text)
          : await AuthService.instance
              .login(_username.text.trim().toLowerCase(), _pass.text);
      await _syncProfile(u);
      // setelah berhasil, main.dart otomatis menampilkan halaman utama
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Isi nama profil dari akun jika profil masih bawaan.
  Future<void> _syncProfile(AuthUser u) async {
    final p = ProfileStore.instance.profile.value;
    const d = Profile.empty;
    await ProfileStore.instance.save(Profile(
      name: p.name == d.name ? u.name : p.name,
      nim: p.nim,
      prodi: p.prodi,
      email: p.email, // GANTI: akun tidak punya email lagi
      bio: p.bio,
      skills: p.skills,
      prodiDesc: p.prodiDesc,
    ));
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- Header gradient ----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 40, 24, 40),
              decoration: const BoxDecoration(
                gradient: kGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.school, size: 44, color: kPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text('POLIJE Student Portofolio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_register ? 'Buat akun baru' : 'Masuk untuk melanjutkan',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            // ---------- Form ----------
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_register) ...[
                          TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration:
                                _dec('Nama Lengkap', Icons.person_outline),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Nama wajib diisi';
                              if (v.trim().length < 3)
                                return 'Minimal 3 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        // GANTI: kolom Email -> kolom Username
                        TextFormField(
                          controller: _username,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: _dec('Username', Icons.alternate_email),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Username wajib diisi';
                            if (_register) {
                              if (s.length < 3) return 'Minimal 3 karakter';
                              if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(s)) {
                                return 'Hanya huruf, angka, titik, dan garis bawah';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: _hide,
                          textInputAction: _register
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onFieldSubmitted: (_) => _register ? null : _submit(),
                          decoration: _dec('Password', Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(_hide
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(() => _hide = !_hide),
                              )),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password wajib diisi';
                            if (_register && v.length < 6)
                              return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        if (_register) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirm,
                            obscureText: _hide,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration:
                                _dec('Konfirmasi Password', Icons.lock_reset),
                            validator: (v) =>
                                v != _pass.text ? 'Password tidak sama' : null,
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: Colors.red))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Icon(
                                    _register ? Icons.person_add : Icons.login),
                            label: Text(_register ? 'Daftar' : 'Masuk'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() {
                                    _register = !_register;
                                    _error = null;
                                    _formKey.currentState?.reset();
                                  }),
                          child: Text(_register
                              ? 'Sudah punya akun? Masuk'
                              : 'Belum punya akun? Daftar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
