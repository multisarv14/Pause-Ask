import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(FirebaseFirestore.instance),
);

/// The signed-in user's profile; null when signed out or not set up yet.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watch(user.uid);
});

class ProfileRepository {
  ProfileRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<UserProfile?> watch(String uid) => _doc(uid)
      .snapshots(includeMetadataChanges: true)
      // A cache-only "doesn't exist" right after login is not trustworthy
      // (new device, empty cache); wait for the server's answer.
      .where((snap) => snap.exists || !snap.metadata.isFromCache)
      .map(
        (snap) => snap.exists ? UserProfile.fromMap(uid, snap.data()!) : null,
      );

  Future<void> create({
    required String uid,
    required String name,
    required String phone,
    required List<String> roles,
    required String language,
    required bool largeText,
    required int consentVersion,
    required DateTime consentAcceptedAt,
  }) => _doc(uid).set({
    'name': name,
    'phone': phone,
    'roles': roles,
    'language': language,
    'largeText': largeText,
    'consentVersion': consentVersion,
    'consentAcceptedAt': Timestamp.fromDate(consentAcceptedAt),
    'fcmToken': null, // filled in by the notifications step
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> updatePreferences(
    String uid, {
    String? language,
    bool? largeText,
  }) => _doc(uid).update({'language': ?language, 'largeText': ?largeText});

  /// Device token for guardian alerts; null on logout.
  Future<void> updateFcmToken(String uid, String? token) =>
      _doc(uid).update({'fcmToken': token});
}
