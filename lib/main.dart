import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latihan1/auth/login.dart'; // Gunakan path lengkap agar LoginPage dikenali

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ganti URL dan ANON_KEY dengan milikmu dari Dashboard Supabase
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), 
    );
  }
}