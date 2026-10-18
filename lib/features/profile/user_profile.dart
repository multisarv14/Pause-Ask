import '../checkin/checkin_models.dart';

/// Role values stored in `users/{uid}.roles`.
abstract final class UserRoles {
  static const protected = 'protected';
  static const guardian = 'guardian';
}

/// The three choices offered at profile setup.
enum RoleChoice {
  protected([UserRoles.protected]),
  guardian([UserRoles.guardian]),
  both([UserRoles.protected, UserRoles.guardian]);

  const RoleChoice(this.roles);
  final List<String> roles;
}

/// Firestore document `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.roles,
    required this.language,
    required this.largeText,
    required this.consentVersion,
    this.checkin,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) =>
      UserProfile(
        uid: uid,
        name: data['name'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        roles: List<String>.from(data['roles'] as List? ?? const []),
        language: data['language'] as String? ?? 'en',
        largeText: data['largeText'] as bool? ?? false,
        consentVersion: data['consentVersion'] as int? ?? 0,
        checkin: CheckinSettings.fromMap(data['checkin']),
      );

  final String uid;
  final String name;
  final String phone;
  final List<String> roles;
  final String language;
  final bool largeText;
  final int consentVersion;

  /// Daily "I'm OK" settings; null until first saved.
  final CheckinSettings? checkin;

  bool get isProtected => roles.contains(UserRoles.protected);
  bool get isGuardian => roles.contains(UserRoles.guardian);
}
