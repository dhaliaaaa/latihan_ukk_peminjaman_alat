import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // Background agak abu-abu sesuai gambar
      body: Column(
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
                    fontSize: 24, // Sesuai gambar
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Tombol X yang lebih tebal
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // Grid Stat Card
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
                  
                  // Section Grafik
                  _buildChartSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F), // Warna biru card lebih terang sedikit
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Box Putih di Kiri (Sesuai Gambar)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Background transparan putih
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // Teks Angka dan Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grafik Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildFilterBtn("Mingguan", true),
              _buildFilterBtn("Bulanan", false),
              _buildFilterBtn("Tahunan", false),
            ],
          ),
          const SizedBox(height: 30),
          // Chart Bar
          SizedBox(height: 200, child: _simpleBarChart()),
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
        boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 5)] : null,
      ),
      child: Text(
        t,
        style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _simpleBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, 35),
          _makeGroupData(1, 50),
          _makeGroupData(2, 75),
          _makeGroupData(3, 60),
          _makeGroupData(4, 100),
          _makeGroupData(5, 80),
          _makeGroupData(6, 90),
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF0D2B52),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Pengguna'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Katalog'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
      ],
    );
  }
}