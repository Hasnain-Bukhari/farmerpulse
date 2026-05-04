import '../../data/repositories/revenue_repository.dart';

/// Use case for deleting revenue records.
class DeleteRevenueUseCase {
  final RevenueRepository _repository;

  const DeleteRevenueUseCase(this._repository);

  /// Delete a revenue record by ID.
  Future<void> call(String revenueId) async {
    // Validation
    if (revenueId.trim().isEmpty) {
      throw Exception('Revenue ID cannot be empty');
    }

    if (!_repository.revenueExists(revenueId)) {
      throw Exception('Revenue record not found');
    }

    // Delete from database
    await _repository.deleteRevenue(revenueId);
  }
}