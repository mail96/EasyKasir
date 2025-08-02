// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _cartItems = [];
  double _total = 0;
  double _discount = 0;
  String _paymentMethod = 'cash';

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      // Cek jika produk sudah ada di keranjang
      int index = _cartItems.indexWhere((item) => item['productId'] == product['productId']);
      
      if (index != -1) {
        _cartItems[index]['quantity'] += 1;
        _cartItems[index]['subtotal'] = _cartItems[index]['quantity'] * _cartItems[index]['price'];
      } else {
        _cartItems.add({
          ...product,
          'quantity': 1,
          'subtotal': product['price']
        });
      }
      
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + item['subtotal']);
    setState(() {
      _total = subtotal - _discount;
    });
  }

  Future<void> _processPayment() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Keranjang kosong')));
      return;
    }

    try {
      // await _firestore.collection('transactions').add({
      //   'dateTime': DateTime.now(),
      //   'items': _cartItems,
      //   'paymentMethod': _paymentMethod,
      //   'total': _total,
      //   'discount': _discount,
      //   'grandTotal': _total,
      //   'cashierId': 'current_user_id', // Ganti dengan ID user sesungguhnya
      // });

      // Reset transaksi setelah berhasil
      setState(() {
        _cartItems = [];
        _total = 0;
        _discount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi berhasil')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi Penjualan')),
      body: Column(
        children: [
          // Input Produk
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                var item = _cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('${item['quantity']} x ${item['price']}'),
                  trailing: Text('${item['subtotal']}'),
                );
              },
            ),
          ),
          
          // Total dan Diskon
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:'),
                    Text('$_total'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Diskon:'),
                    Text('$_discount'),
                  ],
                ),
              ],
            ),
          ),
          
          // Metode Pembayaran
          DropdownButton<String>(
            value: _paymentMethod,
            items: ['cash', 'transfer', 'card'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _paymentMethod = newValue!;
              });
            },
          ),
          
          // Tombol Proses
          ElevatedButton(
            onPressed: _processPayment,
            child: Text('Proses Pembayaran'),
          ),
        ],
      ),
    );
  }
}