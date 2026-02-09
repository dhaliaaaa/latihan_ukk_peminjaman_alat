import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahKategoriPage extends StatefulWidget {
  const TambahKategoriPage({super.key});

  @override
  State<TambahKategoriPage> createState() => _TambahKategoriPageState();
}

class _TambahKategoriPageState extends State<TambahKategoriPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final data = await supabase.from('kategori').select().order('nama_kategori');
    setState(() => categories = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _addCategory(String name) async {
    if (name.isEmpty) return;
    await supabase.from('kategori').insert({'nama_kategori': name});
    _fetchCategories();
  }

  Future<void> _deleteCategory(int id) async {
    await supabase.from('kategori').delete().eq('id_kategori', id);
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tambah Kategori",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2B52)),
            ),
            const SizedBox(height: 20),
            
            // List Kategori yang sudah ada
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(
                  children: categories.map((cat) => _buildItemKategori(cat['nama_kategori'], cat['id_kategori'])).toList(),
                ),
              ),
            ),

            // Field untuk input kategori baru
            _buildInputKategori(),

            const SizedBox(height: 20),

            // Tombol Simpan & Batal (Navy Row)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D2B52),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                        label: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const VerticalDivider(color: Colors.white54, thickness: 1, indent: 10, endIndent: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemKategori(String nama, int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2B52))),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF8B0000)),
            onPressed: () => _deleteCategory(id),
          ),
        ],
      ),
    );
  }

  Widget _buildInputKategori() {
    TextEditingController controller = TextEditingController();
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Tambah Kategori", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF0D2B52)),
            onPressed: () => _addCategory(controller.text),
          ),
        ],
      ),
    );
  }
}