import 'package:flutter/material.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../models/portfolio.dart';
import '../services/profile_store.dart';
import '../widgets/gradient_header.dart';
import '../widgets/portfolio_card.dart';
import 'portfolio_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onGoTo;
  const HomePage({super.key, required this.onGoTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;
  int _total = 0;
  List<Portfolio> _latest = [];
  bool _loading = true;
  String? _error;

  static const _banners = [
    (
      Icons.rocket_launch,
      'Portofolio Digital',
      'Tampilkan karya terbaikmu dalam satu aplikasi.',
      [Color.fromARGB(255, 63, 32, 220), Color.fromARGB(255, 60, 31, 166)]
    ),
    (
      Icons.school,
      'Bangga di POLIJE',
      'Pendidikan vokasi yang siap menghadapi dunia kerja.',
      [Color(0xFF1565C0), Color(0xFF42A5F5)]
    ),
    (
      Icons.emoji_events,
      'Terus Berkarya',
      'Tambah proyek baru dan kembangkan skill-mu.',
      [Color(0xFFEF6C00), Color(0xFFFFB74D)]
    ),
  ];

  @override
  void initState() {
    super.initState();
    DbHelper.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DbHelper.instance.changes.removeListener(_load);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all =
          await DbHelper.instance.getAll(category: 'Semua', keyword: '');
      // urutkan dari id terbesar (terbaru), tanpa mengubah list asli
      final sorted = [...all]..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      if (!mounted) return;
      setState(() {
        _total = all.length;
        _latest = sorted.take(3).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('load error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openDetail(Portfolio p) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => PortfolioDetailPage(id: p.id!)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ValueListenableBuilder<Profile>(
          valueListenable: ProfileStore.instance.profile,
          builder: (_, p, __) => GradientHeader(
            title: 'Halo, ${p.name.split(' ').first}! 👋',
            subtitle: '${p.prodi} • POLIJE',
            trailing: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            bottom: Row(
              children: [
                _stat(Icons.folder, '$_total', 'Karya'),
                const SizedBox(width: 12),
                _stat(Icons.badge, p.nim, 'NIM'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // PageView banner
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: b.$4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(b.$1, size: 54, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.$2,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(b.$3,
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? kPrimary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Menu cepat
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shortcut(Icons.person, 'Profil', 1),
              _shortcut(Icons.folder, 'Karya', 2),
              _shortcut(Icons.add_circle, 'Tambah', 3),
              _shortcut(Icons.school, 'POLIJE', 4),
            ],
          ),
        ),
        // Judul + tombol Lihat semua
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 0),
          child: Text('Karya Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => widget.onGoTo(2),
              icon: const Icon(Icons.folder_open),
              label: const Text('Lihat semua'),
            ),
          ),
        ),
        // Daftar karya terbaru (loading / error / kosong / data)
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          _errorView()
        else if (_latest.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Belum ada karya.')),
          )
        else
          ..._latest.map((p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 130,
                  child: PortfolioCard(
                    item: p,
                    onTap: () => _openDetail(p),
                  ),
                ),
              )),
        // Ajakan menambah karya
        _addCta(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _errorView() => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );

  Widget _stat(IconData icon, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _shortcut(IconData icon, String label, int index) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onGoTo(index),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 26,
                  backgroundColor: kPrimary.withOpacity(0.12),
                  child: Icon(icon, color: kPrimary)),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _addCta() => Container(
        margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: kPrimary.withOpacity(0.15),
              child: const Icon(Icons.add_photo_alternate, color: kPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Belum ada karya baru bulan ini',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Yuk tambah proyek barumu!',
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => widget.onGoTo(3),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah karya'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
