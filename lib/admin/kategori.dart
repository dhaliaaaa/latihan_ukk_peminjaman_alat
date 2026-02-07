import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

// --- 1. WRAPPER UTAMA ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex =
      2; // Set default ke Katalog (Index 2) untuk melihat hasilnya langsung

  final List<Widget> _pages = [
    const DashboardAdmin(),
    const Center(child: Text("Halaman Pengguna")),
    const KategoriPage(),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D2B52),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin), label: 'Pengguna'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

// --- 2. HALAMAN DASHBOARD ADMIN ---
class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0D2B52),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Halo, Admin!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grafik Peminjaman",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(children: [
            _buildFilterBtn("Mingguan", true),
            _buildFilterBtn("Bulanan", false),
            _buildFilterBtn("Tahunan", false)
          ]),
          const SizedBox(height: 30),
          SizedBox(height: 200, child: _simpleBarChart()),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String t, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: active ? const Color(0xFF0D2B52) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0D2B52))),
      child: Text(t,
          style: TextStyle(
              color: active ? Colors.white : const Color(0xFF0D2B52),
              fontSize: 11)),
    );
  }

  Widget _simpleBarChart() {
    return BarChart(BarChartData(
      maxY: 100,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const days = [
                    'Senin',
                    'Selasa',
                    'Rabu',
                    'Kamis',
                    'Jumat',
                    'Sabtu',
                    'Minggu'
                  ];
                  return (v.toInt() >= 0 && v.toInt() < days.length)
                      ? Text(days[v.toInt()],
                          style: const TextStyle(fontSize: 9))
                      : const Text('');
                })),
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 25)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(toY: 30, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(toY: 50, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(toY: 70, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 3, barRods: [
          BarChartRodData(toY: 60, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 4, barRods: [
          BarChartRodData(toY: 90, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 5, barRods: [
          BarChartRodData(toY: 80, color: const Color(0xFF0D2B52), width: 15)
        ]),
        BarChartGroupData(x: 6, barRods: [
          BarChartRodData(toY: 85, color: const Color(0xFF0D2B52), width: 15)
        ]),
      ],
    ));
  }
}

// --- 3. HALAMAN KATEGORI/KATALOG ---
class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _KategoriPageState extends State<KategoriPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  String selectedKategori = 'Semua';
  final List<String> daftarKategori = [
    'Semua',
    'Laptop',
    'FlashDisk',
    'Proyektor',
    'Camera'
  ];

  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    return supabase.from('alat').stream(primaryKey: ['id']);
  }

  // FUNGSIONALITAS BARU: Dialog Konfirmasi Hapus (100% Mirip Gambar)
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "HAPUS",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B52),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Apakah anda yakin untuk menghapus produk?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Batal
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAAAAAA),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    // Tombol Hapus (Merah Marun)
                    GestureDetector(
                      onTap: () {
                        // Logika penghapusan data bisa diletakkan di sini
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF800000),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          "Hapus",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF002347),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Katalog Alat",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.close, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search, color: Color(0xFF002347)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: _buildFilterList(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getAlatStream(),
                    builder: (context, snapshot) {
                      List<Map<String, dynamic>> data = snapshot.data ?? [];
                      if (data.isEmpty &&
                          snapshot.connectionState != ConnectionState.waiting) {
                        data = [
                          {
                            'nama_alat': 'Proyektor BenQ EX-1',
                            'kategori': 'Proyektor',
                            'stok': 8,
                            'gambar_url':
                                'https://vmfmclmubfoidvdyofjt.supabase.co/storage/v1/object/public/alat_images/proyektor.png'
                          },
                          {
                            'nama_alat': 'Laptop Asus Vivobook 15.6',
                            'kategori': 'Laptop',
                            'stok': 10,
                            'gambar_url':
                                'https://vmfmclmubfoidvdyofjt.supabase.co/storage/v1/object/public/alat_images/laptop.png'
                          },
                          {
                            'nama_alat': '256GB USB 2.0 FLASH DRIVE',
                            'kategori': 'FlashDisk',
                            'stok': 4,
                            'gambar_url':
                                'https://vmfmclmubfoidvdyofjt.supabase.co/storage/v1/object/public/alat_images/flashdisk.png'
                          },
                          {
                            'nama_alat': 'Canon EOS 200D MARK',
                            'kategori': 'Camera',
                            'stok': 6,
                            'gambar_url':
                                'https://vmfmclmubfoidvdyofjt.supabase.co/storage/v1/object/public/alat_images/camera.png'
                          },
                        ];
                      }
                      final filtered = selectedKategori == 'Semua'
                          ? data
                          : data
                              .where((i) => i['kategori'] == selectedKategori)
                              .toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(15),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildCardAlat(filtered[index]),
                      );
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 20, bottom: 30, top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildFabAction("Tambah Alat", Icons.post_add),
                          const SizedBox(height: 10),
                          _buildFabAction("Tambah Kategori", Icons.grid_view),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        itemCount: daftarKategori.length,
        itemBuilder: (context, index) {
          String kat = daftarKategori[index];
          bool isSelected = selectedKategori == kat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => selectedKategori = kat),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF002347) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF002347))),
                child: Text(kat,
                    style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF002347),
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardAlat(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add_circle,
                      color: Color(0xFF002347), size: 28))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.network(item['gambar_url'] ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40)),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(item['nama_alat'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002347),
                    fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Hapus memicu Dialog
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(context),
                  child: const Icon(Icons.delete_outline,
                      size: 22, color: Color(0xFF002347)),
                ),
                const Icon(Icons.edit_outlined,
                    size: 22, color: Color(0xFF002347)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF002347),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("Tersedia ${item['stok']}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF0D2B52),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
