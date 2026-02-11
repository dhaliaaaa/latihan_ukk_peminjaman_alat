import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 1. Perbaiki import agar mengarah ke file yang benar
import 'kirim_pengajuan.dart'; 

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  int? selectedIdKategori;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Stream<List<Map<String, dynamic>>> _getKategoriStream() {
    return supabase.from('kategori').stream(primaryKey: ['id_kategori']);
  }

  Stream<List<Map<String, dynamic>>> _getAlatStream() {
    var stream = supabase.from('alat').stream(primaryKey: ['id_alat']);
    if (selectedIdKategori != null) {
      return stream.eq('id_kategori', selectedIdKategori!);
    }
    return stream;
  }

  void _navigasiKeFormPengajuan(Map<String, dynamic> alat) {
    final user = supabase.auth.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silahkan login terlebih dahulu")),
      );
      return;
    }

    if ((alat['stok'] ?? 0) < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok alat habis!"), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. Gunakan Nama Class 'KirimPengajuanPage' sesuai file yang dibuat tadi
    // Jangan lupa kirim 'alat' dan 'jumlah' (default 1)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KirimPengajuanPage(alat: alat, jumlah: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          _buildCategoryFilter(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getAlatStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var dataAlat = snapshot.data ?? [];
                
                if (searchQuery.isNotEmpty) {
                  dataAlat = dataAlat.where((item) => 
                    item['nama_alat'].toString().toLowerCase().contains(searchQuery.toLowerCase())
                  ).toList();
                }

                if (dataAlat.isEmpty) return const Center(child: Text("Alat tidak ditemukan"));

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: dataAlat.length,
                  itemBuilder: (context, index) => _buildCardAlat(dataAlat[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAlat(Map<String, dynamic> alat) {
    final int stok = alat['stok'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: alat['kode_aset'] != null 
                ? Image.network(alat['kode_aset'], fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40)) 
                : const Icon(Icons.image_not_supported, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              alat['nama_alat'] ?? '', 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002347)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text("Stok: $stok", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _navigasiKeFormPengajuan(alat),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: stok > 0 ? const Color(0xFF002347) : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stok > 0 ? "Pinjam" : "Habis", 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF002347),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text("Katalog Alat", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search, color: Color(0xFF002347)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
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
    );
  }

  Widget _buildFilterChip(String label, int? id) {
    bool isActive = selectedIdKategori == id;
    return GestureDetector(
      onTap: () => setState(() => selectedIdKategori = id),
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
}