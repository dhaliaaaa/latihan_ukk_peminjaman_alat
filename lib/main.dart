import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login.dart'; 
import 'admin/dashboard_admin.dart';    
import 'petugas/dashboard_petugas.dart'; 
import 'peminjam/dashboard_peminjam.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://aobjqngvgvkvjihhjoqn.supabase.co', 
    anonKey: 'sb_publishable_wIRenG1rs3PiJk-2HOGmnA_BT48CPW9',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinjamin Braka',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002347)),
        useMaterial3: true,
      ),
      home: const AuthGate(), 
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        // Jika tidak ada sesi aktif, tampilkan LoginPage
        if (session == null) {
          return const LoginPage();
        }

        // Jika ada sesi, ambil data role dari tabel 'user'
        return FutureBuilder<Map<String, dynamic>>(
          key: ValueKey(session.user.id), // Paksa refresh saat ganti akun
          future: Supabase.instance.client
              .from('user') // Pastikan nama tabel di Supabase adalah 'user'
              .select('role')
              .eq('id_user', session.user.id) // Pastikan nama kolom adalah 'id_user'
              .single(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Jika error (data tidak ditemukan), tampilkan Login kembali
            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return const LoginPage();
            }

            final String role = profileSnapshot.data?['role'] ?? '';

            // CEK ROLE SECARA SPESIFIK
            if (role == 'admin') {
              return const DashboardAdmin();
            } else if (role == 'petugas') {
              return const DashboardPetugas();
            } else if (role == 'peminjam') {
              return const DashboardPeminjam();
            } else {
              // Jika role tidak dikenal, lempar ke login
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}