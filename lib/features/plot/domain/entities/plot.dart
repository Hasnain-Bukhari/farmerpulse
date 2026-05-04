/// Pure business object representing a farm plot.
///
/// A plot belongs to a season and contains farming activities.
class Plot {
  final String id;
  final String seasonId;
  final String name;
  final String? location;
  final double area;
  final String areaUnit;
  final String? soilType;
  final PlotStatus status;
  final String? notes;
  final DateTime createdAt;

  Plot({
    required this.id,
    required this.seasonId,
    required this.name,
    this.location,
    required this.area,
    required this.areaUnit,
    this.soilType,
    this.status = PlotStatus.active,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy with updated fields.
  Plot copyWith({
    String? id,
    String? seasonId,
    String? name,
    String? location,
    double? area,
    String? areaUnit,
    String? soilType,
    PlotStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Plot(
      id: id ?? this.id,
      seasonId: seasonId ?? this.seasonId,
      name: name ?? this.name,
      location: location ?? this.location,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      soilType: soilType ?? this.soilType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plot && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Plot(id: $id, name: $name, seasonId: $seasonId)';
}

/// Plot status enumeration.
enum PlotStatus {
  active('Active', 'active'),
  fallow('Fallow', 'fallow'),
  retired('Retired', 'retired');

  final String label;
  final String value;

  const PlotStatus(this.label, this.value);

  static PlotStatus fromString(String value) {
    return PlotStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PlotStatus.active,
    );
  }
}
