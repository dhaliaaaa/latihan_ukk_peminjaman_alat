import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersetujuanPage extends StatefulWidget {
  const PersetujuanPage({super.key});

  @override
  State<PersetujuanPage> createState() => _PersetujuanPageState();
}

class _PersetujuanPageState extends State<PersetujuanPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Color navyColor = const Color(0xFF002347);

  // 1. FUNGSI UPDATE STATUS (SETUJU/TOLAK)
  Future<void> _updateStatus(int id, String status) async {
    try {
      await supabase
          .from('peminjaman')
          .update({'status': status}) // Mengubah status di DB
          .eq('id_peminjaman', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permintaan berhasil $status"),
            backgroundColor: status == 'disetujui' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal update: $e");
    }
  }

  // 2. STREAM REALTIME
  Stream<List<Map<String, dynamic>>> _getPantauPengajuan() {
    return supabase
        .from('peminjaman')
        .stream(primaryKey: ['id_peminjaman'])
        .eq('status', 'ajukan peminjaman')
        .order('tgl_pinjam', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPantauPengajuan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada pengajuan baru"));
                }

                final dataPeminjaman = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: dataPeminjaman.length,
                  itemBuilder: (context, index) {
                    return _buildCardPersetujuan(dataPeminjaman[index]);
                  },
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
      padding: const EdgeInsets.only(top: 60, bottom: 25, left: 25, right: 25),
      decoration: BoxDecoration(color: navyColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Hallo Petugas", 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("petugas1@gmail.com", style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 5),
              Text("Online", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 50),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari petugas...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: navyColor, borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: const [
                Text("Filter tanggal", style: TextStyle(color: Colors.white)),
                Icon(Icons.expand_more, color: Colors.white),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPersetujuan(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(item['nama_peminjam'] ?? "Siswa", 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("siswa@gmail.com"),
            trailing: const Icon(Icons.more_vert),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: supabase.from('alat').select().eq('id_alat', item['id_alat']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final alat = snapshot.data!.first;
                      final String? fotoUrl = alat['foto_url']; // Kolom baru Anda

                      return Row(
                        children: [
                          // 3. MENAMPILKAN FOTO ALAT DARI URL
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: fotoUrl != null && fotoUrl.isNotEmpty
                                ? Image.network(
                                    fotoUrl,
                                    width: 80, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _placeholderFoto(),
                                  )
                                : _placeholderFoto(),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alat['nama_alat'] ?? "Alat", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(item['tgl_pinjam'].toString().substring(0, 10),
                                style: const TextStyle(color: Colors.grey)),
                            ],
                          )
                        ],
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 15),
                // 4. TOMBOL AKSI
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(item['id_peminjaman'], 'ditolak'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        child: const Text("Tolak"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(item['id_peminjaman'], 'disetujui'),
                        style: ElevatedButton.styleFrom(backgroundColor: navyColor, foregroundColor: Colors.white),
                        child: const Text("Setuju"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderFoto() {
    return Container(
      width: 80, height: 60,
      color: Colors.grey[200],
      child: const Icon(Icons.laptop, color: Colors.grey),
    );
  }
}