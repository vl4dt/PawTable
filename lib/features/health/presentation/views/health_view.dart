import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../behavior/presentation/views/behavior_view.dart';
import '../../../feeding/presentation/views/feeding_view.dart';
import '../../../medications/presentation/views/medication_view.dart';
import '../../../vaccinations/presentation/views/vaccination_view.dart';
import 'health_timeline_view.dart';

/// Health dashboard — entry point for all health tracking
///
/// Shows quick access to feeding, vaccinations, medications,
/// behavior logging, and unified health timeline.
class HealthView extends ConsumerWidget {
  final String petId;
  const HealthView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Health'),
          bottom: TabBar(
            indicatorColor: PawTableColors.primary,
            tabs: const [
              Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
              Tab(text: 'Feeding', icon: Icon(Icons.restaurant)),
              Tab(text: 'Vaccines', icon: Icon(Icons.shield)),
              Tab(text: 'Meds', icon: Icon(Icons.medication)),
              Tab(text: 'Behavior', icon: Icon(Icons.sentiment_satisfied)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HealthTimelineView(petId: petId),
            FeedingView(petId: petId),
            VaccinationView(petId: petId),
            MedicationView(petId: petId),
            BehaviorView(petId: petId),
          ],
        ),
      ),
    );
  }
}
