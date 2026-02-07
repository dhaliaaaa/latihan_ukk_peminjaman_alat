import 'package:flutter/material.dart';
// Import halaman-halaman kamu di sini
import 'admin/dashboard_admin.dart'; 
import 'admin/kategori.dart'; 

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan berdasarkan menu yang dipilih
  final List<Widget> _pages = [
    const DashboardAdmin(), // Menu Beranda
    const Center(child: Text("Halaman Pengguna")), // Menu Pengguna
    const KategoriPage(), // Menu Katalog (Halaman yang kamu kirim kodenya)
    const Center(child: Text("Halaman Riwayat")), // Menu Riwayat
    const Center(child: Text("Halaman Pengaturan")), // Menu Pengaturan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack digunakan agar saat pindah tab, data di halaman sebelumnya tidak ter-reset
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Tetap muncul meski lebih dari 3 item
        selectedItemColor: const Color(0xFF002347),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}