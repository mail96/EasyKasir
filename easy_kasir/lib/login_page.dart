import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isSignUp = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  void toggleMode(bool signUpSelected) {
    setState(() => isSignUp = signUpSelected);
    _fadeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Card untuk logo KasirKu
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

              // Card untuk tab & form
              Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 660),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Tab Masuk/Daftar
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            children: [
                              _tabBox(
                                'Masuk',
                                !isSignUp,
                                () => toggleMode(false),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white30,
                              ),
                              _tabBox(
                                'Daftar',
                                isSignUp,
                                () => toggleMode(true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Konten yang berubah
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            key: ValueKey(isSignUp),
                            children: [
                              Text(
                                isSignUp ? 'Buat Akun' : 'Selamat Datang',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isSignUp
                                    ? "Mudahkan manajemen bisnismu dengan Kasirku."
                                    : 'Bergabunglah dengan kami untuk pengalaman manajemen Kasir yang lebih baik.',
                                style: const TextStyle(color: Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(label: 'Email'),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'Password',
                                isPassword: true,
                              ),
                              if (!isSignUp)
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: null,
                                    child: Text(
                                      'Lupa Password?',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: () {},
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
                                  child: Text(
                                    isSignUp ? 'Daftar' : 'Masuk',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _tabBox(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
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
