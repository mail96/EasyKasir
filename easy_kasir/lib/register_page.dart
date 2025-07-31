import 'package:flutter/material.dart';
import 'login_page.dart'; // Import halaman login

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Card untuk logo KasirKu (konsisten dengan login)
              Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 90),
                  child: Text(
                    'KasirKu',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Card untuk form register
              Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Buat Akun',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Mudahkan manajemen bisnismu dengan Kasirku.",
                          style: TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(label: 'Nama Lengkap'),
                        const SizedBox(height: 14),
                        _buildTextField(label: 'Email'),
                        const SizedBox(height: 14),
                        _buildTextField(
                          label: 'Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          label: 'Konfirmasi Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () {
                              // Logic register
                              // Setelah register berhasil, navigasi kembali ke login
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Kembali ke halaman login
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Sudah punya akun? Masuk',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off, color: Colors.white54)
            : null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}