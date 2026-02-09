import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isLoading = false; // Untuk indikator loading saat simpan

  @override
  void initState() {
    super.initState();
    // Mengambil data awal dengan fallback string kosong atau '0'
    _namaController = TextEditingController(text: widget.alat['nama_alat']?.toString() ?? "");
    _stokController = TextEditingController(text: widget.alat['stok']?.toString() ?? "0");
    _deskripsiController = TextEditingController(text: widget.alat['deskripsi']?.toString() ?? "");
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- FUNGSI UPDATE KE SUPABASE ---
  Future<void> _updateAlat() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama alat tidak boleh kosong"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.from('alat').update({
        'nama_alat': _namaController.text,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'deskripsi': _deskripsiController.text,
      }).eq('id_alat', widget.alat['id_alat']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Mengirim 'true' agar halaman sebelumnya bisa refresh
      }
    } catch (e) {
      debugPrint("Error update: $e");
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
            // --- HEADER NAVY SESUAI DESAIN ---
            Stack(
              children: [
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D2B52), // Navy sesuai desain sebelumnya
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: (widget.alat['kode_aset'] != null && widget.alat['kode_aset'].toString().isNotEmpty)
                                ? Image.network(
                                    widget.alat['kode_aset'], 
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  )
                                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                          // Tombol Edit Gambar
                          Container(
                            margin: const EdgeInsets.only(right: 5, bottom: 5),
                            decoration: const BoxDecoration(
                              color: Colors.white, 
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0D2B52), size: 18),
                              onPressed: () {
                                // Tambahkan logika pilih gambar jika diperlukan
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- FORM INPUT ---
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

                  // --- TOMBOL BATAL & SIMPAN ---
                  Row(
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
                            elevation: 5,
                          ),
                          onPressed: _isLoading ? null : _updateAlat,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0D2B52), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0D2B52), width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          left: 15,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            color: Colors.white,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF0D2B52), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}