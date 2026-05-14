import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_page.dart';

class ProductRatesPage extends StatefulWidget {
  final String token; // required auth token
  final String? username; // carry username

  const ProductRatesPage({
    super.key,
    required this.token,
    this.username,
  });

  @override
  State<ProductRatesPage> createState() => _ProductRatesPageState();
}

class _ProductRatesPageState extends State<ProductRatesPage> {
  final List<String> categories = [
    'All',
    'IT Waste',
    'Vehicle Scrap',
    'Household Scrap',
    'Metal Scrap',
    'Plastic & Paper',
    'E-Waste',
    'Appliance Scrap',
    'Furniture Scrap',
    'Glass Scrap',
    'Miscellaneous',
  ];

  List<Map<String, dynamic>> allProducts = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  late TextEditingController _searchController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final apiService = ApiService();
      final products = await apiService.getProducts();
      setState(() {
        allProducts = List<Map<String, dynamic>>.from(products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> getFilteredItems() {
    List<Map<String, dynamic>> filtered;

    if (selectedCategory == 'All') {
      filtered = allProducts;
    } else {
      filtered = allProducts
          .where((item) => item['product_category'] == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              (item['product_name'] ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              (item['product_description'] ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeader(), // now SafeArea-based
          if (!_isLoading) ...[
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(child: _buildContent()),
          ] else ...[
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final filteredItems = getFilteredItems();
    return filteredItems.isEmpty
        ? _buildEmptyState()
        : _buildItemsList(filteredItems);
  }

  // ✅ UPDATED: SafeArea + smaller padding to remove extra top gap [web:1453]
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF111827), size: 24),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserPage(
                      token: widget.token,
                      username: widget.username,
                    ),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Rates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Check current scrap prices',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for items',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items) {
    if (selectedCategory == 'All') {
      return _buildGroupedItemsList(items);
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildItemCard(items[index]),
      );
    }
  }

  Widget _buildGroupedItemsList(List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (var item in items) {
      final category = item['product_category'] ?? 'Miscellaneous';
      groupedItems.putIfAbsent(category, () => []);
      groupedItems[category]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            ...categoryItems.map((item) => _buildItemCard(item)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final icon = item['product_icon'] ?? '📦';
    final name = item['product_name'] ?? 'N/A';
    final description = item['product_description'] ?? '';
    final price = item['product_price'] ?? '₹0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
