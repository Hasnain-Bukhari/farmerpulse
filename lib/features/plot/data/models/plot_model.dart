import 'package:hive/hive.dart';
import '../../domain/entities/plot.dart';

part 'plot_model.g.dart';

/// Hive-annotated model for persisting Plot data.
@HiveType(typeId: 1)
class PlotModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String seasonId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? location;

  @HiveField(4)
  final double area;

  @HiveField(5)
  final String areaUnit;

  @HiveField(6)
  final String? soilType;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime createdAt;

  PlotModel({
    required this.id,
    required this.seasonId,
    required this.name,
    this.location,
    required this.area,
    required this.areaUnit,
    this.soilType,
    this.status = 'active',
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert from domain entity to data model.
  factory PlotModel.fromEntity(Plot entity) {
    return PlotModel(
      id: entity.id,
      seasonId: entity.seasonId,
      name: entity.name,
      location: entity.location,
      area: entity.area,
      areaUnit: entity.areaUnit,
      soilType: entity.soilType,
      status: entity.status.value,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from data model to domain entity.
  Plot toEntity() {
    return Plot(
      id: id,
      seasonId: seasonId,
      name: name,
      location: location,
      area: area,
      areaUnit: areaUnit,
      soilType: soilType,
      status: PlotStatus.fromString(status),
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'PlotModel(id: $id, name: $name)';
}
