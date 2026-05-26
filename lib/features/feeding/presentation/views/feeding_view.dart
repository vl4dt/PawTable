import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main feeding log view
class FeedingView extends ConsumerWidget {
  final String petId;
  const FeedingView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Logs')),
      body: const Center(child: Text('Feeding logs coming soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
