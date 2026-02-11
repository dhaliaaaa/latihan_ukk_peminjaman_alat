import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KirimPengajuanPage extends StatefulWidget {
  final Map<String, dynamic> alat;
  final int jumlah;

  const KirimPengajuanPage({super.key, required this.alat, required this.jumlah});

  @override
  State<KirimPengajuanPage> createState() => _KirimPengajuanPageState();
}

class _KirimPengajuanPageState extends State<KirimPengajuanPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();
  DateTime? _tglPinjam;
  DateTime? _tglKembali;
  bool _isLoading = false;

  final Color navyColor = const Color(0xFF002347);
  final Color secondaryNavy = const Color(0xFF0D2E5C);

  Future<void> _kirimData() async {
    // Validasi input
    if (_namaController.text.isEmpty || _tglPinjam == null || _tglKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      
      // INSERT DATA KE SUPABASE
      await supabase.from('peminjaman').insert({
        'id_user': user?.id,
        'id_alat': widget.alat['id_alat'],
        'nama_peminjam': _namaController.text, // Kolom baru yang Anda tambahkan
        'tgl_pinjam': _tglPinjam!.toIso8601String(),
        'tgl_kembali': _tglKembali!.toIso8601String(),
        'jumlah': widget.jumlah,
        // SINKRONISASI: Status harus 'ajukan peminjaman' agar muncul di Petugas
        'status': 'ajukan peminjaman', 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengajuan berhasil dikirim!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      // Menampilkan pesan error jika insert gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengajuan Peminjaman", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: navyColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Alat Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.alat['kode_aset'] ?? '',
                      width: 70, height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.alat['nama_alat'] ?? 'Tanpa Nama',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navyColor)),
                        Text("Tersedia: ${widget.alat['stok']}",
                          style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text("${widget.jumlah}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: secondaryNavy)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _inputField("Nama Peminjam", "Masukkan Nama anda", _namaController),
            _dateField("Tanggal Pinjaman", _tglPinjam, (date) => setState(() => _tglPinjam = date)),
            _dateField("Tanggal Kembali", _tglKembali, (date) => setState(() => _tglKembali = date)),
            const SizedBox(height: 40),
            
            // Button Kirim
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirimData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Kirim Pengajuan",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: navyColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F4F8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: secondaryNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _dateField(String label, DateTime? value, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: navyColor)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: navyColor,
                      onPrimary: Colors.white,
                      onSurface: navyColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null ? "Pilih Tanggal" : "${value.day}/${value.month}/${value.year}",
                  style: TextStyle(color: value == null ? Colors.black54 : Colors.black87),
                ),
                Icon(Icons.calendar_today_rounded, size: 20, color: secondaryNavy),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}