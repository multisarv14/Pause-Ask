import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../check/check_models.dart';
import '../circle/circle_repository.dart';
import '../guardian/guardian_repository.dart';
import '../profile/profile_repository.dart';
import '../../services/firebase/firebase_bootstrap.dart';

/// Guardians see the circle's checks; everyone else their own.
final historyShowsFamilyProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final circle = ref.watch(myCircleProvider).value;
  return (profile?.isGuardian ?? false) && circle != null;
});

/// History list, newest first (max 50; checks expire after 30 days anyway).
final historyChecksProvider = StreamProvider<List<CheckRecord>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (!ref.watch(firebaseReadyProvider) || uid == null) {
    return Stream.value(const []);
  }
  if (ref.watch(historyShowsFamilyProvider)) {
    final circle = ref.watch(myCircleProvider).value!;
    return ref.watch(guardianRepositoryProvider).watchCircleChecks(circle.id);
  }
  return FirebaseFirestore.instance
      .collection('checks')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(CheckRecord.fromDoc).toList());
});

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => FunctionsHistoryRepository(appFunctions()),
);

abstract interface class HistoryRepository {
  /// Owner only (enforced by the `deleteCheck` function).
  Future<void> deleteCheck(String checkId);
}

class FunctionsHistoryRepository implements HistoryRepository {
  FunctionsHistoryRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<void> deleteCheck(String checkId) => _functions
      .httpsCallable('deleteCheck')
      .call<Object?>({'checkId': checkId});
}
