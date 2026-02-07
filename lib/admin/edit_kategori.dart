import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKategoriPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditKategoriPage({super.key, required this.item});

  @override
  State<EditKategoriPage> createState() => _EditKategoriPageState();
}

class _EditKategoriPageState extends State<EditKategoriPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late TextEditingController _namaController;
  late TextEditingController _gambarController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item['nama_kategori']);
    _gambarController = TextEditingController(text: widget.item['kode_alat']);
  }

  Future<void> _updateKategori() async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('kategori').update({
        'nama_kategori': _namaController.text,
        'kode_alat': _gambarController.text,
      }).match({'id_kategori': widget.item['id_kategori']});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil diperbarui")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: $e")),
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
            // --- HEADER SESUAI DESAIN ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    color: Color(0xFF002347),
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
                // Preview Gambar Kartu
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: _gambarController.text.startsWith('http')
                                  ? Image.network(_gambarController.text, fit: BoxFit.contain)
                                  : const Icon(Icons.image, size: 60, color: Colors.grey),
                            ),
                          ),
                        ),
                        // Tombol Pensil Edit
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle, // PERBAIKAN: BoxShape, bukan BoxCircle
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 22, color: Color(0xFF002347)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // --- FORM INPUT SESUAI DESAIN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  _buildOutlineInput("Nama", _namaController),
                  const SizedBox(height: 25),
                  _buildOutlineInput("URL Gambar (Kode Alat)", _gambarController),
                  
                  const SizedBox(height: 80),

                  // --- BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBDBDBD),
                            elevation: 5,
                            shadowColor: Colors.black45,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002347),
                            elevation: 5,
                            shadowColor: Colors.black45,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _updateKategori,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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

  // Widget Helper untuk Textfield agar label berada di garis (Outline)
  Widget _buildOutlineInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (val) {
        if (label.contains("URL")) setState(() {}); // Preview update otomatis
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF002347), fontWeight: FontWeight.bold, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Membuat label selalu di atas
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF002347), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF002347), width: 2),
        ),
      ),
    );
  }
}