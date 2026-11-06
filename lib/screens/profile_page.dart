import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../services/profile_photo_store.dart';
import '../services/profile_store.dart';
import '../widgets/gradient_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Profile>(
      valueListenable: ProfileStore.instance.profile,
      builder: (context, p, _) {
        final initials = p.name.trim().isEmpty
            ? '?'
            : p.name.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase();
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: 'Profil Saya',
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'Edit profil',
                onPressed: () => _showEdit(context, p),
              ),
              bottom: Row(
                children: [
                  _avatar(context, initials),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('NIM ${p.nim}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _info(Icons.school, 'Program Studi', p.prodi),
                  _info(Icons.email, 'Email', p.email),
                  _info(Icons.info_outline, 'Tentang Saya', p.bio),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.bolt, color: kAccent),
                            SizedBox(width: 8),
                            Text('Keahlian',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: p.skills
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .map((s) => Chip(label: Text(s)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: DbHelper.instance.getAll(),
                    builder: (_, snap) => _info(Icons.folder, 'Total Karya',
                        '${snap.data?.length ?? 0} portofolio'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= FOTO PROFIL (CRUD) =================

  /// Avatar: tampilkan foto (READ) atau inisial; ketuk untuk membuka menu.
  Widget _avatar(BuildContext context, String initials) {
    return ValueListenableBuilder<String?>(
      valueListenable: ProfilePhotoStore.instance.photo,
      builder: (ctx, b64, _) {
        ImageProvider? img;
        if (b64 != null && b64.isNotEmpty) {
          try {
            img = MemoryImage(base64Decode(b64));
          } catch (_) {}
        }
        return GestureDetector(
          onTap: () => _showPhotoMenu(context, img != null),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                backgroundImage: img,
                child: img == null
                    ? Text(initials,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kPrimary))
                    : null,
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: kAccent,
                  child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoMenu(BuildContext context, bool hasPhoto) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Lihat foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewPhoto(context);
                },
              ),
            ListTile(
              leading: Icon(hasPhoto ? Icons.edit : Icons.add_a_photo),
              title: Text(hasPhoto ? 'Ganti foto' : 'Tambah foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSave(context);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePhoto(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// CREATE (belum ada foto) / UPDATE (ganti foto)
  Future<void> _pickAndSave(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final hadPhoto = ProfilePhotoStore.instance.photo.value != null;
    try {
      final x = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 600, imageQuality: 75);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      await ProfilePhotoStore.instance.save(base64Encode(bytes));
      messenger.showSnackBar(SnackBar(
          content: Text(hadPhoto
              ? 'Foto profil berhasil diperbarui'
              : 'Foto profil berhasil ditambahkan')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('Gagal: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  /// READ (pratinjau besar, bisa di-zoom)
  void _viewPhoto(BuildContext context) {
    final b64 = ProfilePhotoStore.instance.photo.value;
    if (b64 == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(base64Decode(b64), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filled(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DELETE (dengan dialog konfirmasi)
  Future<void> _deletePhoto(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 36),
        title: const Text('Hapus Foto Profil?'),
        content: const Text('Foto akan dihapus dan diganti avatar inisial.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ProfilePhotoStore.instance.remove();
      messenger.showSnackBar(
          const SnackBar(content: Text('Foto profil dihapus')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  Widget _info(IconData icon, String label, String value) => Card(
        child: ListTile(
          leading: Icon(icon, color: kPrimary),
          title: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(value,
              style: const TextStyle(fontSize: 15, color: null, height: 1.3)),
        ),
      );

  void _showEdit(BuildContext context, Profile p) {
    final messenger = ScaffoldMessenger.of(context);
    final name = TextEditingController(text: p.name);
    final nim = TextEditingController(text: p.nim);
    final prodi = TextEditingController(text: p.prodi);
    final email = TextEditingController(text: p.email);
    final bio = TextEditingController(text: p.bio);
    final skills = TextEditingController(text: p.skills);
    final prodiDesc = TextEditingController(text: p.prodiDesc);
    final key = GlobalKey<FormState>();

    // Foto dipilih dulu di sini (pratinjau), baru dikirim ke MySQL saat Simpan.
    String? pendingPhoto = ProfilePhotoStore.instance.photo.value;
    bool photoChanged = false;
    bool saving = false;

    Widget field(String label, TextEditingController c,
            {int lines = 1, bool required = true}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: c,
            maxLines: lines,
            decoration: InputDecoration(
                labelText: label, border: const OutlineInputBorder()),
            validator: (v) => required && (v == null || v.trim().isEmpty)
                ? '$label wajib diisi'
                : null,
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          ImageProvider? img;
          final cur = pendingPhoto;
          if (cur != null && cur.isNotEmpty) {
            try {
              img = MemoryImage(base64Decode(cur));
            } catch (_) {}
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Edit Profil',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    // ---------- Foto profil ----------
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: kPrimary.withOpacity(0.12),
                      backgroundImage: img,
                      child: img == null
                          ? const Icon(Icons.person, size: 48, color: kPrimary)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(img == null
                              ? Icons.add_a_photo
                              : Icons.edit),
                          label:
                              Text(img == null ? 'Tambah foto' : 'Ganti foto'),
                          onPressed: () async {
                            try {
                              final x = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 600,
                                  imageQuality: 75);
                              if (x == null) return;
                              final bytes = await x.readAsBytes();
                              setSheet(() {
                                pendingPhoto = base64Encode(bytes);
                                photoChanged = true;
                              });
                            } catch (e) {
                              messenger.showSnackBar(SnackBar(
                                  content: Text('Gagal memilih foto: $e')));
                            }
                          },
                        ),
                        if (img != null)
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Hapus foto',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () => setSheet(() {
                              pendingPhoto = null;
                              photoChanged = true;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ---------- Data profil ----------
                    field('Nama', name),
                    field('NIM', nim),
                    field('Program Studi', prodi),
                    field('Email', email),
                    field('Tentang Saya', bio, lines: 3),
                    field('Keahlian (pisahkan dengan koma)', skills),
                    field('Deskripsi Program Studi', prodiDesc, lines: 3),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: const Text('Simpan'),
                        onPressed: saving
                            ? null
                            : () async {
                                if (!key.currentState!.validate()) return;
                                setSheet(() => saving = true);

                                await ProfileStore.instance.save(Profile(
                                  name: name.text.trim(),
                                  nim: nim.text.trim(),
                                  prodi: prodi.text.trim(),
                                  email: email.text.trim(),
                                  bio: bio.text.trim(),
                                  skills: skills.text.trim(),
                                  prodiDesc: prodiDesc.text.trim(),
                                ));

                                String? err;
                                if (photoChanged) {
                                  try {
                                    final photo = pendingPhoto;
                                    if (photo == null) {
                                      await ProfilePhotoStore.instance.remove();
                                    } else {
                                      await ProfilePhotoStore.instance
                                          .save(photo);
                                    }
                                  } catch (e) {
                                    err = e
                                        .toString()
                                        .replaceFirst('Exception: ', '');
                                  }
                                }

                                if (ctx.mounted) Navigator.pop(ctx);
                                messenger.showSnackBar(SnackBar(
                                    content: Text(err == null
                                        ? 'Profil berhasil disimpan'
                                        : 'Profil tersimpan, tapi foto gagal: $err')));
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
