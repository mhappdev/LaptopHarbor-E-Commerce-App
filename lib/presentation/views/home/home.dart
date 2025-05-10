import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbor/presentation/providers/cart_provider.dart';
import 'package:laptop_harbor/presentation/providers/wishlist_provider.dart';
import 'package:laptop_harbor/presentation/views/home/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbor/presentation/views/admin/models/product_model.dart';
import 'package:laptop_harbor/presentation/views/admin/firebase/firestore_service.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/product_detail_screen.dart';
import 'package:laptop_harbor/presentation/views/drawer/custom_drawer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<Product>> _productsStream;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';
  String _selectedPriceRange = 'All';
  String _selectedSort = 'Featured';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Gaming',
    'Ultrabook',
    'Business',
    'Macbook',
    'Chromebook',
    'Convertible'
  ];

  final List<String> _brands = [
    'All',
    'Acer',
    'Apple',
    'Asus',
    'Dell',
    'HP',
    'Lenovo',
    'Microsoft',
    'MSI',
    'Razer',
    'Samsung',
  ];

  final List<String> _priceRanges = [
    'All',
    'Under \$500',
    '\$500 - \$1000',
    '\$1000 - \$1500',
    'Over \$1500'
  ];

  final List<String> _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low'
  ];

  @override
  void initState() {
    super.initState();
    _productsStream = _firestoreService.getProductsStream();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => _applyFilters();

  void _applyFilters() {
    List<Product> filtered = List.from(_allProducts);

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.laptopName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            product.brandName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    if (_selectedBrand != 'All') {
      filtered = filtered
          .where((product) => product.brandName == _selectedBrand)
          .toList();
    }

    if (_selectedPriceRange != 'All') {
      switch (_selectedPriceRange) {
        case 'Under \$500':
          filtered = filtered.where((p) => p.price < 500).toList();
          break;
        case '\$500 - \$1000':
          filtered =
              filtered.where((p) => p.price >= 500 && p.price <= 1000).toList();
          break;
        case '\$1000 - \$1500':
          filtered = filtered
              .where((p) => p.price >= 1000 && p.price <= 1500)
              .toList();
          break;
        case 'Over \$1500':
          filtered = filtered.where((p) => p.price > 1500).toList();
          break;
      }
    }

    filtered = _sortProducts(filtered);

    if (mounted) setState(() => _filteredProducts = filtered);
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (_selectedSort) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating: High to Low':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        products.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Laptop Harbor', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xff037EEE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(_allProducts),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Container(
        color: Colors.grey[50],
        child: StreamBuilder<List<Product>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return _buildErrorState();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            _allProducts = snapshot.data!;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _applyFilters());

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildBannerSlider(),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver:
                      SliverToBoxAdapter(child: _buildFilterRow(isLargeScreen)),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.only(bottom: 80), // Added bottom padding
                  sliver: _buildProductGrid(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xff037EEE)),
        ),
      );

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff037EEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildBannerSlider() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.95,
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: [
          'assets/images/banner1.jpg',
          'assets/images/banner2.jpg',
          'assets/images/banner3.jpg',
        ].map((asset) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterRow(bool isLargeScreen) {
    return Column(
      children: [
        _buildCategoryChips(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildBrandDropdown()),
            const SizedBox(width: 8),
            Expanded(child: _buildPriceRangeDropdown()),
            const SizedBox(width: 8),
            Expanded(child: _buildSortDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: _selectedCategory == _categories[index],
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? _categories[index] : 'All';
                _applyFilters();
              });
            },
            selectedColor: const Color(0xff037EEE),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: _selectedCategory == _categories[index]
                  ? Colors.white
                  : Colors.black,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBrand,
      items: _brands
          .map((brand) => DropdownMenuItem(
                value: brand,
                child: Text(brand, style: const TextStyle(color: Colors.black)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedBrand = value!;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        labelText: 'Brand',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildPriceRangeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriceRange,
      items: _priceRanges
          .map((range) => DropdownMenuItem(
                value: range,
                child: Text(range, style: const TextStyle(color: Colors.black)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedPriceRange = value!;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        labelText: 'Price Range',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSort,
      items: _sortOptions
          .map((option) => DropdownMenuItem(
                value: option,
                child:
                    Text(option, style: const TextStyle(color: Colors.black)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSort = value!;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        labelText: 'Sort By',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildProductGrid() {
    if (_filteredProducts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildProductCard(_filteredProducts[index]),
        childCount: _filteredProducts.length,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
  return Consumer2<CartProvider, WishlistProvider>(
    builder: (context, cart, wishlist, child) {
      final isWishlisted = wishlist.isInWishlist(product);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), // Left-right padding
        child: GestureDetector(
          onTap: () {
            // Navigate to Product Detail Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Wishlist Icon
                  Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 100,
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            wishlist.toggleWishlist(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isWishlisted
                                      ? 'Removed from Wishlist'
                                      : 'Added to Wishlist',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Laptop Name
                  Text(
                    product.laptopName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Ratings
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Price and Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          cart.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${product.laptopName} added to cart'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xff037EEE), // Theme color
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_checkout, // 3D-feel icon
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}


  void _navigateToProductDetail(Product product) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = products.where((product) {
      return product.laptopName.toLowerCase().contains(query.toLowerCase()) ||
          product.brandName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Hero(
            tag: 'search-image-${product.id}',
            child: CircleAvatar(
              backgroundImage: product.imageUrls.isNotEmpty
                  ? NetworkImage(product.imageUrls.first)
                  : const AssetImage('assets/images/placeholder.png')
                      as ImageProvider,
            ),
          ),
          title: Text(product.laptopName),
          subtitle: Text(
            '\$${product.price.toStringAsFixed(2)} • ${product.rating} ⭐',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
