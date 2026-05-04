/// Pure business object representing a farm activity.
///
/// An activity belongs to a plot and represents work done on that plot.
class Activity {
  final String id;
  final String plotId;
  final ActivityType type;
  final String title;
  final String? description;
  final DateTime date;
  final int? durationMinutes;
  final double? cost;
  final double? quantity;
  final String? unit;
  final ActivityStatus status;
  final List<String> photos;
  final DateTime createdAt;

  Activity({
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
    this.status = ActivityStatus.completed,
    this.photos = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if activity happened today.
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if activity is overdue (planned but date passed).
  bool isOverdue() {
    return status == ActivityStatus.planned && date.isBefore(DateTime.now());
  }

  /// Get formatted duration string.
  String? getFormattedDuration() {
    if (durationMinutes == null) return null;
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  /// Create a copy with updated fields.
  Activity copyWith({
    String? id,
    String? plotId,
    ActivityType? type,
    String? title,
    String? description,
    DateTime? date,
    int? durationMinutes,
    double? cost,
    double? quantity,
    String? unit,
    ActivityStatus? status,
    List<String>? photos,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Activity(id: $id, type: ${type.label}, plotId: $plotId)';
}

/// Activity type enumeration.
enum ActivityType {
  landPreparation('Land Preparation', 'land_preparation'),
  seeding('Seeding', 'seeding'),
  watering('Watering', 'watering'),
  spray('Spray', 'spray'),
  harvest('Harvest', 'harvest'),
  fertilizer('Fertilizer', 'fertilizer'),
  cleaning('Cleaning', 'cleaning');

  final String label;
  final String value;

  const ActivityType(this.label, this.value);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.cleaning,
    );
  }
}

/// Activity status enumeration.
enum ActivityStatus {
  planned('Planned', 'planned'),
  completed('Completed', 'completed'),
  cancelled('Cancelled', 'cancelled');

  final String label;
  final String value;

  const ActivityStatus(this.label, this.value);

  static ActivityStatus fromString(String value) {
    return ActivityStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ActivityStatus.completed,
    );
  }
}
