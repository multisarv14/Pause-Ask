import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../check/check_models.dart';
import '../circle/circle_repository.dart';
import '../../services/firebase/firebase_bootstrap.dart';

final guardianRepositoryProvider = Provider<GuardianRepository>(
  (ref) => GuardianRepository(FirebaseFirestore.instance, appFunctions()),
);

/// One check, live (the asker's result screen and the guardian alert screen).
final checkRecordProvider = StreamProvider.family<CheckRecord?, String>((
  ref,
  checkId,
) {
  if (!ref.watch(firebaseReadyProvider)) return Stream.value(null);
  return ref.watch(guardianRepositoryProvider).watchCheck(checkId);
});

/// Unanswered checks by other members of my circle, newest first.
final openCircleChecksProvider = StreamProvider<List<CheckRecord>>((ref) {
  final circle = ref.watch(myCircleProvider).value;
  final myUid = ref.watch(authStateProvider).value?.uid;
  if (circle == null || myUid == null) return Stream.value(const []);
  return ref
      .watch(guardianRepositoryProvider)
      .watchCircleChecks(circle.id)
      .map(
        (checks) => checks
            .where((c) => c.uid != myUid && c.guardianResponse == null)
            .toList(),
      );
});

class RespondResult {
  const RespondResult({required this.accepted, required this.response});

  /// False when another guardian answered first.
  final bool accepted;
  final GuardianResponse response;
}

class GuardianRepository {
  GuardianRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<CheckRecord?> watchCheck(String checkId) => _db
      .doc('checks/$checkId')
      .snapshots()
      .map((s) => s.exists ? CheckRecord.fromDoc(s) : null);

  Stream<List<CheckRecord>> watchCircleChecks(String circleId) => _db
      .collection('checks')
      .where('circleId', isEqualTo: circleId)
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots()
      .map((s) => s.docs.map(CheckRecord.fromDoc).toList());

  Future<RespondResult> respond(String checkId, GuardianReply reply) async {
    final result = await _functions
        .httpsCallable('respondToCheck')
        .call<Object?>({'checkId': checkId, 'type': reply.wire});
    final data = Map<String, dynamic>.from(result.data as Map);
    return RespondResult(
      accepted: data['accepted'] == true,
      response: GuardianResponse.fromMap(data['response'])!,
    );
  }
}
