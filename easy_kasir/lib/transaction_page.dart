import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_page.dart' show formatRupiah;
import 'models/transaction.dart';

class TransactionScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? cartItems;
  final bool isHistoryView;

  const TransactionScreen({
    Key? key,
    this.cartItems,
    this.isHistoryView = false,
  }) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late List<Map<String, dynamic>> _cartItems;
  double _total = 0;
  double _discount = 0;
  String _paymentMethod = 'Tunai';
  List<Transaction> _transactions = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isHistoryView) {
      _cartItems = widget.cartItems!.map((item) {
        return {...item, 'subtotal': item['price'] * item['quantity']};
      }).toList();
      _calculateTotal();
    }
    _loadTransactions();
  }

  void _loadTransactions() async {
    // Ini contoh data dummy, ganti dengan data dari database Anda
    setState(() {
      _transactions = [
        Transaction(
          id: '1',
          dateTime: DateTime.now().subtract(Duration(days: 2)),
          items: [
            {'name': 'Produk 1', 'price': 15000, 'quantity': 2},
            {'name': 'Produk 2', 'price': 20000, 'quantity': 1},
          ],
          paymentMethod: 'Tunai',
          total: 50000,
          discount: 0,
        ),
        Transaction(
          id: '2',
          dateTime: DateTime.now().subtract(Duration(days: 1)),
          items: [
            {'name': 'Produk 3', 'price': 25000, 'quantity': 1},
          ],
          paymentMethod: 'Kartu Debit',
          total: 25000,
          discount: 0,
        ),
      ];
    });
  }

  void _calculateTotal() {
    double subtotal = _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    setState(() {
      _total = subtotal - _discount;
    });
  }

  Future<void> _processPayment() async {
    try {
      // Simpan transaksi baru
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        items: _cartItems,
        paymentMethod: _paymentMethod,
        total: _total,
        discount: _discount,
      );
      
      setState(() {
        _transactions.insert(0, newTransaction);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran berhasil: Rp ${_total.toStringAsFixed(0)}'),
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isHistoryView ? 'Riwayat Transaksi' : 'Transaksi'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: widget.isHistoryView
              ? null
              : TabBar(
                  tabs: [
                    Tab(text: 'Pembayaran'),
                    Tab(text: 'Riwayat'),
                  ],
                ),
        ),
        body: widget.isHistoryView
            ? _buildHistoryView()
            : TabBarView(
                children: [
                  _buildPaymentView(),
                  _buildHistoryView(),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              var item = _cartItems[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text('${item['quantity']} x ${formatRupiah(item['price'])}'),
                trailing: Text(formatRupiah(item['price'] * item['quantity'])),
              );
            },
          ),
        ),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildHistoryView() {
    if (_transactions.isEmpty) {
      return Center(child: Text('Belum ada riwayat transaksi'));
    }

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              'Transaksi #${transaction.id}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy HH:mm').format(transaction.dateTime),
            ),
            children: [
              ...transaction.items.map((item) => ListTile(
                title: Text(item['name']),
                trailing: Text('${item['quantity']} x ${formatRupiah(item['price'])} = ${formatRupiah(item['price'] * item['quantity'])}'),
              )),
              Divider(),
              ListTile(
                title: Text('Total'),
                trailing: Text(formatRupiah(transaction.total)),
              ),
              ListTile(
                title: Text('Metode Pembayaran'),
                trailing: Text(transaction.paymentMethod),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah(_cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity'])))),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah(_discount)),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(formatRupiah(_total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(height: 16),
          Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _paymentMethod,
            isExpanded: true,
            items: ['Tunai', 'Kartu Debit', 'QRIS'].map((String value) {
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
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: Text(
                'PROSES PEMBAYARAN',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}