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

  // --- FUNGSI HAPUS ALAT ---
  Future<void> _deleteAlat(int id, String nama) async {
    // Menampilkan dialog konfirmasi
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
        // Proses hapus di Supabase
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

  // --- FUNGSI EDIT ALAT (Placeholder) ---
  void _editAlat(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Fitur Edit untuk ${item['nama_alat']} sedang disiapkan")),
    );
    // Di sini kamu bisa mengarahkan ke Navigator.push untuk EditAlatPage
  }

  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    return supabase
        .from('alat')
        .stream(primaryKey: ['id_alat'])
        .eq('id_kategori', widget.idKategori);
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
                    
                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return const Center(child: Text("Belum ada alat di kategori ini"));
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
                              childAspectRatio: 0.70, // Sedikit disesuaikan agar muat dengan IconButton
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
                ? Image.network(item['foto_alat'], fit: BoxFit.contain)
                : const Icon(Icons.laptop, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            item['nama_alat'] ?? 'Unit', 
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
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
                // Badge Stok
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B52), 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    "Stok: ${item['stok'] ?? 0}", 
                    style: const TextStyle(color: Colors.white, fontSize: 9)
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}