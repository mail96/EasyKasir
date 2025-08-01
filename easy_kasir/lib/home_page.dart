import 'package:flutter/material.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/custom_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> categories = ['Minuman', 'Makanan', 'Lainnya'];
  final List<Map<String, dynamic>> products = List.generate(
    10,
    (index) => {
      'name': 'Produk ${index + 1}',
      'price': 15000 + (index * 500),
      'image': 'assets/images/placeholder.png',
      'quantity': 0,
    },
  );

  int _selectedCategoryIndex = -1;

  // Menghitung subtotal dari produk yang telah dipilih (quantity > 0)
  double _calculateSubtotal() {
    double subtotal = 0;
    for (var product in products) {
      subtotal += product['price'] * product['quantity'];
    }
    return subtotal;
  }

  // Fungsi untuk menampilkan pop-up pembayaran
  void _showCheckoutPopup() {
    final selectedProducts = products.where((p) => p['quantity'] > 0).toList();
    final subtotal = _calculateSubtotal();
    String? selectedPaymentMethod = 'Tunai';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.all(16),
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
                        // Input Nama
                        _buildTextField('Nama Anda'),
                        const SizedBox(height: 16),
                        // Daftar Produk
                        const Text(
                          'Daftar Produk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildProductList(selectedProducts),
                        const SizedBox(height: 16),
                        // Input Catatan
                        _buildTextField('Catatan', maxLines: 3),
                        const SizedBox(height: 16),
                        // Subtotal
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
                        // Metode Pembayaran
                        _buildPaymentMethod(selectedPaymentMethod, (newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue;
                          });
                        }),
                        const SizedBox(height: 24),
                        // Tombol Lanjutkan Pembayaran
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Tambahkan logika pembayaran di sini
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

  // Ganti fungsi lama dengan yang baru
  void _onCashierIconPressed() {
    _showCheckoutPopup();
  }

  // Fungsi untuk menambah jumlah produk
  void _incrementQuantity(int index) {
    setState(() {
      products[index]['quantity']++;
    });
  }

  // Fungsi untuk mengurangi jumlah produk
  void _decrementQuantity(int index) {
    setState(() {
      if (products[index]['quantity'] > 0) {
        products[index]['quantity']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onDrawerPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onCartPressed: () {
          // Aksi ketika ikon keranjang ditekan
        },
        title: 'Beranda',
      ),
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            sliver: SliverToBoxAdapter(child: _buildSearchBar()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: InkWell(
                        onTap: _onCashierIconPressed, // Memanggil fungsi baru
                        child: const Icon(
                          Icons.point_of_sale,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ...categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      String category = entry.value;

                      Color backgroundColor = _selectedCategoryIndex == index
                          ? Colors.yellow.shade100
                          : const Color(0xFFF0F0F0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Chip(
                            label: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: _buildProductGrid(),
          ),
        ],
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

  Widget _buildProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final product = products[index];
        return _buildProductCard(product, index);
      }, childCount: products.length),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
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
                  child: Center(
                    child: Image.asset(
                      product['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
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
                      'Rp ${product['price'].toString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  // Widget untuk TextField di dalam pop-up
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

  // Widget untuk daftar produk di dalam pop-up
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
                final totalItemPrice = product['price'] * product['quantity'];
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

  // Widget untuk dropdown metode pembayaran
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
