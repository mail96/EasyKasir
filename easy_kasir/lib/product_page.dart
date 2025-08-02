import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/custom_drawer.dart';
import 'home_page.dart';

enum ProductType { makanan, minuman }

enum FoodType { ringan, berat }

enum DrinkType { dingin, panas }

class Product {
  String name;
  double price;
  File? image;
  int quantity;
  ProductType type;
  FoodType? foodType;
  DrinkType? drinkType;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.type,
    this.foodType,
    this.drinkType,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      image: map['image'] is String ? null : File(map['image']),
      quantity: map['quantity'],
      type: ProductType.values.firstWhere(
        (e) => e.toString() == 'ProductType.${map['type']}',
        orElse: () => ProductType.makanan,
      ),
      foodType: map['foodType'] != null
          ? FoodType.values.firstWhere(
              (e) => e.toString() == 'FoodType.${map['foodType']}',
            )
          : null,
      drinkType: map['drinkType'] != null
          ? DrinkType.values.firstWhere(
              (e) => e.toString() == 'DrinkType.${map['drinkType']}',
            )
          : null,
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Product> products = sharedProducts
      .map((p) => Product.fromMap(p))
      .toList();

  ProductType? _filterType;
  FoodType? _filterFoodType;
  DrinkType? _filterDrinkType;

  List<Product> get _filteredProducts {
    return products.where((product) {
      final matchesType = _filterType == null || product.type == _filterType;
      final matchesFoodType =
          _filterFoodType == null ||
          (product.type == ProductType.makanan &&
              product.foodType == _filterFoodType);
      final matchesDrinkType =
          _filterDrinkType == null ||
          (product.type == ProductType.minuman &&
              product.drinkType == _filterDrinkType);

      return matchesType && matchesFoodType && matchesDrinkType;
    }).toList();
  }

  void _navigateToAddPage() async {
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductPage()),
    );

    if (newProduct != null) {
      setState(() {
        products.add(newProduct);
        sharedProducts.add({
          'name': newProduct.name,
          'price': newProduct.price,
          'image': newProduct.image?.path ?? 'assets/images/gambar1.jpeg',
          'quantity': newProduct.quantity,
          'type': newProduct.type.toString().split('.').last,
          'foodType': newProduct.foodType?.toString().split('.').last,
          'drinkType': newProduct.drinkType?.toString().split('.').last,
        });
      });
    }
  }

  void _navigateToEditPage(int index) async {
    final product = _filteredProducts[index];
    final editedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductPage(product: product, isEditing: true),
      ),
    );

    if (editedProduct != null) {
      setState(() {
        final originalIndex = products.indexOf(product);
        products[originalIndex] = editedProduct;
        sharedProducts[originalIndex] = {
          'name': editedProduct.name,
          'price': editedProduct.price,
          'image': editedProduct.image?.path ?? 'assets/images/gambar1.jpeg',
          'quantity': editedProduct.quantity,
          'type': editedProduct.type.toString().split('.').last,
          'foodType': editedProduct.foodType?.toString().split('.').last,
          'drinkType': editedProduct.drinkType?.toString().split('.').last,
        };
      });
    }
  }

  void _deleteProduct(int index) {
    final productToDelete = _filteredProducts[index];
    final originalIndex = products.indexOf(productToDelete);

    if (originalIndex < 0 || originalIndex >= sharedProducts.length) return;

    setState(() {
      products.removeAt(originalIndex);
      sharedProducts.removeAt(originalIndex);
    });
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text('Semua'),
            selected: _filterType == null,
            onSelected: (_) => setState(() {
              _filterType = null;
              _filterFoodType = null;
              _filterDrinkType = null;
            }),
          ),
          FilterChip(
            label: Text('Makanan'),
            selected: _filterType == ProductType.makanan,
            onSelected: (_) => setState(() {
              _filterType = ProductType.makanan;
              _filterDrinkType = null;
            }),
          ),
          FilterChip(
            label: Text('Minuman'),
            selected: _filterType == ProductType.minuman,
            onSelected: (_) => setState(() {
              _filterType = ProductType.minuman;
              _filterFoodType = null;
            }),
          ),

          if (_filterType == ProductType.makanan) ...[
            SizedBox(width: 8),
            FilterChip(
              label: Text('Semua Makanan'),
              selected: _filterFoodType == null,
              onSelected: (_) => setState(() => _filterFoodType = null),
            ),
            FilterChip(
              label: Text('Ringan'),
              selected: _filterFoodType == FoodType.ringan,
              onSelected: (_) =>
                  setState(() => _filterFoodType = FoodType.ringan),
            ),
            FilterChip(
              label: Text('Berat'),
              selected: _filterFoodType == FoodType.berat,
              onSelected: (_) =>
                  setState(() => _filterFoodType = FoodType.berat),
            ),
          ],

          if (_filterType == ProductType.minuman) ...[
            SizedBox(width: 8),
            FilterChip(
              label: Text('Semua Minuman'),
              selected: _filterDrinkType == null,
              onSelected: (_) => setState(() => _filterDrinkType = null),
            ),
            FilterChip(
              label: Text('Dingin'),
              selected: _filterDrinkType == DrinkType.dingin,
              onSelected: (_) =>
                  setState(() => _filterDrinkType = DrinkType.dingin),
            ),
            FilterChip(
              label: Text('Panas'),
              selected: _filterDrinkType == DrinkType.panas,
              onSelected: (_) =>
                  setState(() => _filterDrinkType = DrinkType.panas),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onDrawerPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onCartPressed: () {},
        title: 'Daftar Produk',
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Produk ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildFilterChips(),
          SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: product.image == null
                            ? Center(child: Icon(Icons.image, size: 60))
                            : ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Image.file(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  frameBuilder:
                                      (
                                        ctx,
                                        child,
                                        frame,
                                        wasSynchronouslyLoaded,
                                      ) {
                                        if (wasSynchronouslyLoaded)
                                          return child;
                                        return frame != null
                                            ? child
                                            : CircularProgressIndicator();
                                      },
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.error),
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatRupiah(product.price),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              product.type == ProductType.makanan
                                  ? 'Makanan ${product.foodType?.toString().split('.').last ?? ''}'
                                  : 'Minuman ${product.drinkType?.toString().split('.').last ?? ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 18),
                              onPressed: () => _navigateToEditPage(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            Text(
                              '<${product.quantity}>',
                              style: TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteProduct(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPage,
        icon: Icon(Icons.add),
        label: Text("Tambah"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AddEditProductPage extends StatefulWidget {
  final Product? product;
  final bool isEditing;

  const AddEditProductPage({super.key, this.product, this.isEditing = false});

  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late int _quantity;
  File? _selectedImage;
  late ProductType _selectedType;
  late FoodType? _selectedFoodType;
  late DrinkType? _selectedDrinkType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isEditing ? widget.product?.name : '',
    );
    _priceController = TextEditingController(
      text: widget.isEditing ? widget.product?.price.toString() : '',
    );
    _quantity = widget.isEditing ? widget.product?.quantity ?? 1 : 1;
    _selectedImage = widget.isEditing ? widget.product?.image : null;
    _selectedType = widget.isEditing
        ? widget.product?.type ?? ProductType.makanan
        : ProductType.makanan;
    _selectedFoodType = widget.isEditing
        ? widget.product?.foodType
        : FoodType.ringan;
    _selectedDrinkType = widget.isEditing
        ? widget.product?.drinkType
        : DrinkType.dingin;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;

      Navigator.pop(
        context,
        Product(
          name: _nameController.text,
          price: price,
          image: _selectedImage,
          quantity: _quantity,
          type: _selectedType,
          foodType: _selectedType == ProductType.makanan
              ? _selectedFoodType
              : null,
          drinkType: _selectedType == ProductType.minuman
              ? _selectedDrinkType
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'EDIT PRODUK' : 'TAMBAH PRODUK BARU'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (double.tryParse(value) == null)
                    return 'Harus angka valid';
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Jenis Produk',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<ProductType>(
                    value: ProductType.makanan,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedDrinkType = null;
                        _selectedFoodType = FoodType.ringan;
                      });
                    },
                  ),
                  Text('Makanan'),
                  Radio<ProductType>(
                    value: ProductType.minuman,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedFoodType = null;
                        _selectedDrinkType = DrinkType.dingin;
                      });
                    },
                  ),
                  Text('Minuman'),
                ],
              ),
              if (_selectedType == ProductType.makanan) ...[
                SizedBox(height: 8),
                Text(
                  'Jenis Makanan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Radio<FoodType>(
                      value: FoodType.ringan,
                      groupValue: _selectedFoodType,
                      onChanged: (value) =>
                          setState(() => _selectedFoodType = value),
                    ),
                    Text('Ringan'),
                    Radio<FoodType>(
                      value: FoodType.berat,
                      groupValue: _selectedFoodType,
                      onChanged: (value) =>
                          setState(() => _selectedFoodType = value),
                    ),
                    Text('Berat'),
                  ],
                ),
              ] else ...[
                SizedBox(height: 8),
                Text(
                  'Jenis Minuman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Radio<DrinkType>(
                      value: DrinkType.dingin,
                      groupValue: _selectedDrinkType,
                      onChanged: (value) =>
                          setState(() => _selectedDrinkType = value),
                    ),
                    Text('Dingin'),
                    Radio<DrinkType>(
                      value: DrinkType.panas,
                      groupValue: _selectedDrinkType,
                      onChanged: (value) =>
                          setState(() => _selectedDrinkType = value),
                    ),
                    Text('Panas'),
                  ],
                ),
              ],
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage == null
                      ? Center(child: Icon(Icons.image, size: 40))
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Jumlah Produk:'),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                  Text(_quantity.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() {
                      _quantity++;
                    }),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
