// lib/widgets/custom_drawer.dart

import 'package:easy_kasir/home_page.dart';
import 'package:easy_kasir/login_page.dart'; // Import halaman login
import 'package:easy_kasir/product_page.dart';
import 'package:flutter/material.dart';
import '../transaction_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fungsi untuk proses logout
    Future<void> _logout() async {
      try {
        await FirebaseAuth.instance.signOut();
        // Setelah logout, navigasikan kembali ke halaman login
        // pushAndRemoveUntil akan menghapus semua halaman sebelumnya
        // dari stack navigasi, sehingga pengguna tidak bisa kembali
        // ke halaman beranda dengan tombol back.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Tangani error jika terjadi
        print("Error during logout: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
        );
      }
    }

    return Drawer(
      child: ListView(
        // Penting: Hilangkan padding di bagian atas ListView
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header Drawer dengan gradasi
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.yellow.shade200, // Kuning muda
                  Colors.white, // Putih
                ],
              ),
            ),
            child: const Text(
              'Menu KasirKu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Opsi untuk "Beranda"
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          // Opsi untuk "Produk"
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.black),
            title: const Text('Produk'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('Transaksi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionScreen(cartItems: []),
                ),
              );
            },
          ),
          const Divider(), // Tambahkan garis pemisah
          // Tombol Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
