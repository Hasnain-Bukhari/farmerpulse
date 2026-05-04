import '../../data/repositories/activity_repository.dart';

/// Use case for deleting an activity.
class DeleteActivityUseCase {
  final ActivityRepository _repository;

  DeleteActivityUseCase(this._repository);

  /// Execute the use case.
  Future<void> call(String activityId) async {
    // Validate: Activity must exist
    final activity = _repository.getActivityById(activityId);
    if (activity == null) {
      throw ArgumentError('Activity not found');
    }

    await _repository.deleteActivity(activityId);
  }
}
