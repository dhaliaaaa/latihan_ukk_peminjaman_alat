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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // --- FUNGSI HAPUS ALAT ---
  Future<void> _deleteAlat(int id, String nama) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Alat"),
        content: Text("Apakah kamu yakin ingin menghapus $nama?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await supabase.from('alat').delete().eq('id_alat', id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$nama berhasil dihapus")),
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
  }

  // --- FUNGSI EDIT ALAT ---
  void _editAlat(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Fitur Edit untuk ${item['nama_alat']} sedang disiapkan")),
    );
  }

  // --- STREAM DATA ALAT ---
  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    return supabase
        .from('alat')
        .stream(primaryKey: ['id_alat'])
        .eq('id_kategori', widget.idKategori)
        .order('nama_alat', ascending: true);
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getAlatStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    
                    var data = snapshot.data ?? [];

                    // Logika Filter Pencarian Sederhana
                    if (_searchQuery.isNotEmpty) {
                      data = data.where((item) => 
                        item['nama_alat'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (data.isEmpty) {
                      return const Center(child: Text("Tidak ada alat ditemukan"));
                    }

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
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

          // TOMBOL TAMBAH MELAYANG
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFabButton("Tambah Alat", Icons.post_add_rounded, _goToTambahAlat),
                const SizedBox(height: 10),
                _buildFabButton("Tambah Kategori", Icons.dashboard_customize_rounded, _openTambahKategori),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2B52),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), 
                blurRadius: 8, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D2B52),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), 
          bottomRight: Radius.circular(30)
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.kategori.toUpperCase(), 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                )
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white), 
                onPressed: () => Navigator.pop(context)
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(30)
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
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
    // AMBIL STOK DARI DATABASE
    final int stok = item['stok'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: item['foto_alat'] != null 
                ? Image.network(
                    item['foto_alat'], 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  )
                : const Icon(Icons.laptop, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            item['nama_alat'] ?? 'Unit', 
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Hapus
                GestureDetector(
                  onTap: () => _deleteAlat(item['id_alat'], item['nama_alat'] ?? 'Alat'),
                  child: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
                ),
                // Tombol Edit
                GestureDetector(
                  onTap: () => _editAlat(item),
                  child: const Icon(Icons.edit_outlined, size: 22, color: Colors.blueAccent),
                ),
                // BADGE TERSEDIA (Dinamis)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // Warna merah jika stok kosong, biru jika ada
                    color: stok > 0 ? const Color(0xFF0D2B52) : Colors.red.shade900, 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    "Tersedia: $stok", 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 9,
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}