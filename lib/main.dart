import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login.dart';

import 'admin/dashboard_admin.dart';    

import 'petugas/dashboard_petugas.dart';

import 'peminjam/dashboard_peminjam.dart';

// TAMBAHKAN IMPORT BARU DISINI

import 'peminjam/main_navigation_peminjam.dart';



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

        return FutureBuilder<Map<String, dynamic>?>(

          key: ValueKey(session.user.id), // Paksa refresh saat ganti akun

          future: Supabase.instance.client

              .from('user') // Nama tabel di Supabase

              .select('role')

              .eq('id_user', session.user.id) // Nama kolom id_user

              .maybeSingle(), // Menggunakan maybeSingle agar tidak crash jika data null

          builder: (context, profileSnapshot) {

            if (profileSnapshot.connectionState == ConnectionState.waiting) {

              return const Scaffold(

                body: Center(child: CircularProgressIndicator()),

              );

            }



            // Jika error atau data profil tidak ditemukan

            if (profileSnapshot.hasError || profileSnapshot.data == null) {

              return const LoginPage();

            }



            final String role = profileSnapshot.data?['role'] ?? '';



            // CEK ROLE SECARA SPESIFIK

            if (role == 'admin') {

              return const DashboardAdmin();

            } else if (role == 'petugas') {

              return const DashboardPetugas();

            } else if (role == 'peminjam') {

              // UPDATE: Sekarang mengarah ke file Navigasi Baru yang Anda buat

              return const MainNavigationPeminjam();

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