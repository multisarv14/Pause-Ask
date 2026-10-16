import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../auth/auth_providers.dart';
import 'circle_models.dart';

final circleRepositoryProvider = Provider<CircleRepository>(
  (ref) => CircleRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instanceFor(region: AppConstants.firebaseRegion),
  ),
);

/// The circle the signed-in user belongs to (max 1), or null.
final myCircleProvider = StreamProvider<Circle?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(circleRepositoryProvider).watchMyCircle(user.uid);
});

/// Members of [circleId]: owner first, then by join date.
final circleMembersProvider = StreamProvider.family<List<CircleMember>, String>(
  (ref, circleId) => ref.watch(circleRepositoryProvider).watchMembers(circleId),
);

/// Reads come straight from Firestore (rules: members only).
/// Every write goes through a callable Cloud Function.
class CircleRepository {
  CircleRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<Circle?> watchMyCircle(String uid) => _db
      .collection('circles')
      .where('memberUids', arrayContains: uid)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : Circle.fromDoc(s.docs.first));

  Stream<List<CircleMember>> watchMembers(String circleId) => _db
      .collection('circles/$circleId/members')
      .orderBy('joinedAt')
      .snapshots()
      .map((s) => s.docs.map(CircleMember.fromDoc).toList());

  Future<Map<String, dynamic>> _call(String name, [Object? data]) async {
    final result = await _functions.httpsCallable(name).call<Object?>(data);
    return Map<String, dynamic>.from(result.data as Map? ?? const {});
  }

  Future<String> createCircle(String name) async =>
      (await _call('createCircle', {'name': name}))['circleId'] as String;

  Future<CircleInvite> createInvite() async {
    final r = await _call('createInvite');
    return CircleInvite(
      code: r['code'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (r['expiresAt'] as num).toInt(),
      ),
    );
  }

  Future<String> joinCircle(String code) async =>
      (await _call('joinCircle', {'code': code}))['circleId'] as String;

  Future<void> leaveCircle() => _call('leaveCircle');

  Future<void> removeMember(String uid) => _call('removeMember', {'uid': uid});
}
