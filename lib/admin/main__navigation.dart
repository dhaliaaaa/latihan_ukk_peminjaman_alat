import 'package:flutter/material.dart';
// Menggunakan import relatif (titik satu berarti satu folder)
import 'dashboard_admin.dart'; 
import 'kategori.dart'; 
import 'riwayat_admin.dart'; 

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardAdmin(),           
    const Center(child: Text("Halaman Pengguna")), 
    const KategoriPage(),             
    const RiwayatAdminPage(), 
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
        showUnselectedLabels: true,
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