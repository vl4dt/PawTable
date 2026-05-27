import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/invite_repository.dart';

// =========================================================================
// INVITE STATE
// =========================================================================

/// UI state for invite operations
enum InviteOperation { none, creating, accepting, cancelling }

class InviteState {
  final InviteOperation operation;
  final InviteToken? inviteToken;
  final InviteResult? inviteResult;
  final bool isLoading;
  final String? error;
  final List<InviteToken> activeInvites;

  const InviteState({
    this.operation = InviteOperation.none,
    this.inviteToken,
    this.inviteResult,
    this.isLoading = false,
    this.error,
    this.activeInvites = const [],
  });

  InviteState copyWith({
    InviteOperation? operation,
    InviteToken? inviteToken,
    InviteResult? inviteResult,
    bool? isLoading,
    String? error,
    List<InviteToken>? activeInvites,
  }) {
    return InviteState(
      operation: operation ?? this.operation,
      inviteToken: inviteToken ?? this.inviteToken,
      inviteResult: inviteResult ?? this.inviteResult,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      activeInvites: activeInvites ?? this.activeInvites,
    );
  }
}

// =========================================================================
// PROVIDER
// =========================================================================

/// Provider for managing family invites
class InviteNotifier extends StateNotifier<InviteState> {
  InviteNotifier({
    required InviteRepository inviteRepository,
  })  : _inviteRepository = inviteRepository,
        super(const InviteState()) {
    // Listen to active invites
    _listenActiveInvites();
  }

  final InviteRepository _inviteRepository;

  void _listenActiveInvites() {
    // In production, groupId would come from auth/family provider
  }

  /// Create a new invite for the given group
  Future<InviteToken?> createInvite({
    required String groupId,
    required String createdById,
    int maxUses = 1,
    Duration expiry = const Duration(days: 7),
  }) async {
    state = state.copyWith(
      operation: InviteOperation.creating,
      isLoading: true,
      error: null,
    );

    try {
      final token = await _inviteRepository.createInvite(
        groupId: groupId,
        createdById: createdById,
        maxUses: maxUses,
        expiry: expiry,
      );
      state = state.copyWith(
        inviteToken: token,
        operation: InviteOperation.none,
        isLoading: false,
      );
      return token;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create invite: $e',
        operation: InviteOperation.none,
        isLoading: false,
      );
      return null;
    }
  }

  /// Accept an invite via deep link or code
  Future<InviteResult> acceptInvite({
    required String code,
    required String userId,
    required String displayName,
  }) async {
    state = state.copyWith(
      operation: InviteOperation.accepting,
      isLoading: true,
      error: null,
    );

    try {
      // Validate the invite first
      final token = await _inviteRepository.validateInvite(code);
      if (token == null) {
        state = state.copyWith(
          inviteResult: InviteResult.invalid(),
          operation: InviteOperation.none,
          isLoading: false,
        );
        return InviteResult.invalid();
      }

      // Accept the invite
      final result = await _inviteRepository.acceptInvite(
        code: code,
        userId: userId,
        displayName: displayName,
      );

      state = state.copyWith(
        inviteResult: result,
        operation: InviteOperation.none,
        isLoading: false,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to accept invite: $e',
        operation: InviteOperation.none,
        isLoading: false,
      );
      return InviteResult.failure('Failed to accept invite: $e');
    }
  }

  /// Cancel an invite
  Future<void> cancelInvite(String inviteId) async {
    state = state.copyWith(
      operation: InviteOperation.cancelling,
      isLoading: true,
      error: null,
    );

    try {
      await _inviteRepository.cancelInvite(inviteId);
      state = state.copyWith(
        operation: InviteOperation.none,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to cancel invite: $e',
        operation: InviteOperation.none,
        isLoading: false,
      );
    }
  }

  /// Share the invite code by copying to clipboard
  Future<void> copyInviteCode(InviteToken token) async {
    await Clipboard.setData(ClipboardData(text: token.code));
    state = state.copyWith(
      error: 'Invite code copied to clipboard!',
    );
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(error: null);
    });
  }

  /// Generate share text for the invite
  String buildShareText(InviteToken token) {
    return '''
Join my family on PawTable!

Use this code: ${token.code}

Or tap the link below:
${token.toShareLink()}
''';
  }

  /// Clear the error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for the invite system
final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  throw UnimplementedError('InviteRepository not registered');
});

final inviteNotifierProvider =
    StateNotifierProvider<InviteNotifier, InviteState>((ref) {
  final repository = ref.watch(inviteRepositoryProvider);
  return InviteNotifier(inviteRepository: repository);
});
