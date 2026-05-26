import 'package:flutter/material.dart';

/// Pet avatar — displays pet photo or species icon
class PetAvatar extends StatelessWidget {
  final String? photoUri;
  final String species;
  final double size;
  final Color? backgroundColor;
  const PetAvatar({
    super.key,
    this.photoUri,
    this.species = 'dog',
    this.size = 48,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = backgroundColor ?? theme.colorScheme.primary;

    if (photoUri != null && photoUri!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(photoUri!),
        onBackgroundImageError: (_, __) {
          // Fallback to species icon
        },
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Icon(_getSpeciesIcon(species), size: size * 0.5, color: Colors.white),
    );
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.air;
      case 'rabbit':
        return Icons.face;
      case 'fish':
        return Icons.pets;
      case 'reptile':
        return Icons.landscape;
      case 'hamster':
        return Icons.pets;
      case 'horse':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }
}
