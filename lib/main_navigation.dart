import 'package:flutter/material.dart';
import 'admin/kategori.dart'; // Nama file di folder admin adalah kategori.dart

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Daftar halaman yang dipanggil
  final List<Widget> _pages = [
    const DashboardAdmin(),           
    const Center(child: Text("Halaman Pengguna")), 
    const KategoriPage(), // Pastikan nama Class di dalam kategori.dart adalah KategoriPage
    const Center(child: Text("Halaman Riwayat")),  
    const Center(child: Text("Halaman Pengaturan")), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D2B52),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Pengguna'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
        ],
      ),
    );
  }
}