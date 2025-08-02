// lib/widgets/custom_drawer.dart

import 'package:easy_kasir/home_page.dart';
import 'package:easy_kasir/product_page.dart';
import 'package:flutter/material.dart';
import '../transaction_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Aksi saat "Beranda" diklik
              // Hanya perlu menutup drawer, karena sudah berada di halaman beranda.
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
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
          // Tambahkan ListTile lain di sini jika dibutuhkan
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
        ],
      ),
    );
  }
}
