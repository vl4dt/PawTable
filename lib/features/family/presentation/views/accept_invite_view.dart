import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../features/family/domain/entities/invite_entity.dart';
import '../providers/invite_provider.dart';

/// View for accepting an invite via deep link or code input
class AcceptInviteView extends ConsumerStatefulWidget {
  final String? code; // From deep link, optional

  const AcceptInviteView({super.key, this.code});

  @override
  ConsumerState<AcceptInviteView> createState() => _AcceptInviteViewState();
}

class _AcceptInviteViewState extends ConsumerState<AcceptInviteView> {
  final _codeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.code != null && widget.code!.isNotEmpty) {
      _codeController.text = widget.code!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
      ),
      body: _buildBody(context, inviteState),
    );
  }

  Widget _buildBody(BuildContext context, InviteState inviteState) {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show result if available
    if (inviteState.inviteResult != null) {
      return _buildResult(context, inviteState.inviteResult!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and title
          Icon(
            Icons.group_add_rounded,
            size: 64,
            color: PawTableColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Join a Family Group',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the invite code to join your family\'s PawTable group.',
            style: TextStyle(
              fontSize: 15,
              color: PawTableColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Code input
          _buildCodeInput(context),

          const SizedBox(height: 16),

          // Accept button
          ElevatedButton(
            onPressed: _isProcessing ? null : _acceptInvite,
            child: const Text('Join Group'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: PawTableColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Demo section for testing
          _buildDemoSection(context),
        ],
      ),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: PawTableColors.onSurfaceVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _codeController,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontFamily: 'monospace',
        ),
        textCapitalization: TextCapitalization.characters,
        maxLength: 8,
        decoration: const InputDecoration(
          hintText: 'ABCDEFGH',
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
        onChanged: (value) {
          _codeController.text = value.toUpperCase();
        },
      ),
    );
  }

  Widget _buildResult(BuildContext context, InviteResult result) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (result.success) ...[
            Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: PawTableColors.successDark,
            ),
            const SizedBox(height: 24),
            Text(
              result.message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              Icons.error_rounded,
              size: 72,
              color: PawTableColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              result.message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(inviteNotifierProvider.notifier).clearError();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demo: Quick Test',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter "DEMO1234" to test the flow. In production, use real invite codes.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                _codeController.text = 'DEMO1234';
              },
              child: const Text('Use Demo Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvite() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isProcessing = true);

    final result = await ref.read(inviteNotifierProvider.notifier).acceptInvite(
          code: code,
          userId: 'demo_user', // In production, from auth provider
          displayName: 'Demo User',
        );

    setState(() => _isProcessing = false);

    if (context.mounted && !result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: PawTableColors.error,
        ),
      );
    }
  }
}
