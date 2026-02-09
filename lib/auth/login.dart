import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; 
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() => _errorMessage = null);

    // Validasi input sederhana
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Masukkan email");
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Masukkan password");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. Proses Autentikasi Supabase
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. KUNCI SUKSES ROLE: 
      // Kita TIDAK menggunakan Navigator.push di sini.
      // Begitu login berhasil, AuthGate di main.dart (StreamBuilder) akan 
      // otomatis mendeteksi sesi baru, mengecek tabel 'user', 
      // dan menampilkan dashboard yang sesuai secara otomatis.
      
    } on AuthException catch (error) {
      setState(() {
        if (error.message.contains("Invalid login credentials")) {
          _errorMessage = "Email atau Password salah!";
        } else {
          _errorMessage = error.message;
        }
      });
    } catch (error) {
      setState(() => _errorMessage = "Terjadi kesalahan tak terduga");
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Biru Melengkung
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xFF002347),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/image/LOGO.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.business, color: Color(0xFF002347), size: 80),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "PINJAMIN",
                      style: TextStyle(
                        color: Color(0xFF002347),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      "BRAKA",
                      style: TextStyle(
                        color: Color(0xFF002347),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Input Email
                    _buildTextField(
                      controller: _emailController,
                      hint: "Enter email",
                      icon: Icons.email,
                      hasError: _errorMessage != null && _errorMessage!.toLowerCase().contains("email"),
                    ),
                    const SizedBox(height: 20),
                    
                    // Input Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Enter password",
                      icon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      isPassword: _obscurePassword, 
                      isPasswordField: true, 
                      hasError: _errorMessage != null && (_errorMessage!.toLowerCase().contains("password") || _errorMessage!.contains("salah")),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // Tombol Login
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002347),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordField = false,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: hasError 
            ? Colors.red.withAlpha(128) // Pengganti withOpacity agar lebih modern
            : Colors.grey.shade300
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: GestureDetector(
            onTap: isPasswordField ? () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            } : null,
            child: Icon(icon, color: Colors.black, size: 20),
          ),
        ),
      ),
    );
  }
}