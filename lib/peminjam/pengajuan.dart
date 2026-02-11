import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getPengajuanStream() {
    final user = supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    return supabase
        .from('peminjaman')
        .stream(primaryKey: ['id_peminjaman'])
        .eq('id_user', user.id)
        .order('tgl_pinjam', ascending: false);
  }

  Future<void> _batalkanPengajuan(dynamic id) async {
    try {
      await supabase.from('peminjaman').delete().eq('id_peminjaman', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengajuan berhasil dibatalkan")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPengajuanStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text("Belum ada data pengajuan.", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  itemCount: data.length,
                  itemBuilder: (context, index) => _buildCard(data[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF002347),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Text(
        "Status Pengajuan Anda",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: supabase.from('alat').select().eq('id_alat', item['id_alat']).maybeSingle(),
      builder: (context, snapAlat) {
        final alat = snapAlat.data;
        final status = item['status'] ?? 'ajukan peminjaman';
        // Ambil URL Foto dari tabel alat
        final String? fotoUrl = alat?['foto_url']; 

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PERBAIKAN: MENAMPILKAN GAMBAR ALAT ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 75, height: 75,
                      color: Colors.grey[100],
                      child: fotoUrl != null && fotoUrl.isNotEmpty
                          ? Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              // Loader saat gambar loading
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                              },
                              // Placeholder jika link mati atau error
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Icon(Icons.inventory_2, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alat?['nama_alat'] ?? "Memuat...", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text("Pinjam: ${item['tgl_pinjam']?.toString().split('T')[0] ?? '-'}", 
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text("Kembali: ${item['tgl_kembali']?.toString().split('T')[0] ?? '-'}", 
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Jumlah: ${item['jumlah']} Unit", 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (status == 'ajukan peminjaman')
                    TextButton.icon(
                      onPressed: () => _confirmDelete(item['id_peminjaman']),
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                      label: const Text("Batalkan", style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'disetujui') color = Colors.green;
    if (status == 'ditolak') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete(dynamic id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan?"),
        content: const Text("Yakin ingin membatalkan antrean ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tidak")),
          TextButton(onPressed: () { _batalkanPengajuan(id); Navigator.pop(ctx); }, child: const Text("Ya, Batal")),
        ],
      ),
    );
  }
}