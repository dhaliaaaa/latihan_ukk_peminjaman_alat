import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahAlatPage extends StatefulWidget {
  const TambahAlatPage({super.key});

  @override
  State<TambahAlatPage> createState() => _TambahAlatPageState();
}

class _TambahAlatPageState extends State<TambahAlatPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Controller untuk Input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  int _jumlahTersedia = 0;
  
  // Data Kategori dari Supabase
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // --- AMBIL DATA KATEGORI UNTUK DROPDOWN ---
  Future<void> _fetchCategories() async {
    final data = await supabase.from('kategori').select().order('nama_kategori');
    setState(() {
      _categories = List<Map<String, dynamic>>.from(data);
    });
  }

  // --- FUNGSI SIMPAN KE SUPABASE ---
  Future<void> _simpanAlat() async {
    if (_namaController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Kategori harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.from('alat').insert({
        'nama_alat': _namaController.text,
        'id_kategori': _selectedCategory!['id_kategori'],
        'stok': _jumlahTersedia, // Sesuaikan nama kolom di DB Anda (stok/jumlah)
        'deskripsi': _deskripsiController.text,
        'status': 'tersedia',
        // 'foto_alat': url_foto, // Jika Anda ingin upload image nantinya
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alat Berhasil Ditambahkan"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2B52),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tambah Alat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN TAMBAH FOTO ---
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 50, color: Color(0xFF0D2B52)),
                            Text("Tambah Foto", style: TextStyle(color: Color(0xFF0D2B52), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Color(0xFF0D2B52), shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- INPUT NAMA ALAT ---
                _buildLabel("Nama Alat"),
                _buildTextField(_namaController, "Masukkan nama alat"),

                // --- DROPDOWN KATEGORI ---
                _buildLabel("Kategori"),
                _buildDropdownKategori(),

                // --- JUMLAH TERSEDIA ---
                _buildLabel("Jumlah Tersedia"),
                _buildCounter(),

                // --- DESKRIPSI ---
                _buildLabel("Deskripsi"),
                _buildTextField(_deskripsiController, "Tambahkan deskripsi...", maxLines: 4),

                const SizedBox(height: 40),

                // --- TOMBOL SIMPAN ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _simpanAlat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2B52))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text("Pilih Kategori"),
          items: _categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat['nama_kategori']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("$_jumlahTersedia", style: const TextStyle(fontSize: 16)),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_box, color: Color(0xFF0D2B52)),
                onPressed: () => setState(() => _jumlahTersedia++),
              ),
              IconButton(
                icon: const Icon(Icons.indeterminate_check_box, color: Color(0xFF0D2B52)),
                onPressed: () => setState(() {
                  if (_jumlahTersedia > 0) _jumlahTersedia--;
                }),
              ),
            ],
          )
        ],
      ),
    );
  }
}