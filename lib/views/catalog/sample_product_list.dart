import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_wishlist_button.dart';

class SampleProductList extends StatefulWidget {
  const SampleProductList({super.key});

  @override
  State<SampleProductList> createState() => _SampleProductListState();
}

class _SampleProductListState extends State<SampleProductList> {
  final ApiService _apiService = ApiService();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Decor Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.brown,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Gagal memuat data",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = _apiService.fetchProducts();
                      });
                    },
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            
            if (products.isEmpty) {
              return const Center(
                child: Text("Tidak ada produk tersedia."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.chair, color: Colors.brown),
                              )
                            : const Icon(Icons.chair, color: Colors.brown),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    trailing: AnimatedWishlistButton(
                      onChanged: (isLiked) {
                        // Handle wishlist logic
                      },
                    ),
                    onTap: () {
                      // Navigate to details if needed
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Memulai..."));
        },
      ),
    );
  }
}
