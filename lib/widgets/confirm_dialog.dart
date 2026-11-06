import 'package:flutter/material.dart';

/// Dialog konfirmasi hapus. Mengembalikan true jika pengguna menekan "Hapus".
Future<bool> confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
      title: const Text('Hapus Portofolio?'),
      content: Text('"$title" akan dihapus permanen dan tidak bisa dikembalikan.'),
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
  return result ?? false;
}
