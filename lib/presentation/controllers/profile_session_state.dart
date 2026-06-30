import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/profile_entity.dart';

class ProfileSessionState {
  final activeProfile = signal<Profile?>(null);

  late final hasActiveProfile = computed(() => activeProfile.value != null);

  void setActiveProfile(Profile profile) => activeProfile.value = profile;

  void clearActiveProfile() => activeProfile.value = null;
}