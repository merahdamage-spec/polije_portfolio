import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/portfolio.dart';

/// Gambar karya (disimpan sebagai base64); jika kosong -> placeholder icon.
class PortfolioImage extends StatelessWidget {
  final String? path; // berisi string base64
  final double? width;
  final double? height;
  const PortfolioImage({super.key, this.path, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(gradient: kGradient),
      child: const Icon(Icons.image_outlined, color: Colors.white70, size: 36),
    );
    if (path == null || path!.isEmpty) return placeholder;
    Uint8List bytes;
    try {
      bytes = base64Decode(path!);
    } catch (_) {
      return placeholder;
    }
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class PortfolioCard extends StatelessWidget {
  final Portfolio item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PortfolioCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            PortfolioImage(path: item.imagePath, width: 100, height: double.infinity),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        if (onEdit != null || onDelete != null)
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (v) =>
                                v == 'edit' ? onEdit?.call() : onDelete?.call(),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                      contentPadding: EdgeInsets.zero)),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                      leading: Icon(Icons.delete,
                                          color: Colors.red),
                                      title: Text('Hapus'),
                                      contentPadding: EdgeInsets.zero)),
                            ],
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        _chip(item.category, Icons.folder_outlined),
                        _chip(item.technology, Icons.code),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) => Chip(
        avatar: Icon(icon, size: 14, color: kPrimary),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      );
}
