/// Pure business object representing a farming season.
///
/// This is a domain entity with no framework dependencies.
/// Contains business logic methods for season operations.
class Season {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? cropType;
  final String? notes;
  final DateTime createdAt;

  Season({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    this.cropType,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if a given date falls within this season.
  bool isDateInSeason(DateTime date) {
    return (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
        (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));
  }

  /// Calculate the total duration of this season in days.
  int getDurationInDays() {
    return endDate.difference(startDate).inDays;
  }

  /// Check if the season is currently ongoing.
  bool isOngoing() {
    final now = DateTime.now();
    return isDateInSeason(now);
  }

  /// Create a copy with updated fields.
  Season copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? cropType,
    String? notes,
    DateTime? createdAt,
  }) {
    return Season(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      cropType: cropType ?? this.cropType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Season && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Season(id: $id, name: $name, isActive: $isActive)';
}
