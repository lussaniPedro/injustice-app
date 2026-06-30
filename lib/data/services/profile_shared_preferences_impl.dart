import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/profile_entity.dart';
import '../../domain/models/profile_mapper.dart';
import 'profile_local_storage_interface.dart';

final class ProfileSharedPreferencesService implements IProfileLocalStorage {
  static const String _storageKey = 'profiles_data';

  @override
  Future<ListProfileResult> getAllProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(_storageKey);

      if(result == null || result.isEmpty){
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;
      final profiles = decoded
          .map((e) => ProfileMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(profiles);
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter perfis: $e'),
      );
    }
  }

  @override
  Future<ProfileResult> getProfileById(String id) async {
    try {
      final result = await getAllProfiles();

      return result.fold(
        onSuccess: (profiles){
          final profile = profiles.firstWhere(
            (p) => p.id == id,
            orElse: () => throw Exception('Perfil não encontrado'),
          );
          return Success(profile);
        },
        onFailure: (err) => Error(err),
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter perfil: $e'),
      );
    }
  }

  @override
  Future<ProfileResult> saveProfile(Profile profile) async {
    try {
      final current = await getAllProfiles();

      return await current.fold(
        onSuccess: (profiles) async {
          final updated = [...profiles, profile];
          await _saveProfiles(updated);
          return Success(profile);
        },
        onFailure: (failure) async {
          if(failure is EmptyResultFailure){
            await _saveProfiles([profile]);
            return Success(profile);
          }
          return Error(ApiLocalFailure());
        },
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar perfil: $e'),
      );
    }
  }

  @override
  Future<ProfileResult> updateProfile(Profile profile) async {
    try {
      final result = await getAllProfiles();

      return await result.fold(
        onSuccess: (profiles) async {
          final index = profiles.indexWhere((p) => p.id == profile.id);

          if(index == -1){
            throw Exception('Perfil não encontrado');
          }

          final updated = [...profiles];
          updated[index] = profile;

          await _saveProfiles(updated);
          return Success(profile);
        },
        onFailure: (err) => Error(err),
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao atualizar perfil: $e'),
      );
    }
  }

  @override
  Future<VoidResult> deleteProfile(String id) async {
    try {
      final result = await getAllProfiles();

      return await result.fold(
        onSuccess: (profiles) async {
          final updated = profiles.where((p) => p.id != id).toList();
          await _saveProfiles(updated);
          return const Success(null);
        },
        onFailure: (err) => Error(err),
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao deletar perfil: $e'),
      );
    }
  }

  Future<void> _saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      profiles.map((p) => ProfileMapper.toMap(p)).toList(),
    );
    await prefs.setString(_storageKey, jsonString);
  }
}