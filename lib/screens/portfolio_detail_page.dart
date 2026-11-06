import 'package:flutter/material.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../models/portfolio.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/portfolio_card.dart';
import 'portfolio_form_page.dart';

class PortfolioDetailPage extends StatefulWidget {
  final int id;
  const PortfolioDetailPage({super.key, required this.id});

  @override
  State<PortfolioDetailPage> createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  Portfolio? _item;

  @override
  void initState() {
    super.initState();
    DbHelper.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DbHelper.instance.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final d = await DbHelper.instance.getById(widget.id);
      if (mounted) setState(() => _item = d);
    } catch (_) {}
  }

  Future<void> _delete() async {
    final item = _item!;
    if (!await confirmDelete(context, item.title)) return;
    try {
      await DbHelper.instance.delete(item.id!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}')));
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Portofolio dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Karya'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: kGradient)),
        actions: item == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PortfolioFormPage(portfolio: item))),
                ),
                IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
              ],
      ),
      body: item == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PortfolioImage(
                          path: item.imagePath,
                          width: double.infinity,
                          height: 220),
                    ),
                    const SizedBox(height: 16),
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      Chip(
                          avatar: const Icon(Icons.folder_outlined, size: 16),
                          label: Text(item.category)),
                      Chip(
                          avatar: const Icon(Icons.code, size: 16),
                          label: Text(item.technology)),
                      Chip(
                          avatar: const Icon(Icons.event, size: 16),
                          label: Text(formatDate(item.createdAt))),
                    ]),
                    const Divider(height: 28),
                    const Text('Deskripsi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(item.description, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
    );
  }
}
