/// Domain entity representing revenue for a season or plot.
class Revenue {
  final String id;
  final String seasonId;
  final String? plotId; // null means season-wide revenue
  final double amount;
  final RevenueType type;
  final String description;
  final DateTime recordedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Revenue({
    required this.id,
    required this.seasonId,
    this.plotId,
    required this.amount,
    required this.type,
    required this.description,
    required this.recordedDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with modified properties.
  Revenue copyWith({
    String? id,
    String? seasonId,
    String? plotId,
    double? amount,
    RevenueType? type,
    String? description,
    DateTime? recordedDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Revenue(
      id: id ?? this.id,
      seasonId: seasonId ?? this.seasonId,
      plotId: plotId ?? this.plotId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      recordedDate: recordedDate ?? this.recordedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this revenue is for a specific plot.
  bool get isPlotSpecific => plotId != null;

  /// Check if this revenue is season-wide.
  bool get isSeasonWide => plotId == null;

  /// Get formatted amount with currency.
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Revenue && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Revenue{id: $id, amount: $amount, type: $type, description: $description}';
  }
}

/// Profit/Loss calculation result.
class ProfitLossResult {
  final String seasonId;
  final String? plotId;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final List<Revenue> revenues;
  final Map<String, double> expensesByType;
  final DateTime calculatedAt;

  const ProfitLossResult({
    required this.seasonId,
    this.plotId,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.revenues,
    required this.expensesByType,
    required this.calculatedAt,
  });

  /// Check if the result shows a profit.
  bool get isProfit => netProfit > 0;

  /// Check if the result shows a loss.
  bool get isLoss => netProfit < 0;

  /// Check if break-even.
  bool get isBreakEven => netProfit == 0;

  /// Get profit status description.
  String get profitStatus {
    if (isProfit) return 'Profit';
    if (isLoss) return 'Loss';
    return 'Break Even';
  }

  /// Get return on investment (ROI) percentage.
  double get roi {
    if (totalExpenses == 0) return 0.0;
    return (netProfit / totalExpenses) * 100;
  }

  /// Get formatted net profit with currency.
  String get formattedNetProfit => '\$${netProfit.abs().toStringAsFixed(2)}';

  /// Get formatted profit margin as percentage.
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';

  /// Get formatted ROI as percentage.
  String get formattedROI => '${roi.toStringAsFixed(1)}%';

  /// Get revenue breakdown by type.
  Map<String, double> get revenuesByType {
    final breakdown = <String, double>{};
    
    for (final revenue in revenues) {
      final type = revenue.type.label;
      breakdown[type] = (breakdown[type] ?? 0.0) + revenue.amount;
    }
    
    return breakdown;
  }

  /// Get most profitable revenue type.
  String? get mostProfitableType {
    final revenueTypes = revenuesByType;
    if (revenueTypes.isEmpty) return null;
    
    return revenueTypes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get break-even analysis.
  BreakEvenAnalysis getBreakEvenAnalysis() {
    return BreakEvenAnalysis(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      breakEvenRevenue: totalExpenses,
      revenueNeeded: isLoss ? netProfit.abs() : 0.0,
    );
  }
}

/// Break-even analysis result.
class BreakEvenAnalysis {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double breakEvenRevenue;
  final double revenueNeeded;

  const BreakEvenAnalysis({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.breakEvenRevenue,
    required this.revenueNeeded,
  });

  /// Get percentage to break-even.
  double get percentageToBreakEven {
    if (totalRevenue == 0) return 100.0;
    return (revenueNeeded / totalRevenue) * 100;
  }

  /// Check if already at break-even or profit.
  bool get isBreakEvenOrProfit => revenueNeeded == 0.0;

  /// Get formatted revenue needed.
  String get formattedRevenueNeeded => '\$${revenueNeeded.toStringAsFixed(2)}';

  /// Get formatted percentage to break-even.
  String get formattedPercentageToBreakEven => '${percentageToBreakEven.toStringAsFixed(1)}%';
}

/// Types of revenue sources.
enum RevenueType {
  harvest('Harvest Sales', 'Revenue from selling harvested crops'),
  livestock('Livestock Sales', 'Revenue from selling livestock'),
  produce('Produce Sales', 'Revenue from fresh produce sales'),
  equipment('Equipment Rental', 'Revenue from renting out equipment'),
  services('Services', 'Revenue from providing farming services'),
  subsidies('Subsidies', 'Government subsidies and grants'),
  insurance('Insurance Claims', 'Insurance payouts for crop/livestock'),
  other('Other', 'Other revenue sources');

  const RevenueType(this.label, this.description);

  final String label;
  final String description;
}