import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_kategori.dart'; // Pastikan import ini ada

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getKategoriStream() {
    return supabase.from('kategori').stream(primaryKey: ['id_kategori']);
  }

  Future<void> _deleteKategori(int id) async {
    try {
      await supabase.from('kategori').delete().match({'id_kategori': id});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil dihapus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: $e")),
        );
      }
    }
  }

  void _showDeleteDialog(int id, String nama) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "HAPUS",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF002347)),
                ),
                const SizedBox(height: 15),
                Text(
                  "Apakah anda yakin untuk menghapus kategori $nama?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); 
                          _deleteKategori(id);    
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
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
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF002347),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Katalog Alat",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
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
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: [
                        _buildFilterChip("Semua", true),
                        _buildFilterChip("Laptop", false),
                        _buildFilterChip("FlashDisk", false),
                        _buildFilterChip("Proyektor", false),
                        _buildFilterChip("Camera", false),
                      ],
                    ),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getKategoriStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final data = snapshot.data ?? [];
                      if (data.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: Text("Tidak ada data kategori")),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            childAspectRatio: 0.8, 
                            crossAxisSpacing: 15, 
                            mainAxisSpacing: 15),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return _buildCardKategori(data[index]);
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 40, top: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildFabAction("Tambah Alat", Icons.post_add_rounded),
                          const SizedBox(height: 10),
                          _buildFabAction("Tambah Kategori", Icons.dashboard_rounded),
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

  Widget _buildCardKategori(Map<String, dynamic> item) {
    final int id = item['id_kategori'] ?? 0;
    final String nama = item['nama_kategori'] ?? 'Tanpa Nama';
    final String urlGambar = item['kode_alat'] ?? ''; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 10, right: 10,
            child: Icon(Icons.add_circle, color: Color(0xFF002347), size: 26),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: urlGambar.startsWith('http') 
                    ? Image.network(
                        urlGambar,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 40),
                      )
                    : const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  nama.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002347), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showDeleteDialog(id, nama),
                      child: const Icon(Icons.delete_outline, color: Color(0xFF002347), size: 22),
                    ),
                    const SizedBox(width: 5),
                    
                    // --- UPDATE DISINI: NAVIGASI EDIT ---
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditKategoriPage(item: item)),
                        );
                      },
                      child: const Icon(Icons.edit_outlined, color: Color(0xFF002347), size: 22),
                    ),
                    
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF002347), borderRadius: BorderRadius.circular(10)),
                      child: const Text("Tersedia", style: TextStyle(color: Colors.white, fontSize: 10)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF002347) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF002347)),
      ),
      child: Center(
        child: Text(
          label, 
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF002347),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon) {
    return Container(
      width: 160, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF002347), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20), 
          const SizedBox(width: 10), 
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }
}