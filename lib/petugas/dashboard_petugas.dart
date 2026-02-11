import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



class DashboardPetugas extends StatefulWidget {

  const DashboardPetugas({super.key});



  @override

  State<DashboardPetugas> createState() => _DashboardPetugasState();

}



class _DashboardPetugasState extends State<DashboardPetugas> {

  final supabase = Supabase.instance.client;

  int _selectedIndex = 0;



  // Fungsi untuk menangani perpindahan navigasi

  void _onItemTapped(int index) {

    setState(() {

      _selectedIndex = index;

    });

  }



  // Fungsi Logout

  Future<void> _handleLogout() async {

    await supabase.auth.signOut();

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Column(

        children: [

          // HEADER (Biru Tua)

          Container(

            width: double.infinity,

            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),

            decoration: const BoxDecoration(

              color: Color(0xFF002347),

            ),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Halo, Petugas!",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                  ),

                ),

               

                // --- PERUBAHAN DISINI: PROFIL DENGAN MENU LOGOUT ---

                PopupMenuButton<String>(

                  onSelected: (value) {

                    if (value == 'logout') {

                      _handleLogout();

                    }

                  },

                  offset: const Offset(0, 50),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(15),

                  ),

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

                    radius: 22,

                    backgroundColor: Colors.white24,

                    child: Icon(Icons.person, color: Colors.white, size: 28),

                  ),

                ),

              ],

            ),

          ),



          Expanded(

            child: SingleChildScrollView(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // STATS CARDS

                  Row(

                    children: [

                      _buildSummaryCard("4", "Peminjaman Baru"),

                      const SizedBox(width: 15),

                      _buildSummaryCard("6", "Jatuh Tempo"),

                    ],

                  ),

                  const SizedBox(height: 30),



                  // ACTION BUTTONS

                  _buildActionButton(Icons.qr_code_scanner, "Scan Barcode"),

                  const SizedBox(height: 15),

                  _buildActionButton(Icons.check_circle, "Verifikasi Pengembalian"),

                  const SizedBox(height: 15),

                  _buildActionButton(Icons.build, "Cek Kondisi Barang"),

                  const SizedBox(height: 40),



                  // DAFTAR ANTREAN

                  const Text(

                    "Daftar Antrean",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                  ),

                  const SizedBox(height: 15),



                  // LIST REAL-TIME DARI SUPABASE

                  StreamBuilder<List<Map<String, dynamic>>>(

                    stream: supabase

                        .from('peminjaman')

                        .stream(primaryKey: ['id'])

                        .order('created_at'),

                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {

                        return const Center(child: CircularProgressIndicator());

                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {

                        return const Center(child: Text("Tidak ada antrean"));

                      }

                     

                      final data = snapshot.data!;

                      return Container(

                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(

                          color: const Color(0xFFF4F7FA),

                          borderRadius: BorderRadius.circular(20),

                        ),

                        child: Column(

                          children: data.map((item) => _buildQueueItem(

                            item['nama_peminjam'] ?? 'User',

                            item['nama_barang'] ?? 'Barang',

                          )).toList(),

                        ),

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



  // Widget Kartu Statistik Kecil (TETAP SAMA)

  Widget _buildSummaryCard(String count, String label) {

    return Expanded(

      child: Container(

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(

          color: const Color(0xFF153E6B),

          borderRadius: BorderRadius.circular(12),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(0.1),

              blurRadius: 4,

              offset: const Offset(0, 4),

            )

          ]

        ),

        child: Row(

          children: [

            const Icon(Icons.inventory_2, color: Colors.white, size: 30),

            const SizedBox(width: 10),

            Flexible(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),

                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),

                ],

              ),

            )

          ],

        ),

      ),

    );

  }



  // Widget Tombol Aksi Utama (TETAP SAMA)

  Widget _buildActionButton(IconData icon, String title) {

    return Container(

      width: double.infinity,

      height: 55,

      decoration: BoxDecoration(

        color: const Color(0xFF153E6B),

        borderRadius: BorderRadius.circular(15),

      ),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(icon, color: Colors.white),

          const SizedBox(width: 10),

          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

        ],

      ),

    );

  }



  // Widget Item Antrean (TETAP SAMA)

  Widget _buildQueueItem(String name, String item) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Row(

        children: [

          const CircleAvatar(

            backgroundColor: Color(0xFF002347),

            child: Icon(Icons.person, color: Colors.white),

          ),

          const SizedBox(width: 15),

          Expanded(

            child: RichText(

              text: TextSpan(

                style: const TextStyle(color: Colors.black, fontSize: 16),

                children: [

                  TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),

                  TextSpan(text: " ($item)", style: const TextStyle(color: Colors.grey)),

                ],

              ),

            ),

          ),

          ElevatedButton(

            onPressed: () {},

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFF153E6B),

              elevation: 4,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

            ),

            child: const Text("Proses", style: TextStyle(color: Colors.white)),

          ),

        ],

      ),

    );

  }



  // Widget Navigasi Bawah (TETAP SAMA)

  Widget _buildBottomNav() {

    return BottomNavigationBar(

      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFF002347),

      unselectedItemColor: Colors.grey,

      currentIndex: _selectedIndex,

      onTap: _onItemTapped,

      selectedFontSize: 12,

      unselectedFontSize: 12,

      items: const [

        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),

        BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: "Setuju"),

        BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: "Kembali"),

        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Laporan"),

        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Pengaturan"),

      ],

    );

  }

}