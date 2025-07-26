import '../model/time_capsule_model.dart';

class TimeCapsulePresenter {
  final TimeCapsuleModel model;
  final void Function() showLoading;
  final void Function() hideLoading;
  final void Function(List<Map<String, dynamic>>) showCapsules;
  final void Function(String) showError;

  TimeCapsulePresenter({
    required this.model,
    required this.showLoading,
    required this.hideLoading,
    required this.showCapsules,
    required this.showError,
  });

  Future<void> loadCapsules() async {
    try {
      showLoading();
      final capsules = await model.getTimeCapsulesForUser();
      showCapsules(capsules);
    } catch (e) {
      showError('Error loading capsules: $e');
    } finally {
      hideLoading();
    }
  }

  Future<void> openCapsule(String capsuleId) async {
    try {
      await model.markAsOpened(capsuleId);
      await loadCapsules();
    } catch (e) {
      showError('Error trying to open the capsule: $e');
    }
  }
}
