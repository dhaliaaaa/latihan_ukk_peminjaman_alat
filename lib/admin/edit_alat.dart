import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditAlatPage extends StatefulWidget {
  final Map<String, dynamic> alat;

  const EditAlatPage({super.key, required this.alat});

  @override
  _EditAlatPageState createState() => _EditAlatPageState();
}

class _EditAlatPageState extends State<EditAlatPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;
  
  String? _imageUrl; 
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.alat['nama_alat']?.toString() ?? "");
    _stokController = TextEditingController(text: widget.alat['stok']?.toString() ?? "0");
    _deskripsiController = TextEditingController(text: widget.alat['deskripsi']?.toString() ?? "");
    
    // MENGGUNAKAN KOLOM kode_aset sesuai struktur tabel Supabase kamu
    _imageUrl = widget.alat['kode_aset']?.toString();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH & UPLOAD GAMBAR ---
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompresi gambar agar tidak terlalu berat
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final bytes = await image.readAsBytes(); 

      // Pembersihan nama file (Mengganti spasi dengan underscore agar tidak error InvalidKey)
      final String safeName = _namaController.text.replaceAll(' ', '_');
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$safeName.jpg";
      final path = 'uploads/$fileName';

      // Upload ke bucket 'asset ukk'
      await supabase.storage.from('asset ukk').uploadBinary(
        path, 
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      // Ambil Public URL setelah berhasil upload
      final String newUrl = supabase.storage.from('asset ukk').getPublicUrl(path);

      setState(() {
        _imageUrl = newUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto berhasil diunggah!"), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI UPDATE DATA ---
  Future<void> _updateAlat() async {
    if (_namaController.text.isEmpty || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan stok tidak boleh kosong"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // UPDATE DATA KE TABEL 'alat'
      // Pastikan 'kode_aset' di Supabase sudah bertipe 'text' agar tidak 'value too long'
      await supabase.from('alat').update({
        'nama_alat': _namaController.text,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'deskripsi': _deskripsiController.text,
        'kode_aset': _imageUrl, 
      }).eq('id_alat', widget.alat['id_alat']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        // Mengirim 'true' kembali ke halaman utama agar halaman utama tahu harus refresh data
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 30),
              child: Column(
                children: [
                  _buildStyledTextField("Nama", _namaController),
                  const SizedBox(height: 25),
                  _buildStyledTextField("Stok", _stokController, isNumber: true),
                  const SizedBox(height: 25),
                  _buildStyledTextField("Deskripsi", _deskripsiController, maxLines: 4),
                  const SizedBox(height: 50),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Color(0xFF0D2B52),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
        ),
        Positioned(
          top: 50,
          left: 15,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 160,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: _imageUrl != null && _imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              _imageUrl!, 
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 5),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Color(0xFF0D2B52), size: 18),
                      onPressed: _isLoading ? null : _pickAndUploadImage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2B52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: _isLoading ? null : _updateAlat,
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D2B52), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D2B52), width: 2)),
            ),
          ),
        ),
        Positioned(
          left: 15,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            color: Colors.white,
            child: Text(label, style: const TextStyle(color: Color(0xFF0D2B52), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}