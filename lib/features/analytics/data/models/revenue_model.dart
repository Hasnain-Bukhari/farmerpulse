import 'package:hive/hive.dart';
import '../../domain/entities/revenue.dart';

part 'revenue_model.g.dart';

/// Hive model for Revenue entity.
@HiveType(typeId: 4)
class RevenueModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String seasonId;

  @HiveField(2)
  String? plotId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  int typeIndex; // Store enum index

  @HiveField(5)
  String description;

  @HiveField(6)
  DateTime recordedDate;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  RevenueModel({
    required this.id,
    required this.seasonId,
    this.plotId,
    required this.amount,
    required this.typeIndex,
    required this.description,
    required this.recordedDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from domain entity to Hive model.
  factory RevenueModel.fromEntity(Revenue revenue) {
    return RevenueModel(
      id: revenue.id,
      seasonId: revenue.seasonId,
      plotId: revenue.plotId,
      amount: revenue.amount,
      typeIndex: revenue.type.index,
      description: revenue.description,
      recordedDate: revenue.recordedDate,
      notes: revenue.notes,
      createdAt: revenue.createdAt,
      updatedAt: revenue.updatedAt,
    );
  }

  /// Convert from Hive model to domain entity.
  Revenue toEntity() {
    return Revenue(
      id: id,
      seasonId: seasonId,
      plotId: plotId,
      amount: amount,
      type: RevenueType.values[typeIndex],
      description: description,
      recordedDate: recordedDate,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}