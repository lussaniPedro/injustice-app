import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/profile_entity.dart';

enum ProfileSuccessEvent { created, updated, deleted }

class ProfilesStateViewModel {
  final state = signal<List<Profile>>([]);
  final message = signal<String?>(null);
  final successEvent = signal<ProfileSuccessEvent?>(null);

  late final canCreateMore = computed(() => state.value.length < 4);
  late final hasProfiles = computed(() => state.value.isNotEmpty);

  void clearMessage() => message.value = null;
  void setMessage(String msg) => message.value = msg;
  void clearSuccessEvent() => successEvent.value = null;
}