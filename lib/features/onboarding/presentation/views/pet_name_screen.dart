import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/onboarding_provider.dart';

class PetNameScreen extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  const PetNameScreen({super.key, required this.onBack, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final controller = TextEditingController(text: state.name);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text("Let's name your pet", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Give your pet a name they will love forever', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PawTableColors.onSurfaceMuted), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (value) {
                  ref.read(onboardingStateProvider.notifier).setName(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter pet name...',
                  prefixIcon: Icon(Icons.pets_rounded, color: PawTableColors.primary),
                  filled: true,
                  fillColor: PawTableColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(PawTokens.radiusMd), borderSide: BorderSide.none),
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: controller.text.trim().isNotEmpty ? onContinue : null,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
