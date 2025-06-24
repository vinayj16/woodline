import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:woodline/models/product_model.dart';
import 'package:woodline/providers/product_provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:woodline/utils/app_utils.dart';
import 'package:woodline/widgets/image_source_sheet.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _woodTypeController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _estimatedDaysController = TextEditingController(text: '14');
  
  final List<File> _imageFiles = [];
  final List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isCustomOrderAvailable = false;
  String? _selectedCategory;
  
  // Categories
  final List<String> _categories = [
    'Furniture',
    'Decor',
    'Kitchenware',
    'Toys',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing, populate the form with existing product data
    if (widget.product != null) {
      final product = widget.product!;
      _titleController.text = product.title;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _woodTypeController.text = product.woodType ?? '';
      _dimensionsController.text = product.dimensions ?? '';
      _estimatedDaysController.text = product.estimatedDays.toString();
      _isCustomOrderAvailable = product.isCustomOrderAvailable;
      _selectedCategory = product.category;
      _imageUrls.addAll(product.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _woodTypeController.dispose();
    _dimensionsController.dispose();
    _estimatedDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show bottom sheet to choose image source
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) => const ImageSourceSheet(),
      );
      
      if (source == null) return;
      
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Failed to pick images: $e',
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _imageFiles.length) {
        _imageFiles.removeAt(index);
      } else {
        final urlIndex = index - _imageFiles.length;
        if (urlIndex < _imageUrls.length) {
          _imageUrls.removeAt(urlIndex);
        }
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty && _imageUrls.isEmpty) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Please add at least one image',
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      final userProvider = context.read<UserProvider>();
      
      if (userProvider.user == null) {
        throw Exception('User not logged in');
      }

      final product = ProductModel(
        id: widget.product?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrls: _imageUrls, // Existing URLs
        category: _selectedCategory ?? _categories.first,
        woodType: _woodTypeController.text.trim().isNotEmpty
            ? _woodTypeController.text.trim()
            : null,
        dimensions: _dimensionsController.text.trim().isNotEmpty
            ? _dimensionsController.text.trim()
            : null,
        estimatedDays: int.parse(_estimatedDaysController.text.trim()),
        ownerId: userProvider.user!.id,
        isCustomOrderAvailable: _isCustomOrderAvailable,
        isAvailable: true,
        rating: widget.product?.rating,
        reviewCount: widget.product?.reviewCount ?? 0,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        // Add new product
        await productProvider.addProduct(product);
        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context,
            message: 'Product added successfully!',
          );
        }
      } else {
        // Update existing product
        await productProvider.updateProduct(product);
        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context,
            message: 'Product updated successfully!',
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Failed to save product: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final confirm = await AppUtils.showConfirmationDialog(
                        context,
                        title: 'Delete Product',
                        content: 'Are you sure you want to delete this product?',
                        confirmText: 'Delete',
                      );
                      
                      if (confirm == true && mounted) {
                        try {
                          setState(() => _isLoading = true);
                          await context.read<ProductProvider>().deleteProduct(widget.product!.id);
                          if (mounted) {
                            Navigator.pop(context);
                            AppUtils.showSuccessSnackBar(
                              context,
                              message: 'Product deleted successfully',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            AppUtils.showErrorSnackBar(
                              context,
                              message: 'Failed to delete product: $e',
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Image picker
                  _buildImagePickerSection(),
                  const SizedBox(height: 24),
                  
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Product Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Wood Type (optional)
                  TextFormField(
                    controller: _woodTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Wood Type (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.forest),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Dimensions (optional)
                  TextFormField(
                    controller: _dimensionsController,
                    decoration: const InputDecoration(
                      labelText: 'Dimensions (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                      hintText: 'e.g., 24" x 36" x 12"',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Estimated days to complete
                  TextFormField(
                    controller: _estimatedDaysController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Days to Complete',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter estimated days';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Custom order available toggle
                  SwitchListTile(
                    title: const Text('Accept Custom Orders'),
                    subtitle: const Text('Allow customers to request custom versions of this product'),
                    value: _isCustomOrderAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isCustomOrderAvailable = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: Text(
                        widget.product == null ? 'Add Product' : 'Update Product',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePickerSection() {
    final allImages = [
      ..._imageFiles.map((file) => Image.file(file)),
      ..._imageUrls.map((url) => Image.network(url)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Add at least one image (max 10). First image will be used as the main image.',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add image button
              if (allImages.length < 10)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          'Add ${10 - allImages.length} more',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Selected images
              ...List.generate(allImages.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: allImages[index].image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
