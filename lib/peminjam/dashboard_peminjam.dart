import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPeminjam extends StatefulWidget {
  const DashboardPeminjam({super.key});

  @override
  State<DashboardPeminjam> createState() => _DashboardPeminjamState();
}

class _DashboardPeminjamState extends State<DashboardPeminjam> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  // FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER SECTION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF002347), 
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hallo Peminjam",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? "user@gmail.com",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Online",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                // --- PROFIL DENGAN MENU LOGOUT (KONSISTEN DENGAN ROLE LAIN) ---
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  offset: const Offset(0, 70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFF002347)),
                  ),
                ),
              ],
            ),
          ),

          // STATS GRID SECTION
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard("Pengguna Aktif", "7"),
                      _buildStatCard("Alat Tersedia", "18"),
                      _buildStatCard("Jumlah Alat", "12"),
                      _buildStatCard("Alat Dipinjam", "5"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // RIWAYAT PEMINJAMAN SECTION
                  const Text(
                    "Riwayat Peminjaman",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002347),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // LIST DARI SUPABASE
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase
                        .from('riwayat_peminjaman') 
                        .stream(primaryKey: ['id'])
                        .order('tanggal', ascending: false),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      // Data Dummy jika database kosong/error
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          children: [
                            _buildHistoryItem("Ananda Laras", "20 Januari 2026"),
                            const SizedBox(height: 15),
                            _buildHistoryItem("Antasena Bayu", "7 Januari 2026"),
                          ],
                        );
                      }

                      final data = snapshot.data!;
                      return Column(
                        children: data.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildHistoryItem(
                              item['nama_peminjam'] ?? "User",
                              item['tanggal'] ?? "Tanggal",
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // WIDGET NAVIGASI BAWAH
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF002347),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Katalog"),
          BottomNavigationBarItem(icon: Icon(Icons.request_quote), label: "Pinjam"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Pengajuan"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Laporan"),
        ],
      ),
    );
  }

  // WIDGET UNTUK KOTAK STATISTIK
  Widget _buildStatCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF153E6B), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), 
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK ITEM RIWAYAT
  Widget _buildHistoryItem(String name, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2E5C), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF0D2E5C)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}