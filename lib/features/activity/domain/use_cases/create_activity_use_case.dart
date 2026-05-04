import '../entities/activity.dart';
import '../../data/repositories/activity_repository.dart';

/// Use case for creating a new activity.
class CreateActivityUseCase {
  final ActivityRepository _repository;

  CreateActivityUseCase(this._repository);

  /// Execute the use case.
  Future<void> call(Activity activity) async {
    // Validate: Title must not be empty
    if (activity.title.trim().isEmpty) {
      throw ArgumentError('Activity title cannot be empty');
    }

    // Validate: Cost must be non-negative if provided
    if (activity.cost != null && activity.cost! < 0) {
      throw ArgumentError('Cost cannot be negative');
    }

    // Validate: Quantity must be non-negative if provided
    if (activity.quantity != null && activity.quantity! < 0) {
      throw ArgumentError('Quantity cannot be negative');
    }

    // Validate: Duration must be positive if provided
    if (activity.durationMinutes != null && activity.durationMinutes! <= 0) {
      throw ArgumentError('Duration must be greater than 0');
    }

    await _repository.createActivity(activity);
  }
}
