import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
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

    // Search filter
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

    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Brand filter
    if (_selectedBrand != 'All') {
      filtered = filtered
          .where((product) => product.brandName == _selectedBrand)
          .toList();
    }

    // Price range filter
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

    // Sorting
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
        title: const Text('Laptop Harbor'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ProductSearchDelegate(_allProducts),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {/* Navigate to cart */},
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorState();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          _allProducts = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildBannerSlider()),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver:
                    SliverToBoxAdapter(child: _buildFilterRow(isLargeScreen)),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildProductGrid(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildBannerSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: [
        'assets/images/banner1.jpg',
        'assets/images/banner2.jpg',
        'assets/images/banner3.jpg',
      ].map((asset) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
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
            const SizedBox(width: 12),
            Expanded(child: _buildPriceRangeDropdown()),
            const SizedBox(width: 12),
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
          return FilterChip(
            label: Text(_categories[index]),
            selected: _selectedCategory == _categories[index],
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? _categories[index] : 'All';
                _applyFilters();
              });
            },
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: _selectedCategory == _categories[index]
                  ? Theme.of(context).primaryColor
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
                child: Text(brand),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      isExpanded: true,
    );
  }

  Widget _buildPriceRangeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriceRange,
      items: _priceRanges
          .map((range) => DropdownMenuItem(
                value: range,
                child: Text(range),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      isExpanded: true,
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSort,
      items: _sortOptions
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      isExpanded: true,
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Wishlist in Stack
            Stack(
              children: [
                // Centered Image with fixed height to avoid overflow
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
                // Wishlist icon on top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Laptop Name
            Text(
              product.laptopName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

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
                Text(product.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),

            // Price and Add to Cart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Icon(Icons.shopping_cart, size: 16),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => ProductDetailScreen(product: product),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
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
