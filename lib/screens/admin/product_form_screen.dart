import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../services/admin_service.dart';
import '../../services/storage_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null for new product, existing product for edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late TextEditingController _stockController;
  late TextEditingController _ratingController;
  late TextEditingController _numReviewsController;
  dynamic _selectedImage;
  String? _previewUrl;
  bool _isUploading = false;

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Living',
    'Books',
    'Sports',
    'Beauty',
    'Food',
  ];

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.product?.imageUrl ?? '');

    // Initialize with first category, then try to find a match
    _selectedCategory = _categories[0];
    if (widget.product?.category != null) {
      for (var category in _categories) {
        if (category.toLowerCase() == widget.product!.category.toLowerCase()) {
          _selectedCategory = category;
          break;
        }
      }
    }

    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _ratingController =
        TextEditingController(text: widget.product?.rating.toString() ?? '');
    _numReviewsController = TextEditingController(
        text: widget.product?.numReviews.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _ratingController.dispose();
    _numReviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              enabled: false, // Disable direct URL input
            ),
            const SizedBox(height: 16),
            if (_previewUrl != null || _imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImagePreview(),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_isUploading
                  ? 'Uploading...'
                  : _previewUrl != null
                      ? 'Change Image'
                      : 'Select Image'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stock quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Rating'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a rating';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _numReviewsController,
              decoration: const InputDecoration(labelText: 'Number of Reviews'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of reviews';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                  widget.product == null ? 'Add Product' : 'Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_previewUrl != null) {
      return Image.network(
        _previewUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Error loading image'),
          );
        },
      );
    } else if (_imageUrlController.text.isNotEmpty) {
      return Image.network(
        _imageUrlController.text,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Error loading image'),
          );
        },
      );
    } else {
      return const Center(
        child: Text('No image selected'),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        if (kIsWeb) {
          _previewUrl = image.path; // This will be a blob URL in web
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String imageUrl = _imageUrlController.text;

      // Upload new image if selected
      if (_selectedImage != null) {
        // Delete old image if it exists
        if (widget.product != null && widget.product!.imageUrl.isNotEmpty) {
          await _storageService.deleteProductImage(widget.product!.imageUrl);
        }
        imageUrl = await _storageService.uploadProductImage(_selectedImage);
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        category: _selectedCategory,
        stock: int.parse(_stockController.text),
        rating: double.parse(_ratingController.text),
        numReviews: int.parse(_numReviewsController.text),
      );

      if (widget.product == null) {
        await context.read<AdminService>().addProduct(product);
      } else {
        await context.read<AdminService>().updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
