import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/onboarding_provider.dart';

class TrialActivationScreen extends ConsumerWidget {
  final VoidCallback onBack;
  const TrialActivationScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    bool hasConsent = state.hasTrialConsent ?? false;
    bool pushConsent = state.pushNotificationConsent ?? false;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('Start your free trial', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Enjoy 7 days free. Cancel anytime.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PawTableColors.onSurfaceMuted), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _FeatureCard(
                icon: Icons.star_rounded,
                title: 'Full access',
                desc: 'Unlock all features for 7 days',
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.payment_rounded,
                title: 'No payment required',
                desc: 'Start your trial without entering payment details',
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text('Enable notifications'),
                subtitle: const Text('Get reminders for feeding, meds, and vet visits'),
                value: pushConsent,
                onChanged: (value) {
                  ref.read(onboardingStateProvider.notifier).setPushNotificationConsent(value);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Start 7-day free trial'),
                subtitle: const Text('I agree to the terms and conditions'),
                value: hasConsent,
                onChanged: (value) {
                  ref.read(onboardingStateProvider.notifier).setTrialConsent(value);
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: hasConsent ? () {
                  Navigator.of(context).pop();
                } : null,
                child: const Text('Start Trial'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: PawTableColors.surface, borderRadius: BorderRadius.circular(PawTokens.radiusMd)),
      child: Row(
        children: [
          Icon(icon, color: PawTableColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PawTableColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
