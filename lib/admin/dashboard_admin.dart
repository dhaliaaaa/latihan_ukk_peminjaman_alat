import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// IMPORT KATEGORI ANDA DISINI (Pastikan file kategori.dart ada)
import 'kategori.dart'; 

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 0;

  // Fungsi untuk Logout
  Future<void> _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
  }

  // --- KONTEN BERANDA (DENGAN TAMBAHAN GRAFIK BARU) ---
  Widget _buildBerandaContent() {
    return Column(
      children: [
        // Header Biru Gelap
        Container(
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
          decoration: const BoxDecoration(
            color: Color(0xFF0D2B52),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Halo, Admin!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF0D2B52), size: 30),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                // STAT CARD SECTION
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard("30", "Total Aset"),
                    _buildStatCard("17", "Tersedia"),
                    _buildStatCard("6", "Sedang Dipinjam"),
                    _buildStatCard("10", "Perlu Perbaikan"),
                  ],
                ),
                const SizedBox(height: 25),
                
                // GRAFIK LAMA (BAR CHART)
                _buildChartSection(),
                
                const SizedBox(height: 25),

                // GRAFIK BARU: ALAT PALING SERING DIPINJAM (PIE CHART)
                _buildMostBorrowedSection(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LIST HALAMAN ---
    final List<Widget> _pages = [
      _buildBerandaContent(),                             // Index 0
      const Center(child: Text("Halaman Pengguna")),      // Index 1
      const KategoriPage(),                               // Index 2
      const Center(child: Text("Halaman Riwayat")),       // Index 3
      const Center(child: Text("Halaman Pengaturan")),    // Index 4
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D2B52),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }

  // --- WIDGET HELPER STAT CARD ---
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER GRAFIK BATANG (KODE LAMA) ---
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grafik Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterBtn("Mingguan", true),
                _buildFilterBtn("Bulanan", false),
                _buildFilterBtn("Tahunan", false),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(height: 200, child: _simpleBarChart()),
        ],
      ),
    );
  }

  // --- WIDGET BARU: PIE CHART (ALAT TERING DIPINJAM) ---
  Widget _buildMostBorrowedSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Alat Paling Sering Dipinjam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            children: [
              // Grafik Lingkaran
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(color: const Color(0xFF0D2B52), value: 40, title: '40%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(color: Colors.orange, value: 30, title: '30%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(color: Colors.blue, value: 20, title: '20%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(color: Colors.grey, value: 10, title: '10%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend (Keterangan Alat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend(const Color(0xFF0D2B52), "Laptop ASUS"),
                    _buildLegend(Colors.orange, "Proyektor"),
                    _buildLegend(Colors.blue, "Kamera Canon"),
                    _buildLegend(Colors.grey, "Lainnya"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String t, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0D2B52) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? Colors.transparent : Colors.grey[300]!),
      ),
      child: Text(t, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _simpleBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, 35), _makeGroupData(1, 50), _makeGroupData(2, 75),
          _makeGroupData(3, 60), _makeGroupData(4, 100), _makeGroupData(5, 80), _makeGroupData(6, 90),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF0D2B52),
          width: 15,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }
}