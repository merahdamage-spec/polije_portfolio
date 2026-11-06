import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/profile_store.dart';
import '../widgets/gradient_header.dart';

/// ⚠️ DATA AWAL — WAJIB diverifikasi/dilengkapi dari sumber resmi:
/// https://www.polije.ac.id (dan situs jurusan/prodi masing-masing).
const Map<String, List<String>> kJurusan = {
  'Teknologi Informasi': [
    'D4 Teknik Informatika',
    'D3 Manajemen Informatika',
    'D3 Teknik Komputer',
    'D4 Rekayasa Perangkat Lunak',
  ],
  'Teknik': ['D3 Teknik Mesin', 'D4 Teknik Energi Terbarukan'],
  'Teknologi Pertanian': ['D4 Teknologi Rekayasa Pangan', 'D3 Teknologi Industri Pangan'],
  'Produksi Pertanian': ['D4 Teknik Produksi Benih', 'D4 Produksi Tanaman Hortikultura'],
  'Peternakan': ['D3 Produksi Ternak', 'D4 Manajemen Bisnis Unggas'],
  'Manajemen Agribisnis': ['D3 Manajemen Agribisnis', 'D4 Agribisnis Pangan'],
  'Kesehatan': ['D3 Gizi', 'D3 Rekam Medik'],
  'Bahasa, Komunikasi & Pariwisata': ['D3 Bahasa Inggris', 'D4 Destinasi Pariwisata'],
};

const _kegiatan = [
  (Icons.science, 'Laboratorium & Teaching Factory',
      'Pembelajaran berbasis praktik di laboratorium dan unit produksi kampus.'),
  (Icons.groups, 'Organisasi & UKM Mahasiswa',
      'Wadah pengembangan minat, bakat, dan kepemimpinan mahasiswa.'),
  (Icons.handshake, 'Kerja Sama Industri',
      'Magang, kunjungan industri, dan kolaborasi dengan dunia usaha.'),
  (Icons.emoji_events, 'Prestasi Mahasiswa',
      'Capaian mahasiswa pada kompetisi tingkat daerah hingga nasional.'),
  (Icons.local_library, 'Perpustakaan & Fasilitas Belajar',
      'Sarana penunjang kegiatan akademik dan nonakademik.'),
];

class AboutPolijePage extends StatefulWidget {
  const AboutPolijePage({super.key});

  @override
  State<AboutPolijePage> createState() => _AboutPolijePageState();
}

class _AboutPolijePageState extends State<AboutPolijePage> {
  String _jurusan = kJurusan.keys.first;
  final _pc = PageController(viewportFraction: 0.88);
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const GradientHeader(
          title: 'Tentang POLIJE',
          subtitle: 'Politeknik Negeri Jember',
        ),
        // 1. Profil POLIJE
        _section('Profil POLIJE', Icons.account_balance),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _Row(Icons.badge, 'Nama', 'Politeknik Negeri Jember (POLIJE)'),
                _Row(Icons.location_on, 'Lokasi',
                    'Jl. Mastrip, Sumbersari, Kabupaten Jember, Jawa Timur'),
                _Row(Icons.public, 'Website', 'www.polije.ac.id'),
                _Row(Icons.engineering, 'Pendidikan Vokasi',
                    'Menekankan keterampilan terapan; porsi praktik lebih besar dibanding teori agar lulusan siap kerja.'),
                _Row(Icons.info, 'Informasi Umum',
                    'Perguruan tinggi vokasi negeri dengan beragam jurusan di bidang pertanian, teknologi, kesehatan, bisnis, dan pariwisata.'),
              ],
            ),
          ),
        ),
        // 2. Program Studi (Dropdown)
        _section('Program Studi', Icons.menu_book),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _jurusan,
                decoration: const InputDecoration(
                    labelText: 'Pilih Jurusan',
                    prefixIcon: Icon(Icons.account_tree),
                    border: OutlineInputBorder()),
                items: kJurusan.keys
                    .map((j) => DropdownMenuItem(
                        value: j, child: Text(j, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _jurusan = v!),
              ),
              const SizedBox(height: 8),
              ...kJurusan[_jurusan]!.map((p) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.school, color: kPrimary),
                      title: Text(p),
                    ),
                  )),
            ],
          ),
        ),
        // 3. Program Studi Saya
        _section('Program Studi Saya', Icons.star),
        ValueListenableBuilder<Profile>(
          valueListenable: ProfileStore.instance.profile,
          builder: (_, p, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: kGradient, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.prodi,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(p.prodiDesc,
                    style: const TextStyle(color: Colors.white, height: 1.4)),
                const SizedBox(height: 6),
                Text('Kompetensi: ${p.skills}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        // 4. Fasilitas / Kegiatan (PageView)
        _section('Fasilitas & Kegiatan Kampus', Icons.apartment),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pc,
            itemCount: _kegiatan.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final k = _kegiatan[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundColor: kPrimary.withOpacity(0.12),
                          child: Icon(k.$1, color: kPrimary)),
                      const SizedBox(height: 10),
                      Text(k.$2,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(k.$3, style: const TextStyle(height: 1.3)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _kegiatan.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.all(4),
              width: _page == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? kPrimary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
              'Sumber informasi: kanal resmi POLIJE (polije.ac.id).',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        child: Row(children: [
          Icon(icon, color: kPrimary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: kPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(value, style: const TextStyle(height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      );
}
