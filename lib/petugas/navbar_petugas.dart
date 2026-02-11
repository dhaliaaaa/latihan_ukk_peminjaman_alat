import 'package:flutter/material.dart';
import 'dashboard_petugas.dart';
import 'persetujuan.dart';

class NavbarPetugas extends StatefulWidget {
  const NavbarPetugas({super.key});

  @override
  State<NavbarPetugas> createState() => _NavbarPetugasState();
}

class _NavbarPetugasState extends State<NavbarPetugas> {
  int _selectedIndex = 0; // Default Dashboard

  // Daftar halaman
  final List<Widget> _pages = [
    const DashboardPetugas(), // Index 0
    const PersetujuanPage(),   // Index 1
    const Center(child: Text("Halaman Kembali")),
    const Center(child: Text("Halaman Laporan")),
    const Center(child: Text("Halaman Pengaturan")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack memastikan halaman tidak reload saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF002347),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: "Setuju"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: "Kembali"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Laporan"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Pengaturan"),
        ],
      ),
    );
  }
}