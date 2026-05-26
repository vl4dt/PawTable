import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/theme/colors.dart';

import '../../../../shared/widgets/pet_avatar.dart';
import '../../domain/entities/pet_entity.dart';
import '../../presentation/providers/pet_provider.dart';
import '../../../../features/onboarding/domain/models/breed_database.dart';
import '../../../../core/billing/billing_service.dart' show isSubscribedProvider;

/// Pet profile creation wizard
///
/// Multi-step form:
/// 1. Pet name
/// 2. Species & breed
/// 3. Birthdate, weight, details
/// 4. Photo
class AddPetView extends ConsumerStatefulWidget {
  final String? editPetId; // null = create, non-null = edit
  const AddPetView({super.key, this.editPetId});

  @override
  ConsumerState<AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends ConsumerState<AddPetView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();

  PetSpecies _selectedSpecies = PetSpecies.dog;
  String _selectedBreed = '';
  DateTime? _selectedBirthDate;
  String? _photoPath;
  bool _isNeutered = false;
  bool _isMicrochipped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.editPetId != null) {
      _loadExistingPet();
    }
  }

  Future<void> _loadExistingPet() async {
    final petsAsync = ref.read(petListProvider);
    petsAsync.whenData((pets) {
      final pet = pets.firstWhere(
        (p) => p.id == widget.editPetId,
        orElse: () => PetEntity(
          id: '',
          name: '',
          species: PetSpecies.dog,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (pet.id.isNotEmpty) {
        setState(() {
          _nameController.text = pet.name;
          _selectedSpecies = pet.species;
          _breedController.text = pet.breed;
          _selectedBirthDate = pet.birthDate;
          _weightController.text = pet.weight?.toString() ?? '';
          _notesController.text = pet.notes ?? '';
          _isNeutered = pet.isNeutered;
          _isMicrochipped = pet.isMicrochipped;
          _microchipController.text = pet.microchipId ?? '';
          if (pet.photoUri != null) {
            _photoPath = pet.photoUri;
          }
        });
      }
    });
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedBirthDate = date);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final isPremium = ref.read(isSubscribedProvider).value ?? false;
    final petsAsync = ref.read(petListProvider);
    final pets = petsAsync.value ?? [];

    // Premium paywall check: free users limited to 1 pet
    if (!isPremium && pets.length >= 1 && widget.editPetId == null) {
      _showPremiumPaywall();
      return;
    }

    final now = DateTime.now();
    final pet = PetEntity(
      id: widget.editPetId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim(),
      photoUri: _photoPath,
      birthDate: _selectedBirthDate,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isNeutered: _isNeutered,
      isMicrochipped: _isMicrochipped,
      microchipId: _isMicrochipped
          ? _microchipController.text.trim()
          : null,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final notifier = ref.read(petListProvider.notifier);
      if (widget.editPetId != null) {
        await notifier.updatePet(pet);
      } else {
        await notifier.addPet(pet);
      }
      if (mounted) {
        if (widget.editPetId != null) {
          Navigator.of(context).pop(true); // Return true to indicate update
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving pet: $e')),
        );
      }
    }
  }

  void _showPremiumPaywall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: PawTableColors.primary),
            SizedBox(width: 8),
            const Text('Upgrade Required'),
          ],
        ),
        content: const Text(
          'You can only have 1 pet on the free plan. '
          'Upgrade to Premium for unlimited pets!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to premium upgrade
              Navigator.of(context).pop(); // Close add pet
              // Route to premium will be handled by parent
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  double _getAgeDisplay() {
    if (_selectedBirthDate == null) return 0;
    final now = DateTime.now();
    return (now.difference(_selectedBirthDate!).inDays / 365.25).toDouble();
  }

  String _getLifeStageLabel() {
    final age = _getAgeDisplay();
    if (_selectedSpecies == PetSpecies.cat ||
        _selectedSpecies == PetSpecies.dog) {
      if (age < 1) return 'Puppy/Kitten';
      if (age < 2) return 'Juvenile';
      if (age < 7) return 'Adult';
      if (age < 10) return 'Senior';
      return 'Geriatric';
    }
    return 'Adult';
  }

  String _getAgeInYearsMonths() {
    if (_selectedBirthDate == null) return '';
    final now = DateTime.now();
    final totalMonths =
        (now.year - _selectedBirthDate!.year) * 12 +
        (now.month - _selectedBirthDate!.month);
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    if (years > 0 && months > 0) return '$years yr${years > 1 ? 's' : ''} $months mo';
    if (years > 0) return '$years yr${years > 1 ? 's' : ''}';
    return '$months mo';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editPetId != null ? 'Edit Pet' : 'Add Pet'),
        actions: [
          TextButton(
            onPressed: _savePet,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Name'),
              Tab(text: 'Species'),
              Tab(text: 'Details'),
              Tab(text: 'Photo'),
            ],
          ),
          const Divider(height: 1),
          // Tab views
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNameTab(),
                  _buildSpeciesTab(),
                  _buildDetailsTab(),
                  _buildPhotoTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildNameTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your pet's name?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PawTableColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give them a name you both love.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Pet Name',
              hintText: 'e.g. Buddy, Whiskers, Luna',
              prefixIcon: const Icon(Icons.pets, color: PawTableColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              return null;
            },
            autofocus: true,
          ),
          const SizedBox(height: 24),
          // Preview avatar
          Center(
            child: PetAvatar(
              species: _selectedSpecies.name,
              size: 80,
              backgroundColor: PawTableColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesTab() {
    final breeds = BreedDatabase.getBreedsForSpecies(_selectedSpecies);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What kind of pet?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PawTableColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          // Species grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: PetSpecies.values.map((species) {
              final isSelected = _selectedSpecies == species;
              final emoji = BreedDatabase.speciesEmoji(species);
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text(species.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedSpecies = species;
                    _breedController.text = '';
                  });
                },
                selectedColor: PawTableColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Breed dropdown
          Text(
            'Breed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: breeds.contains(_breedController.text.trim())
                ? _breedController.text.trim()
                : null,
            decoration: InputDecoration(
              labelText: breeds.length > 20 ? 'Search or select breed' : 'Select Breed',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category, color: PawTableColors.primary),
            ),
            items: breeds.map((breed) {
              return DropdownMenuItem(
                value: breed,
                child: Text(breed),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _breedController.text = value ?? '');
            },
            hint: const Text('Select a breed or add custom'),
          ),
          const SizedBox(height: 16),
          // Custom breed input
          TextFormField(
            controller: _breedController,
            decoration: InputDecoration(
              labelText: 'Or enter custom breed',
              hintText: 'e.g. Mixed Breed, Custom',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Forward button
          ElevatedButton(
            onPressed: () => _tabController.index = 2,
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PawTableColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          // Birthdate
          InkWell(
            onTap: _selectBirthDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Birth Date',
                prefixIcon: const Icon(Icons.cake, color: PawTableColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: PawTableColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedBirthDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedBirthDate!)
                        : 'Select birth date',
                    style: TextStyle(
                      color: _selectedBirthDate != null
                          ? null
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Age display
          if (_selectedBirthDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.celebration, size: 16),
                  label: Text(_getAgeInYearsMonths()),
                  backgroundColor: PawTableColors.info.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.trending_up, size: 16),
                  label: Text(_getLifeStageLabel()),
                  backgroundColor: PawTableColors.success.withValues(alpha: 0.1),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Weight
          TextFormField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: 'Weight',
              hintText: 'e.g. 5.2',
              prefixIcon: const Icon(Icons.monitor_weight, color: PawTableColors.primary),
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                if (double.tryParse(v) == null) return 'Enter a valid weight';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Neutered toggle
          SwitchListTile(
            title: const Text('Neutered / Spayed'),
            subtitle: const Text('Indicates if pet has been neutered'),
            value: _isNeutered,
            onChanged: (v) => setState(() => _isNeutered = v),
            secondary: const Icon(Icons.pets, color: PawTableColors.primary),
          ),
          // Microchip toggle
          SwitchListTile(
            title: const Text('Microchipped'),
            subtitle: const Text('Pet has an implantable microchip'),
            value: _isMicrochipped,
            onChanged: (v) => setState(() {
              _isMicrochipped = v;
              if (!v) _microchipController.text = '';
            }),
            secondary: const Icon(Icons.qr_code_2, color: PawTableColors.primary),
          ),
          if (_isMicrochipped) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _microchipController,
              decoration: InputDecoration(
                labelText: 'Microchip ID',
                hintText: 'Enter microchip number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
              hintText: 'Any special conditions, allergies, or preferences...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Continue button
          ElevatedButton(
            onPressed: () => _tabController.index = 3,
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet Photo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PawTableColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Take or upload a photo of your pet.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Photo preview or placeholder
          Center(
            child: GestureDetector(
              onTap: () => _showPhotoSourceDialog(),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: PawTableColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: _photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(
                          File(_photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) {
                            return _buildPhotoPlaceholder();
                          },
                        ),
                      )
                    : _buildPhotoPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Photo actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: PawTableColors.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: PawTableColors.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => setState(() => _photoPath = null),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pets,
          size: 64,
          color: PawTableColors.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add photo',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: PawTableColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: PawTableColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _savePet,
            icon: const Icon(Icons.check),
            label: const Text('Save Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
