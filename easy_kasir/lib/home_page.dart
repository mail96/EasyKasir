import 'package:flutter/material.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/custom_drawer.dart';
import 'dart:io';
import 'package:intl/intl.dart';

String formatRupiah(num number) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(number);
}

List<Map<String, dynamic>> sharedProducts = [
  {
    'name': 'Produk 1',
    'price': 15000,
    'image': 'assets/images/gambar1.jpeg',
    'quantity': 0,
    'type': 'makanan',
    'foodType': 'ringan',
  },
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (sharedProducts.isEmpty) {
      sharedProducts = List.generate(
        10,
        (index) => {
          'name': 'Produk ${index + 1}',
          'price': 15000 + (index * 500),
          'image': 'assets/images/gambar1.jpeg',
          'quantity': 0,
          'type': index % 2 == 0 ? 'makanan' : 'minuman',
          'foodType': index % 2 == 0
              ? (index % 3 == 0 ? 'ringan' : 'berat')
              : null,
          'drinkType': index % 2 != 0
              ? (index % 3 == 0 ? 'dingin' : 'panas')
              : null,
        },
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedProductType;
  String? _selectedSubType;

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var product in sharedProducts) {
      subtotal += product['price'] * product['quantity'];
    }
    return subtotal;
  }

  void _showCheckoutPopup() {
    final selectedProducts = sharedProducts
        .where((p) => p['quantity'] > 0)
        .toList();
    final subtotal = _calculateSubtotal();
    String? selectedPaymentMethod = 'Tunai';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.shade100, Colors.grey.shade300],
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Nama Anda'),
                        const SizedBox(height: 16),
                        const Text(
                          'Daftar Produk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildProductList(selectedProducts),
                        const SizedBox(height: 16),
                        _buildTextField('Catatan', maxLines: 3),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Rp ${subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethod(selectedPaymentMethod, (newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue;
                          });
                        }),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran dilanjutkan!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Lanjutkan Pembayaran',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onCashierIconPressed() {
    _showCheckoutPopup();
  }

  void _incrementQuantity(int index) {
    setState(() {
      sharedProducts[index]['quantity']++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (sharedProducts[index]['quantity'] > 0) {
        sharedProducts[index]['quantity']--;
      }
    });
  }

  Widget _buildTypeFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: _selectedProductType == null,
            onSelected: (_) => setState(() {
              _selectedProductType = null;
              _selectedSubType = null;
            }),
          ),
          FilterChip(
            label: const Text('Makanan'),
            selected: _selectedProductType == 'makanan',
            onSelected: (_) => setState(() {
              _selectedProductType = 'makanan';
              _selectedSubType = null;
            }),
          ),
          FilterChip(
            label: const Text('Minuman'),
            selected: _selectedProductType == 'minuman',
            onSelected: (_) => setState(() {
              _selectedProductType = 'minuman';
              _selectedSubType = null;
            }),
          ),

          if (_selectedProductType == 'makanan') ...[
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Semua Makanan'),
              selected: _selectedSubType == null,
              onSelected: (_) => setState(() => _selectedSubType = null),
            ),
            FilterChip(
              label: const Text('Ringan'),
              selected: _selectedSubType == 'ringan',
              onSelected: (_) => setState(() => _selectedSubType = 'ringan'),
            ),
            FilterChip(
              label: const Text('Berat'),
              selected: _selectedSubType == 'berat',
              onSelected: (_) => setState(() => _selectedSubType = 'berat'),
            ),
          ],

          if (_selectedProductType == 'minuman') ...[
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Semua Minuman'),
              selected: _selectedSubType == null,
              onSelected: (_) => setState(() => _selectedSubType = null),
            ),
            FilterChip(
              label: const Text('Dingin'),
              selected: _selectedSubType == 'dingin',
              onSelected: (_) => setState(() => _selectedSubType = 'dingin'),
            ),
            FilterChip(
              label: const Text('Panas'),
              selected: _selectedSubType == 'panas',
              onSelected: (_) => setState(() => _selectedSubType = 'panas'),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return sharedProducts.where((product) {
      final matchesType =
          _selectedProductType == null ||
          product['type'] == _selectedProductType;
      final matchesSubType =
          _selectedSubType == null ||
          (product['type'] == 'makanan' &&
              product['foodType'] == _selectedSubType) ||
          (product['type'] == 'minuman' &&
              product['drinkType'] == _selectedSubType);

      return matchesType && matchesSubType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onDrawerPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onCartPressed: () {},
        title: 'Beranda',
      ),
      drawer: const CustomDrawer(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          setState(() {});
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: SliverToBoxAdapter(child: _buildSearchBar()),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 8.0,
                            ),
                            child: InkWell(
                              onTap: _onCashierIconPressed,
                              child: const Icon(
                                Icons.point_of_sale,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTypeFilterChips(),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  return _buildProductCard(_filteredProducts[index], index);
                }, childCount: _filteredProducts.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFFA5A5A5)),
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Color(0xFFA5A5A5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    Widget imageWidget;
    if (product['image'] is String) {
      imageWidget = Image.asset(
        product['image'] as String,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else if (product['image'] is File) {
      imageWidget = Image.file(
        product['image'] as File,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else {
      imageWidget = const Icon(Icons.image);
    }

    int quantity = product['quantity'];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey.shade200,
                  child: Center(child: imageWidget),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(product['price']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      product['type'] == 'makanan'
                          ? 'Makanan ${product['foodType'] ?? ''}'
                          : 'Minuman ${product['drinkType'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.remove,
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: () => _decrementQuantity(index),
                          ),
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: () => _incrementQuantity(index),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (quantity > 0)
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                backgroundColor: Colors.yellow.shade400,
                radius: 12,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products) {
    return products.isEmpty
        ? const Text('Tidak ada produk di keranjang.')
        : Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final totalItemPrice =
                    (product['price'] as num).toDouble() * product['quantity'];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${product['name']} x${product['quantity']}',
                        ),
                      ),
                      Text('Rp ${totalItemPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Widget _buildPaymentMethod(
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: 'Metode Pembayaran',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: <String>['Tunai', 'Kartu Debit', 'QRIS']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          })
          .toList(),
      onChanged: onChanged,
    );
  }
}
