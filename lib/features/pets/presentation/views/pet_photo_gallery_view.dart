import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/colors.dart';

/// Pet photo gallery — camera integration, grid display, delete
///
/// Features:
/// - Camera capture and gallery selection
/// - Grid photo display with tap to preview
/// - Delete photos
/// - Set as primary photo
/// - Empty state with camera/gallery actions
class PetPhotoGalleryView extends StatefulWidget {
  final String petId;
  final String petName;
  final List<String> existingPhotos;
  final Future<void> Function(String photoPath) onPhotoAdded;
  final Future<void> Function(String photoPath) onPhotoRemoved;
  final Future<void> Function(String photoPath) onPhotoSetPrimary;

  const PetPhotoGalleryView({
    super.key,
    required this.petId,
    required this.petName,
    this.existingPhotos = const [],
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
    required this.onPhotoSetPrimary,
  });

  @override
  State<PetPhotoGalleryView> createState() => _PetPhotoGalleryViewState();
}

class _PetPhotoGalleryViewState extends State<PetPhotoGalleryView> {
  String? _primaryPhoto;

  @override
  void initState() {
    super.initState();
    _primaryPhoto = widget.existingPhotos.isNotEmpty
        ? widget.existingPhotos.last
        : null;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      await widget.onPhotoAdded(image.path);
    }
  }

  Future<void> _deletePhoto(String path) async {
    if (path == _primaryPhoto && widget.existingPhotos.length > 1) {
      _primaryPhoto = widget.existingPhotos.firstWhere(
        (p) => p != path,
        orElse: () => _primaryPhoto!,
      );
    } else if (path == _primaryPhoto) {
      _primaryPhoto = null;
    }
    await widget.onPhotoRemoved(path);
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: PawTableColors.primary),
              title: const Text('Take Photo'),
              subtitle: const Text('Use your camera'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: PawTableColors.primary),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select an existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName}\'s Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _showSourceDialog,
            tooltip: 'Add Photo',
          ),
        ],
      ),
      body: widget.existingPhotos.isEmpty
          ? _buildEmptyState()
          : _buildGalleryGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: PawTableColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Photos Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PawTableColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a photo of ${widget.petName} to get started!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showSourceDialog,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PawTableColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showSourceDialog,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: widget.existingPhotos.length,
      itemBuilder: (context, index) {
        final photoPath = widget.existingPhotos[index];
        final isPrimary = photoPath == _primaryPhoto;
        return _PhotoTile(
          path: photoPath,
          isPrimary: isPrimary,
          onTap: () => _showPhotoPreview(index),
          onDelete: () => _showDeleteDialog(photoPath),
          onSetPrimary: () {
            setState(() => _primaryPhoto = photoPath);
            widget.onPhotoSetPrimary(photoPath);
          },
        );
      },
    );
  }

  void _showPhotoPreview(int index) {
    final photoPath = widget.existingPhotos[index];
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photoPath),
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => Center(
                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CloseButton(
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            if (photoPath == _primaryPhoto)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PawTableColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Primary Photo',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String path) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deletePhoto(path);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _PhotoTile({
    required this.path,
    required this.isPrimary,
    required this.onTap,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (ctx, err, stack) => Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ),
        // Primary badge
        if (isPrimary)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PawTableColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Primary',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        // Delete button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
        // Long press for set primary
        Positioned.fill(
          child: GestureDetector(
            onLongPress: isPrimary ? null : onSetPrimary,
          ),
        ),
      ],
    );
  }
}
