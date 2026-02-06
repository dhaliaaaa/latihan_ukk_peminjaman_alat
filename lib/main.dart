import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login.dart'; // Menggunakan path relatif agar pasti ketemu

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
      // Tanpa 'const' karena LoginPage biasanya punya controller dinamis
      home: LoginPage(), 
    );
  }
}