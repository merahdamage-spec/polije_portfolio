import 'package:flutter/material.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../models/portfolio.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/gradient_header.dart';
import '../widgets/portfolio_card.dart';
import 'portfolio_detail_page.dart';
import 'portfolio_form_page.dart';

/// READ + filter Dropdown + search + akses Edit/Delete
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _search = TextEditingController();
  String _filter = 'Semua';
  List<Portfolio> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    DbHelper.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DbHelper.instance.changes.removeListener(_load);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await DbHelper.instance
          .getAll(category: _filter, keyword: _search.text);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _delete(Portfolio p) async {
    if (!await confirmDelete(context, p.title)) return;
    try {
      await DbHelper.instance.delete(p.id!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Portofolio dihapus')));
  }

  void _edit(Portfolio p) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => PortfolioFormPage(portfolio: p)));

  void _open(Portfolio p) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => PortfolioDetailPage(id: p.id!)));

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                  onPressed: () {
                    setState(() => _loading = true);
                    _load();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi')),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientHeader(
          title: 'Portofolio / Karya',
          subtitle: '${_items.length} karya ditampilkan',
          bottom: Column(
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => _load(),
                decoration: InputDecoration(
                  hintText: 'Cari judul atau deskripsi...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              // Dropdown filter kategori
              DropdownButtonFormField<String>(
                value: _filter,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.filter_list),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ['Semua', ...kCategories]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _filter = v!);
                  _load();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _errorView()
                  : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('Belum ada portofolio'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      // responsive: 1 kolom di HP, lebih banyak di tablet
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 520,
                        mainAxisExtent: 140,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final p = _items[i];
                        return PortfolioCard(
                          item: p,
                          onTap: () => _open(p),
                          onEdit: () => _edit(p),
                          onDelete: () => _delete(p),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
