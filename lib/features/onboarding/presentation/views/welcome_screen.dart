import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen({super.key, required this.onContinue, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: PawTableColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets_rounded, size: 64, color: PawTableColors.primary),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to PawTable',
                      style: theme.textTheme.displayMedium?.copyWith(color: PawTableColors.onBackground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Pet, At Your Table',
                      style: theme.textTheme.bodyLarge?.copyWith(color: PawTableColors.primaryDark),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const _FeatureTile(icon: Icons.favorite_rounded, title: 'Track health & wellness', desc: 'Meals, medications, vaccinations, weight, and more'),
              const SizedBox(height: 16),
              const _FeatureTile(icon: Icons.calendar_month_rounded, title: 'Never miss a reminder', desc: 'Smart alerts for feeding, meds, and vet visits'),
              const SizedBox(height: 16),
              const _FeatureTile(icon: Icons.emoji_events_rounded, title: 'Keep the streak alive', desc: 'Daily check-ins build healthy habits for your pet'),
              const SizedBox(height: 48),
              ElevatedButton(onPressed: onContinue, child: const Text("Let's Go!")),
              const SizedBox(height: 12),
              TextButton(onPressed: onSkip, child: Text('Skip for now', style: TextStyle(color: PawTableColors.onSurfaceMuted))),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureTile({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: PawTableColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(PawTokens.radiusMd)), child: Icon(icon, size: 20, color: PawTableColors.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: PawTableColors.onBackground)),
              const SizedBox(height: 2),
              Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PawTableColors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
