import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int level;
  final double gold;
  final int gems;
  final int energy;

  const Profile({
    required this.id,
    required this.name,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    required this.level,
    required this.gold,
    required this.gems,
    required this.energy,
  });

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? level,
    double? gold,
    int? gems,
    int? energy,
  }){
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      level: level ?? this.level,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
    );
  }

  @override
  List<Object?> get props => [
    id, name, displayName, createdAt, updatedAt,
    level, gold, gems, energy,
  ];

  @override
  String toString(){
    return 'Profile(id: $id, name: $name, '
        'displayName: $displayName, level: $level, gold: $gold, '
        'gems: $gems, energy: $energy)';
  }
}