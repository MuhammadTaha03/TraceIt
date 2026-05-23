import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../providers/app_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  String _type = 'lost'; // 'lost' or 'found'
  String _category = 'Electronics';
  bool _isLoading = false;

  final categories = ['Electronics', 'Keys', 'Clothing', 'Documents', 'Books', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final service = ref.read(supabaseServiceProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to post')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final postId = const Uuid().v4();
    String finalImageUrl = '';

    try {
      // If a local image was picked, upload it to storage
      if (_selectedImageFile != null) {
        final uploadedUrl = await service.uploadPostImage(postId, _selectedImageFile!.path);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      // Default neat mock images depending on type if they didn't specify one
      if (finalImageUrl.isEmpty) {
        if (_category == 'Electronics') {
          finalImageUrl = 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=500';
        } else if (_category == 'Keys') {
          finalImageUrl = 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=500';
        } else if (_category == 'Clothing') {
          finalImageUrl = 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500';
        } else {
          finalImageUrl = 'https://images.unsplash.com/photo-1554030226-e58a826c4f04?w=500';
        }
      }

      final post = Post(
        id: postId,
        userId: user.id,
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        imageUrl: finalImageUrl,
        category: _category,
        status: 'open',
        createdAt: DateTime.now().toUtc(),
      );

      await service.createPost(post);
      
      // Invalidate the post provider so that the feed updates immediately
      ref.invalidate(postsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully reported ${_type == 'lost' ? 'lost' : 'found'} item!'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1E1E1E);
    const primaryColor = Color(0xFFFFD93D); // Flat Neo-brutalism yellow

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: borderColor, width: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: borderColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report Item',
          style: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: borderColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Report Type Toggles
                    Row(
                      children: [
                        _buildTypeSelector('lost', 'I LOST AN ITEM', const Color(0xFFFF6B6B)),
                        const SizedBox(width: 12),
                        _buildTypeSelector('found', 'I FOUND AN ITEM', const Color(0xFF4ECDC4)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _buildLabel('ITEM NAME / TITLE'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('e.g., iPhone 13 Pro Max, Black Keys'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 18),

                    // Category & Location Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('CATEGORY'),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor, width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _category,
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                      color: borderColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down_rounded, color: borderColor),
                                    items: categories.where((c) => c != 'All').map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _category = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('LOCATION / AREA'),
                              TextFormField(
                                controller: _locationController,
                                decoration: _inputDecoration('e.g., Block C Lobby, Library'),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Location required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Description
                    _buildLabel('DESCRIPTION & DETAILS'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration('Describe unique identifiers, color, shape, or where exactly you saw it.'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Description required' : null,
                    ),
                    const SizedBox(height: 18),

                    // Optional Image Upload Picker
                    _buildLabel('IMAGE / PHOTO (OPTIONAL)'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          if (_selectedImageFile != null) ...[
                            Stack(
                              children: [
                                Container(
                                  height: 160,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderColor, width: 1.5),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImageFile!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImageFile = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B6B),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: borderColor, width: 1.5),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close_rounded, size: 16, color: borderColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            Container(
                              height: 90,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor.withOpacity(0.1), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_outlined, size: 24, color: borderColor.withOpacity(0.4)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No Image Selected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: borderColor.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_rounded, size: 16),
                                  label: const Text('GALLERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F3F5),
                                    foregroundColor: borderColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: borderColor, width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                                  label: const Text('CAMERA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F3F5),
                                    foregroundColor: borderColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: borderColor, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Leave empty to auto-use a high-quality category illustration.',
                      style: TextStyle(
                        fontSize: 11,
                        color: borderColor.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: borderColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: borderColor, width: 2),
                      ),
                      child: const Text(
                        'PUBLISH REPORT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String labelText) {
    const borderColor = Color(0xFF1E1E1E);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: borderColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String typeValue, String text, Color activeColor) {
    const borderColor = Color(0xFF1E1E1E);
    final isSelected = _type == typeValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = typeValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isSelected
                ? null
                : const [
                    BoxShadow(
                      color: borderColor,
                      offset: Offset(2, 2),
                    ),
                  ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : borderColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    const borderColor = Color(0xFF1E1E1E);
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: borderColor.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
      errorStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
