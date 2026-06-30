import 'profile_entity.dart';

class ProfileMapper {
  static Map<String, dynamic> toMap(Profile profile){
    return {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'displayName': profile.displayName,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
      'level': profile.level,
      'gold': profile.gold,
      'gems': profile.gems,
      'energy': profile.energy,
    };
  }

  static Profile fromMap(Map<String, dynamic> map){
    return Profile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      level: map['level'] as int,
      gold: (map['gold'] as num).toDouble(),
      gems: map['gems'] as int,
      energy: map['energy'] as int,
    );
  }
}