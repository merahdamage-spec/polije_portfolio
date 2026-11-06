import 'package:flutter/material.dart';

import 'about_polije_page.dart';
import 'home_page.dart';
import 'portfolio_form_page.dart';
import 'portfolio_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _formKey = 0; // untuk mereset form "Tambah" setelah tersimpan

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onGoTo: _go),
      const ProfilePage(),
      const PortfolioPage(),
      PortfolioFormPage(
        key: ValueKey(_formKey),
        onSaved: () => setState(() {
          _formKey++;
          _index = 2; // pindah ke daftar portofolio
        }),
      ),
      const AboutPolijePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
          NavigationDestination(
              icon: Icon(Icons.folder_open),
              selectedIcon: Icon(Icons.folder),
              label: 'Karya'),
          NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Tambah'),
          NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'POLIJE'),
        ],
      ),
    );
  }
}
