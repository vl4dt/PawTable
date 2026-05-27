import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/di/app_module.dart';
import '../../domain/entities/shared_pet_profile_entity.dart';
import '../../domain/repositories/shared_pet_profile_repository.dart';
import '../../../../features/family/domain/entities/family_group_entity.dart';

/// Provider for shared pet profile repository
final sharedPetProfileRepositoryProvider =
    Provider<SharedPetProfileRepository>((ref) {
  return getIt<SharedPetProfileRepository>();
});

/// State for shared pet profiles
class SharedPetProfileState {
  final bool isLoading;
  final String? error;
  final List<SharedPetProfileWithCapabilities> profiles;
  final bool isSharing;

  const SharedPetProfileState({
    this.isLoading = false,
    this.error,
    this.profiles = const [],
    this.isSharing = false,
  });

  SharedPetProfileState copyWith({
    bool? isLoading,
    String? error,
    List<SharedPetProfileWithCapabilities>? profiles,
    bool? isSharing,
  }) {
    return SharedPetProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      profiles: profiles ?? this.profiles,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  /// Check if a pet is shared in this state
  bool isPetShared(String petId) {
    return profiles.any((p) => p.profile.petId == petId);
  }

  /// Get a profile by pet ID
  SharedPetProfileWithCapabilities? getByPetId(String petId) {
    return profiles.firstWhere(
      (p) => p.profile.petId == petId,
      orElse: () => throw Exception('Profile not found'),
    );
  }
}

/// Notifier for shared pet profiles
class SharedPetProfileNotifier extends StateNotifier<SharedPetProfileState> {
  final SharedPetProfileRepository _repository;
  String? _currentGroupId;
  String? _currentUserId;
  String? _currentUserName;

  SharedPetProfileNotifier(this._repository)
      : super(const SharedPetProfileState());

  /// Set the current context (group and user)
  void setContext({
    required String groupId,
    required String userId,
    required String userName,
  }) {
    _currentGroupId = groupId;
    _currentUserId = userId;
    _currentUserName = userName;
  }

  /// Load all shared profiles for the current group
  Future<void> loadProfiles({
    required String groupId,
    required String userId,
    required String userName,
    required List<FamilyMemberEntity> members,
  }) async {
    _currentGroupId = groupId;
    _currentUserId = userId;
    _currentUserName = userName;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final profiles = await _repository.getSharedProfiles(groupId);

      // Find the current user's member entity
      final currentMember = members.firstWhere(
        (m) => m.userId == userId,
        orElse: () => FamilyMemberEntity(
          id: '',
          groupId: groupId,
          userId: userId,
          displayName: userName,
          role: FamilyRole.member,
          joinedAt: DateTime.now(),
        ),
      );

      // Convert to profiles with capabilities
      final profilesWithCaps = profiles.map((profile) {
        final capabilities = _getCapabilities(currentMember.role);
        return SharedPetProfileWithCapabilities(
          profile: profile,
          currentUserId: userId,
          currentUserName: userName,
          memberEntity: currentMember,
          capabilities: capabilities,
        );
      }).toList();

      state = state.copyWith(
        profiles: profilesWithCaps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Share a pet with the current group
  Future<bool> sharePet({
    required String petId,
    required String petName,
  }) async {
    if (_currentGroupId == null || _currentUserId == null) return false;

    state = state.copyWith(isSharing: true, error: null);

    try {
      final profile = await _repository.sharePet(
        petId: petId,
        groupId: _currentGroupId!,
        sharedBy: _currentUserId!,
        sharedByName: _currentUserName ?? 'User',
      );

      final currentMember = FamilyMemberEntity(
        id: '',
        groupId: _currentGroupId!,
        userId: _currentUserId!,
        displayName: _currentUserName ?? 'User',
        role: FamilyRole.owner,
        joinedAt: DateTime.now(),
      );

      final profileWithCaps = SharedPetProfileWithCapabilities(
        profile: profile,
        currentUserId: _currentUserId!,
        currentUserName: _currentUserName ?? 'User',
        memberEntity: currentMember,
        capabilities: _getCapabilities(FamilyRole.owner),
      );

      state = state.copyWith(
        profiles: [...state.profiles, profileWithCaps],
        isSharing: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSharing: false);
      return false;
    }
  }

  /// Unshare a pet from the current group
  Future<bool> unsharePet(String sharedProfileId) async {
    if (_currentGroupId == null) return false;

    try {
      await _repository.unsharePet(sharedProfileId);
      state = state.copyWith(
        profiles: state.profiles
            .where((p) => p.profile.id != sharedProfileId)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Refresh the shared profiles
  Future<void> refresh({
    required String groupId,
    required String userId,
    required String userName,
    required List<FamilyMemberEntity> members,
  }) async {
    await loadProfiles(
      groupId: groupId,
      userId: userId,
      userName: userName,
      members: members,
    );
  }

  /// Get edit capabilities based on role
  LogEditCapability _getCapabilities(FamilyRole role) {
    switch (role) {
      case FamilyRole.owner:
        return LogEditCapability.owner;
      case FamilyRole.admin:
        return LogEditCapability.admin;
      case FamilyRole.member:
        return LogEditCapability.member;
      case FamilyRole.petSitter:
        return LogEditCapability.petSitter;
    }
  }
}

final sharedPetProfileProvider =
    StateNotifierProvider<SharedPetProfileNotifier, SharedPetProfileState>(
        (ref) {
  final repo = ref.watch(sharedPetProfileRepositoryProvider);
  return SharedPetProfileNotifier(repo);
});
