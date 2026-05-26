import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const WizardStepIndicator({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? PawTableColors.primary
                : isActive
                    ? PawTableColors.primary.withOpacity(0.5)
                    : PawTableColors.surfaceVariant,
          ),
        );
      }),
    );
  }
}
