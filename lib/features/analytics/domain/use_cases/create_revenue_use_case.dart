import '../../data/repositories/revenue_repository.dart';
import '../entities/revenue.dart';

/// Use case for creating revenue records.
class CreateRevenueUseCase {
  final RevenueRepository _repository;

  const CreateRevenueUseCase(this._repository);

  /// Create a new revenue record.
  Future<void> call(Revenue revenue) async {
    // Validation
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

    // Save to database
    await _repository.createRevenue(revenue);
  }
}