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
      if (_selectedImageFile != null) {
        final uploadedUrl = await service.uploadPostImage(postId, _selectedImageFile!.path);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully reported ${_type == 'lost' ? 'lost' : 'found'} item!'),
            backgroundColor: const Color(0xFF1A73E8),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
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
    const primaryColor = Color(0xFF1A73E8);
    const outlineColor = Color(0xFF727785);
    const onSurface = Color(0xFF191C1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Item'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Report Type Toggles
                    Row(
                      children: [
                        _buildTypeSelector(
                          'lost', 
                          'I LOST AN ITEM', 
                          const Color(0xFFFFDAD6), 
                          const Color(0xFF93000A),
                        ),
                        const SizedBox(width: 12),
                        _buildTypeSelector(
                          'found', 
                          'I FOUND AN ITEM', 
                          const Color(0xFF89FA9B), 
                          const Color(0xFF002108),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Title
                    _buildLabel('ITEM NAME / TITLE'),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'e.g., iPhone 13 Pro Max, Black Keys'),
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: onSurface),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 24),

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
                              DropdownButtonFormField<String>(
                                value: _category,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                                style: const TextStyle(fontFamily: 'Inter', color: onSurface, fontWeight: FontWeight.w500, fontSize: 14),
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: outlineColor),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('LOCATION / AREA'),
                              TextFormField(
                                controller: _locationController,
                                decoration: const InputDecoration(hintText: 'e.g., Block C Lobby'),
                                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: onSurface),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Location required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    _buildLabel('DESCRIPTION & DETAILS'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Describe unique identifiers, color, shape, or where exactly you saw it.'),
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: onSurface),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Description required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Optional Image Upload Picker
                    _buildLabel('IMAGE / PHOTO (OPTIONAL)'),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE1E3E4), width: 1),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_selectedImageFile != null) ...[
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImageFile!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFBA1A1A),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_outlined, size: 28, color: outlineColor.withOpacity(0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Image Selected',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: outlineColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_rounded, size: 18),
                                  label: const Text('Gallery', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: onSurface,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFC1C6D6)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                  label: const Text('Camera', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: onSurface,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFC1C6D6)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: outlineColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Publish Report',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        labelText,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF414754),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String typeValue, String text, Color activeBgColor, Color activeTextColor) {
    final isSelected = _type == typeValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = typeValue;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeBgColor : const Color(0xFFE1E3E4),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? activeTextColor : const Color(0xFF414754),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
