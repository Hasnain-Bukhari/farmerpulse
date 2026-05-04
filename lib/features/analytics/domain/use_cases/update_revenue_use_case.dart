import '../../data/repositories/revenue_repository.dart';
import '../entities/revenue.dart';

/// Use case for updating revenue records.
class UpdateRevenueUseCase {
  final RevenueRepository _repository;

  const UpdateRevenueUseCase(this._repository);

  /// Update an existing revenue record.
  Future<void> call(Revenue revenue) async {
    // Validation
    if (!_repository.revenueExists(revenue.id)) {
      throw Exception('Revenue record not found');
    }

    if (revenue.description.trim().isEmpty) {
      throw Exception('Revenue description cannot be empty');
    }

    if (revenue.amount <= 0) {
      throw Exception('Revenue amount must be greater than zero');
    }

    if (revenue.seasonId.trim().isEmpty) {
      throw Exception('Season ID is required');
    }

    if (revenue.recordedDate.isAfter(DateTime.now())) {
      throw Exception('Revenue date cannot be in the future');
    }

    // Update with current timestamp
    final updatedRevenue = revenue.copyWith(
      updatedAt: DateTime.now(),
    );

    // Save to database
    await _repository.updateRevenue(updatedRevenue);
  }
}