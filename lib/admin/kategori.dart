import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_alat.dart'; 
import 'tambah_alat.dart'; 

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  int? selectedIdKategori; 

  Stream<List<Map<String, dynamic>>> _getKategoriStream() {
    return supabase.from('kategori').stream(primaryKey: ['id_kategori']);
  }

  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    if (selectedIdKategori != null) {
      return supabase
          .from('alat')
          .stream(primaryKey: ['id_alat'])
          .eq('id_kategori', selectedIdKategori!);
    }
    return supabase.from('alat').stream(primaryKey: ['id_alat']);
  }

  Future<void> _deleteAlat(int idAlat) async {
    try {
      await supabase.from('alat').delete().match({'id_alat': idAlat});
    } catch (e) {
      debugPrint("Error hapus: $e");
    }
  }

  void _showDeleteDialog(int idAlat, String namaAlat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("HAPUS", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002347)))),
        content: Text("Apakah anda yakin untuk menghapus produk $namaAlat?", textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _deleteAlat(idAlat);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF002347),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Katalog Alat", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
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

              // --- FILTER KATEGORI ---
              const SizedBox(height: 15),
              SizedBox(
                height: 35,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getKategoriStream(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildFilterChip("Semua", null);
                        final cat = categories[index - 1];
                        return _buildFilterChip(cat['nama_kategori'], cat['id_kategori']);
                      },
                    );
                  },
                ),
              ),

              // --- GRID DAFTAR ALAT ---
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getAlatStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final listAlat = snapshot.data ?? [];
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 100), 
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 15, mainAxisSpacing: 15),
                      itemCount: listAlat.length,
                      itemBuilder: (context, index) => _buildCardAlat(listAlat[index]),
                    );
                  },
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFabAction("Tambah Alat", Icons.post_add_rounded, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahAlatPage()),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? id) {
    bool isActive = selectedIdKategori == id;
    return GestureDetector(
      onTap: () => setState(() { selectedIdKategori = id; }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF002347) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF002347)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 12, color: isActive ? Colors.white : const Color(0xFF002347))),
        ),
      ),
    );
  }

  Widget _buildCardAlat(Map<String, dynamic> alat) {
    // Ambil data stok dari Supabase
    final int stok = alat['stok'] ?? 0;

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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: alat['kode_aset'] != null 
                ? Image.network(
                    alat['kode_aset'], 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                  )
                : const Icon(Icons.image_not_supported, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              alat['nama_alat'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002347)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF002347), size: 22),
                  onPressed: () => _showDeleteDialog(alat['id_alat'], alat['nama_alat'] ?? ""),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF002347), size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAlatPage(alat: alat),
                      ),
                    );
                  },
                ),
                
                // --- PERUBAHAN DI SINI: BAGIAN STOK ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    // Warna berubah jadi merah jika stok 0
                    color: stok > 0 ? const Color(0xFF002347) : Colors.red.shade800, 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(
                    "Tersedia: $stok", 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF002347),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), 
                blurRadius: 8, 
                offset: const Offset(0, 4)
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}