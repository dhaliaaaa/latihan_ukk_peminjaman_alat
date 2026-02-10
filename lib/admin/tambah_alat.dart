import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TambahAlatPage extends StatefulWidget {
  const TambahAlatPage({super.key});

  @override
  State<TambahAlatPage> createState() => _TambahAlatPageState();
}

class _TambahAlatPageState extends State<TambahAlatPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  int _jumlahTersedia = 0;
  
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoading = false;

  XFile? _pickedImage; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Mengambil data kategori untuk dropdown
  Future<void> _fetchCategories() async {
    try {
      final data = await supabase.from('kategori').select().order('nama_kategori');
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil kategori: $e");
    }
  }

  // Memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  // FUNGSI UPLOAD DENGAN PENANGANAN SPASI NAMA BUCKET
  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    try {
      final bytes = await _pickedImage!.readAsBytes();
      final fileExt = _pickedImage!.path.split('.').last;
      
      // Bersihkan nama file dari spasi untuk menghindari broken link
      final String safeFileName = _namaController.text
          .trim()
          .replaceAll(RegExp(r'[^\w\s]+'), '') 
          .replaceAll(' ', '_');
          
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$safeFileName.$fileExt";
      final path = "alat_images/$fileName";

      // 1. Upload ke Bucket 'asset ukk'
      await supabase.storage.from('asset ukk').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: false),
      );

      // 2. AMBIL URL & HANDLE SPASI BUCKET (PENTING)
      // Mengonversi spasi pada 'asset ukk' menjadi '%20' agar valid secara URL
      final String publicUrl = supabase.storage
          .from('asset ukk')
          .getPublicUrl(path)
          .replaceAll(' ', '%20'); 
      
      return publicUrl;
    } catch (e) {
      debugPrint("Gagal upload ke storage: $e");
      return null;
    }
  }

  // SIMPAN DATA LENGKAP KE DATABASE
  Future<void> _simpanAlat() async {
    if (_namaController.text.trim().isEmpty || _selectedCategory == null || _pickedImage == null) {
      _showSnackBar("Nama, Kategori, dan Foto wajib diisi!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Jalankan Upload terlebih dahulu
      final String? imageUrl = await _uploadImage();

      if (imageUrl == null) {
        throw "Gagal mendapatkan URL foto. Pastikan Policy SELECT di Bucket 'asset ukk' sudah diatur ke 'true'.";
      }

      // 2. Masukkan ke tabel 'alat'
      await supabase.from('alat').insert({
        'nama_alat': _namaController.text.trim(),
        'id_kategori': _selectedCategory!['id_kategori'],
        'stok': _jumlahTersedia,
        'deskripsi': _deskripsiController.text.trim(),
        'status': 'tersedia',
        'kode_aset': imageUrl, 
      });

      if (mounted) {
        _showSnackBar("Alat Berhasil Ditambahkan!", Colors.green);
        Navigator.pop(context, true); 
      }
    } catch (e) {
      debugPrint("Error Simpan: $e");
      if (mounted) {
        String errorMsg = e.toString();
        
        // Proteksi jika user belum mengubah tipe data varchar(100) ke text
        if (errorMsg.contains("22001")) {
          errorMsg = "Gagal: Kolom 'kode_aset' di Supabase harus diubah jadi TEXT agar muat link foto!";
        } else if (errorMsg.contains("403")) {
          errorMsg = "Gagal: Izin ditolak (Policy RLS). Cek Policy Storage/Table kamu.";
        }
        
        _showSnackBar(errorMsg, Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D2B52)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      const SizedBox(height: 30),
                      _buildLabel("Nama Alat"),
                      _buildTextField(_namaController, "Masukkan nama alat..."),
                      _buildLabel("Kategori"),
                      _buildDropdownKategori(),
                      _buildLabel("Jumlah Tersedia"),
                      _buildCounter(),
                      _buildLabel("Deskripsi"),
                      _buildTextField(_deskripsiController, "Deskripsi alat...", maxLines: 4),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D2B52),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(child: Center(child: Text("Tambah Alat", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _pickedImage != null
                    ? (kIsWeb ? Image.network(_pickedImage!.path, fit: BoxFit.cover) : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 55, color: Color(0xFF0D2B52)),
                          SizedBox(height: 5),
                          Text("Pilih Foto", style: TextStyle(color: Color(0xFF0D2B52), fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            Positioned(bottom: -5, right: -5, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF0D2B52), shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 20)))
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8, top: 15), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2B52), fontSize: 16)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
      ),
    );
  }

  Widget _buildDropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D2B52), size: 30),
          hint: const Text("Pilih Kategori"),
          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat['nama_kategori']))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$_jumlahTersedia Unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2B52))),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 30), onPressed: () => setState(() { if (_jumlahTersedia > 0) _jumlahTersedia--; })),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D2B52), size: 30), onPressed: () => setState(() => _jumlahTersedia++)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _simpanAlat,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2B52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
        child: const Text("Simpan Alat ke Katalog", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}