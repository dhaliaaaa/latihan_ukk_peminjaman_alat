import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_peminjam.dart'; 
import 'katalog.dart'; 
import 'pengajuan.dart'; 

class MainNavigationPeminjam extends StatefulWidget {
  const MainNavigationPeminjam({super.key});

  @override
  State<MainNavigationPeminjam> createState() => _MainNavigationPeminjamState();
}

class _MainNavigationPeminjamState extends State<MainNavigationPeminjam> {
  int _selectedIndex = 0;

  // Daftar halaman untuk role PEMINJAM sesuai desain terbaru
  final List<Widget> _pages = [
    const DashboardPeminjam(),    // Indeks 0: Beranda
    const KatalogPage(),          // Indeks 1: Alat/Katalog
    const Center(child: Text("Halaman Pinjam")), // Indeks 2: Pinjam
    const PengajuanPage(),        // Indeks 3: Pengajuan
    const ProfilePlaceholder(),   // Indeks 4: Laporan/Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack digunakan agar state halaman (seperti scroll) tidak hilang saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      // Tombol Tambah melayang hanya muncul di Dashboard
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: () => setState(() => _selectedIndex = 1), // Pindah ke Katalog
            backgroundColor: const Color(0xFF002347),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ) 
        : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: const Color(0xFF002347), // Warna navy tema Anda
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        // Item navigasi disesuaikan dengan desain 5 menu
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Alat'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Pinjam'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Pengajuan'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Laporan'),
        ],
      ),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil & Laporan"),
        backgroundColor: const Color(0xFF002347),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Halaman Profil / Laporan"),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}