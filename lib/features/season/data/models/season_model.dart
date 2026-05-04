import 'package:hive/hive.dart';
import '../../domain/entities/season.dart';

part 'season_model.g.dart';

/// Hive-annotated model for persisting Season data.
///
/// This class handles serialization/deserialization and mapping
/// between the domain entity and database model.
@HiveType(typeId: 0)
class SeasonModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final String? cropType;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  SeasonModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    this.cropType,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert from domain entity to data model.
  factory SeasonModel.fromEntity(Season entity) {
    return SeasonModel(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      cropType: entity.cropType,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from data model to domain entity.
  Season toEntity() {
    return Season(
      id: id,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      cropType: cropType,
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'SeasonModel(id: $id, name: $name)';
}
