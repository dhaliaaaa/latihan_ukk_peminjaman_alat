import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Nama Class diawali huruf kapital (PascalCase) agar bisa dikenali sebagai Widget
class dashboard_admin extends StatelessWidget {
  const dashboard_admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Halo, Admin!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Icon(Icons.close, color: Colors.white, size: 30),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
      decoration: BoxDecoration(color: const Color(0xFF0D2B52), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Perbaikan typo: Positioned (bukan Positionclsed)
          Positioned(left: 10, top: 15, child: Icon(Icons.inventory_2, color: Colors.white.withOpacity(0.3))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grafik Peminjaman", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFilterBtn("Mingguan", true),
              _buildFilterBtn("Bulanan", false),
              _buildFilterBtn("Tahunan", false),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 180, child: _simpleBarChart()),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String t, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: active ? const Color(0xFF0D2B52) : Colors.grey[300], borderRadius: BorderRadius.circular(15)),
      child: Text(t, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 10)),
    );
  }

  Widget _simpleBarChart() {
    return BarChart(BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: const Color(0xFF0D2B52))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: const Color(0xFF0D2B52))]),
      ],
    ));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0D2B52),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Katalog'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
      ],
    );
  }
}