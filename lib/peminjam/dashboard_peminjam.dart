import 'package:flutter/material.dart';

class DashboardPeminjam extends StatelessWidget {
  const DashboardPeminjam({super.key});

  @override
  Widget build(BuildContext context) {
    // HAPUS Scaffold di sini agar tidak double navigasi
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER BIRU NAVY
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
          decoration: const BoxDecoration(color: Color(0xFF002347)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Halo, Peminjam!", 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              // ROW STATUS BADGES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusBadge("1 Aktif", const Color(0xFF6236FF)),
                  _statusBadge("12 Selesai", const Color(0xFF00B14F)),
                  _statusBadge("1 Terlambat", const Color(0xFFFF3B30), isWarning: true),
                ],
              ),
            ],
          ),
        ),
        
        // KONTEN SEDANG DIPINJAM
        const Padding(
          padding: EdgeInsets.fromLTRB(25, 30, 25, 15),
          child: Text("Sedang Dipinjam", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildBorrowItem("Apple Macbook Air 2022", "INV-01-2026", "Kembali dalam: 5 hari", Colors.green),
              _buildBorrowItem("SanDisk 512GB Ultra Dual", "INV-01-2026", "Terlambat: 2 hari", Colors.red, isLate: true),
              _buildBorrowItem("Proyektor Portable", "INV-01-2026", "Kembali dalam: 8 hari", Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color, {bool isWarning = false}) {
    return Container(
      width: 105, height: 75,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWarning) const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
            if (isWarning) const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowItem(String title, String id, String info, Color infoColor, {bool isLate = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            width: 80, height: 60,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.inventory_2, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("ID: $id", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isLate) Icon(Icons.warning, color: infoColor, size: 14),
                    if (isLate) const SizedBox(width: 4),
                    Text(info, style: TextStyle(color: infoColor, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}