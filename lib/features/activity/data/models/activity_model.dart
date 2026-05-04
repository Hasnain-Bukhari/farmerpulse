import 'package:hive/hive.dart';
import '../../domain/entities/activity.dart';

part 'activity_model.g.dart';

/// Hive-annotated model for persisting Activity data.
@HiveType(typeId: 2)
class ActivityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String plotId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final int? durationMinutes;

  @HiveField(7)
  final double? cost;

  @HiveField(8)
  final double? quantity;

  @HiveField(9)
  final String? unit;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final List<String> photos;

  @HiveField(12)
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.plotId,
    required this.type,
    required this.title,
    this.description,
    required this.date,
    this.durationMinutes,
    this.cost,
    this.quantity,
    this.unit,
    this.status = 'completed',
    this.photos = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert from domain entity to data model.
  factory ActivityModel.fromEntity(Activity entity) {
    return ActivityModel(
      id: entity.id,
      plotId: entity.plotId,
      type: entity.type.value,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      durationMinutes: entity.durationMinutes,
      cost: entity.cost,
      quantity: entity.quantity,
      unit: entity.unit,
      status: entity.status.value,
      photos: entity.photos,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from data model to domain entity.
  Activity toEntity() {
    return Activity(
      id: id,
      plotId: plotId,
      type: ActivityType.fromString(type),
      title: title,
      description: description,
      date: date,
      durationMinutes: durationMinutes,
      cost: cost,
      quantity: quantity,
      unit: unit,
      status: ActivityStatus.fromString(status),
      photos: photos,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'ActivityModel(id: $id, type: $type)';
}
