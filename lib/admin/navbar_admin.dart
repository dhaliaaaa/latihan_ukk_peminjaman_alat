import 'package:flutter/material.dart';
// Import semua halaman yang akan ditampilkan di navbar
import 'pengguna.dart'; 

class NavbarAdmin extends StatefulWidget {
  const NavbarAdmin({super.key});

  @override
  State<NavbarAdmin> createState() => _NavbarAdminState();
}

class _NavbarAdminState extends State<NavbarAdmin> {
  // Variabel untuk melacak halaman yang sedang aktif
  int _currentIndex = 1; // Default ke index 1 (Pengguna) sesuai desain

  // Daftar halaman yang akan muncul di Navbar
  final List<Widget> _pages = [
    const Center(child: Text("Halaman Beranda")), // Index 0
    const PenggunaPage(),                         // Index 1 (File pengguna.dart)
    const Center(child: Text("Halaman Katalog")), // Index 2
    const Center(child: Text("Halaman Riwayat")), // Index 3
    const Center(child: Text("Halaman Setting")), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga keadaan (state) halaman agar tidak reload saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Konfigurasi tampilan navbar sesuai desain
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF002347), // Navy Tua sesuai desain
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            activeIcon: Icon(Icons.person_pin_rounded),
            label: 'Pengguna', // Tombol menuju pengguna.dart
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}