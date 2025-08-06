// lib/transaction_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // Import ini ada, tetapi tidak digunakan di fungsi showDateRangePicker

String formatRupiah(num number) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(number);
}

class Transaction {
  final String id;
  final DateTime dateTime;
  final List<Map<String, dynamic>> items;
  final String paymentMethod;
  final double total;
  final double discount;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.paymentMethod,
    required this.total,
    required this.discount,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Asumsi map['dateTime'] adalah Timestamp jika dari Firestore
    // Contoh ini tidak menggunakan Firestore, jadi .toDate() mungkin error
    // Jika Anda menggunakan Firestore, pastikan import `cloud_firestore`
    return Transaction(
      id: map['id'],
      // Ganti dengan map['dateTime'] jika tidak menggunakan Firestore Timestamp
      dateTime: map['dateTime'].toDate(),
      items: List<Map<String, dynamic>>.from(map['items']),
      paymentMethod: map['paymentMethod'],
      total: map['total'],
      discount: map['discount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime,
      'items': items,
      'paymentMethod': paymentMethod,
      'total': total,
      'discount': discount,
    };
  }
}

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
    // Example dummy data - replace with actual database calls
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<File> _generateTransactionPDF(
    List<Transaction> transactions, {
    DateTimeRange? dateRange,
    bool isDaily = true,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(isDaily ? 'Laporan Harian' : 'Laporan Bulanan'),
              ),
              if (dateRange != null)
                pw.Text(
                  'Periode: ${DateFormat('dd MMM yyyy').format(dateRange.start)} - '
                  '${DateFormat('dd MMM yyyy').format(dateRange.end)}',
                ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: _buildPDFData(transactions),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Penjualan: ${formatRupiah(_calculateTotalSales(transactions))}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Produk Terlaris: ${_getBestSellingProduct(transactions)}',
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/laporan_${isDaily ? 'harian' : 'bulanan'}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> _generateTransactionCSV(List<Transaction> transactions) async {
    final csvData = _buildCSVData(transactions);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_transaksi.csv');
    await file.writeAsString(csvData);
    return file;
  }

  List<List<String>> _buildPDFData(List<Transaction> transactions) {
    final data = <List<String>>[
      ['ID Transaksi', 'Tanggal', 'Total', 'Metode Pembayaran'],
    ];

    for (final transaction in transactions) {
      data.add([
        transaction.id,
        DateFormat('dd MMM yyyy HH:mm').format(transaction.dateTime),
        formatRupiah(transaction.total),
        transaction.paymentMethod,
      ]);
    }

    return data;
  }

  String _buildCSVData(List<Transaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID Transaksi,Tanggal,Item,Jumlah,Harga,Subtotal,Metode Pembayaran,Total',
    );

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        buffer.writeln(
          '${transaction.id},'
          '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.dateTime)},'
          '${item['name']},'
          '${item['quantity']},'
          '${item['price']},'
          '${item['price'] * item['quantity']},'
          '${transaction.paymentMethod},'
          '${transaction.total}',
        );
      }
    }

    return buffer.toString();
  }

  double _calculateTotalSales(List<Transaction> transactions) {
    return transactions.fold(0, (sum, transaction) => sum + transaction.total);
  }

  String _getBestSellingProduct(List<Transaction> transactions) {
    final productSales = <String, double>{};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        final productName = item['name'];
        final total = item['price'] * item['quantity'];
        productSales[productName] = (productSales[productName] ?? 0) + total;
      }
    }

    if (productSales.isEmpty) return '-';

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '${sortedProducts.first.key} (${formatRupiah(sortedProducts.first.value)})';
  }

  Future<void> _exportToPDF(bool isDaily) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final filteredTransactions = _transactions
          .where(
            (t) =>
                t.dateTime.isAfter(picked.start) &&
                t.dateTime.isBefore(picked.end),
          )
          .toList();

      if (filteredTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada transaksi pada periode ini')),
        );
        return;
      }

      final file = await _generateTransactionPDF(
        filteredTransactions,
        dateRange: picked,
        isDaily: isDaily,
      );
      await OpenFilex.open(file.path); // Sudah benar menggunakan OpenFilex
    }
  }

  Future<void> _exportToCSV() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada transaksi untuk diexport')),
      );
      return;
    }

    final file = await _generateTransactionCSV(_transactions);
    await OpenFilex.open(file.path); // Sudah benar menggunakan OpenFilex
  }

  Widget _buildSalesReport() {
    final now = DateTime.now();
    final dailySales = _transactions
        .where(
          (t) =>
              t.dateTime.day == now.day &&
              t.dateTime.month == now.month &&
              t.dateTime.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + t.total);

    final monthlySales = _transactions
        .where(
          (t) => t.dateTime.month == now.month && t.dateTime.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + t.total);

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan Penjualan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Harian:'), Text(formatRupiah(dailySales))],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Bulanan:'), Text(formatRupiah(monthlySales))],
            ),
            SizedBox(height: 16),
            Text(
              'Produk Terlaris:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_getBestSellingProduct(_transactions)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('PDF Harian'),
                    onPressed: () => _exportToPDF(true),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('PDF Bulanan'),
                    onPressed: () => _exportToPDF(false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.grid_on),
              label: Text('Export CSV'),
              onPressed: _exportToCSV,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
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
                subtitle: Text(
                  '${item['quantity']} x ${formatRupiah(item['price'])}',
                ),
                trailing: Text(formatRupiah(item['price'] * item['quantity'])),
              );
            },
          ),
        ),
        _buildPaymentSummary(),
      ],
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
              Text(
                formatRupiah(
                  _cartItems.fold(
                    0,
                    (sum, item) => sum + (item['price'] * item['quantity']),
                  ),
                ),
              ),
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
              Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                formatRupiah(_total),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Metode Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _paymentMethod,
            isExpanded: true,
            items: ['Tunai', 'Kartu Debit', 'QRIS'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
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

  Widget _buildHistoryView() {
    if (_transactions.isEmpty) {
      return Center(child: Text('Belum ada riwayat transaksi'));
    }

    return Column(
      children: [
        _buildSalesReport(),
        Expanded(
          child: ListView.builder(
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
                    DateFormat(
                      'dd MMM yyyy HH:mm',
                    ).format(transaction.dateTime),
                  ),
                  children: [
                    ...transaction.items.map(
                      (item) => ListTile(
                        title: Text(item['name']),
                        trailing: Text(
                          '${item['quantity']} x ${formatRupiah(item['price'])} = ${formatRupiah(item['price'] * item['quantity'])}',
                        ),
                      ),
                    ),
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
          ),
        ),
      ],
    );
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
            : TabBarView(children: [_buildPaymentView(), _buildHistoryView()]),
      ),
    );
  }
}
