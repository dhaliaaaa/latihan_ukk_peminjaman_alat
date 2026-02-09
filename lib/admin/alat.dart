import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_kategori.dart'; 
import 'tambah_alat.dart';     

class AlatPage extends StatefulWidget {
  final String kategori;
  final int idKategori;

  const AlatPage({super.key, required this.kategori, required this.idKategori});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    return supabase
        .from('alat')
        .stream(primaryKey: ['id_alat'])
        .eq('id_kategori', widget.idKategori);
  }

  // --- FUNGSI NAVIGASI & POPUP ---
  void _openTambahKategori() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const TambahKategoriPage(),
    );
  }

  void _goToTambahAlat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahAlatPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // MENGGUNAKAN FAB AGAR TOMBOL TIDAK TERGANGGU SCROLL
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFabButton("Tambah Alat", Icons.post_add_rounded, _goToTambahAlat),
          const SizedBox(height: 12),
          _buildFabButton("Tambah Kategori", Icons.dashboard_customize_rounded, _openTambahKategori),
          const SizedBox(height: 20), // Memberi jarak dari bawah layar
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getAlatStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data ?? [];

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Padding bawah besar agar isi tidak tertutup FAB
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCardAlat(data[index]),
                          childCount: data.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tombol yang dipindahkan ke FAB area
  Widget _buildFabButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2B52),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D2B52),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.kategori.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAlat(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: item['foto_alat'] != null 
                ? Image.network(item['foto_alat'], fit: BoxFit.contain)
                : const Icon(Icons.laptop, size: 50, color: Colors.grey),
          ),
          Text(item['nama_alat'] ?? 'Unit', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.delete_outline, size: 22),
                const Icon(Icons.edit_outlined, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF0D2B52), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Tersedia", style: TextStyle(color: Colors.white, fontSize: 10)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}