import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/dashboard_admin.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  String? _emailError;
  String? _passwordError;
  String? _generalError; 

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = "Email tidak boleh kosong");
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null && mounted) {
        try {
          final userData = await Supabase.instance.client
              .from('user') 
              .select('role')
              .eq('id_user', res.user!.id)
              .maybeSingle();

          if (userData == null) {
            throw 'Profil user tidak ditemukan di tabel database.';
          }

          if (mounted) {
            if (userData['role'] == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const dashboard_admin()),
              );
            } else {
              setState(() => _generalError = "Akses ditolak: Anda bukan Admin");
              await Supabase.instance.client.auth.signOut();
            }
          }
        } catch (e) {
          print("DETAIL ERROR DATABASE: $e");
          setState(() => _generalError = "Gagal memverifikasi Role. Pastikan tabel 'user' tersedia.");
          await Supabase.instance.client.auth.signOut();
        }
      }
    } on AuthException catch (e) {
      setState(() => _generalError = e.message);
    } catch (e) {
      print("DETAIL ERROR UMUM: $e");
      setState(() => _generalError = "Koneksi gagal: Silahkan cek internet Anda.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- TAMBAHAN ASSET GAMBAR DI SINI ---
              // Pastikan path assets/logo.png sesuai dengan pubspec.yaml kamu
              Image.asset(
                'assets/image/LOGO.png', 
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  // Jika gambar tidak ditemukan, tampilkan ikon default agar tidak error
                  return const Icon(Icons.lock_person, size: 80, color: Color(0xFF0D2B52));
                },
              ),
              // -------------------------------------
              
              const SizedBox(height: 10),
              const Text(
                "LOGIN ADMIN",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D2B52)),
              ),
              const SizedBox(height: 30),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  errorText: _emailError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _passwordError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              
              if (_generalError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    _generalError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
                
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LOGIN',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}