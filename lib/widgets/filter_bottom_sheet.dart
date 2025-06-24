import 'package:flutter/material.dart';
import 'package:woodline/theme/app_colors.dart';
import 'package:woodline/widgets/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedCategory = 'All';
  String _selectedWoodType = 'All';
  bool _customOrdersOnly = false;

  final List<String> _categories = [
    'All',
    'Furniture',
    'Decor',
    'Kitchenware',
    'Toys',
  ];

  final List<String> _woodTypes = [
    'All',
    'Oak',
    'Pine',
    'Walnut',
    'Maple',
    'Cherry',
    'Mahogany',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    _priceRange = RangeValues(
      _filters['minPrice']?.toDouble() ?? 0,
      _filters['maxPrice']?.toDouble() ?? 1000,
    );
    _selectedCategory = _filters['category'] ?? 'All';
    _selectedWoodType = _filters['woodType'] ?? 'All';
    _customOrdersOnly = _filters['customOrdersOnly'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRangeSection(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
                  const SizedBox(height: 24),
                  _buildWoodTypeSection(),
                  const SizedBox(height: 24),
                  _buildCustomOrdersSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 2000,
          divisions: 40,
          activeColor: AppColors.primary,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${_priceRange.start.round()}'),
            Text('\$${_priceRange.end.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWoodTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wood Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _woodTypes.map((woodType) {
            final isSelected = _selectedWoodType == woodType;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWoodType = woodType;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  woodType,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomOrdersSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Custom Orders Only',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: _customOrdersOnly,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _customOrdersOnly = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            onPressed: _clearFilters,
            text: 'Clear All',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            onPressed: _applyFilters,
            text: 'Apply Filters',
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedCategory = 'All';
      _selectedWoodType = 'All';
      _customOrdersOnly = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
      'category': _selectedCategory == 'All' ? null : _selectedCategory,
      'woodType': _selectedWoodType == 'All' ? null : _selectedWoodType,
      'customOrdersOnly': _customOrdersOnly,
    };

    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}