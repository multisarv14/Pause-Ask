import 'package:cloud_firestore/cloud_firestore.dart';

import '../checkin/checkin_models.dart';

/// `circles/{circleId}`
class Circle {
  const Circle({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.memberUids,
  });

  factory Circle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Circle(
      id: doc.id,
      name: d['name'] as String? ?? '',
      ownerUid: d['ownerUid'] as String? ?? '',
      memberUids: List<String>.from(d['memberUids'] as List? ?? const []),
    );
  }

  final String id;
  final String name;
  final String ownerUid;
  final List<String> memberUids;
}

/// `circles/{circleId}/members/{uid}`
class CircleMember {
  const CircleMember({
    required this.uid,
    required this.name,
    required this.roles,
    this.phone = '',
    this.joinedAt,
    this.checkin,
  });

  factory CircleMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return CircleMember(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      roles: List<String>.from(d['roles'] as List? ?? const []),
      phone: d['phone'] as String? ?? '',
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate(),
      checkin: CheckinSettings.fromMap(d['checkin']),
    );
  }

  final String uid;
  final String name;
  final List<String> roles;

  /// Shared inside the circle for "Call now".
  final String phone;
  final DateTime? joinedAt;

  /// Check-in status copied by Cloud Functions (for Guardian Home).
  final CheckinSettings? checkin;
}

/// Result of the `createInvite` function.
class CircleInvite {
  const CircleInvite({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;
}
