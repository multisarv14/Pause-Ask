import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/country.dart';
import '../auth/auth_providers.dart';
import '../profile/profile_repository.dart';

/// `scamFeed/{id}` — read-only in the app; added via console / seed script.
class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scamType,
    required this.countryCodes,
    required this.publishedAt,
  });

  factory FeedItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    Map<String, String> texts(Object? raw) => raw is Map
        ? raw.map((k, v) => MapEntry('$k', '$v'))
        : const <String, String>{};
    return FeedItem(
      id: doc.id,
      title: texts(d['title']),
      body: texts(d['body']),
      scamType: d['scamType'] as String? ?? '',
      countryCodes: List<String>.from(d['countryCodes'] as List? ?? const []),
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
    );
  }

  final String id;
  final Map<String, String> title;
  final Map<String, String> body;
  final String scamType;
  final List<String> countryCodes;
  final DateTime publishedAt;

  /// The user's language, falling back to English.
  String titleFor(String lang) => title[lang] ?? title['en'] ?? '';
  String bodyFor(String lang) => body[lang] ?? body['en'] ?? '';
}

/// Active alerts for the user's country, newest first. Live: items added in
/// the Firebase console appear without an app update.
final feedProvider = StreamProvider<List<FeedItem>>((ref) {
  if (!ref.watch(firebaseReadyProvider) ||
      ref.watch(authStateProvider).value == null) {
    return Stream.value(const []);
  }
  final country = countryFromPhone(ref.watch(userProfileProvider).value?.phone);
  return FirebaseFirestore.instance
      .collection('scamFeed')
      .where('active', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (s) => s.docs
            .map(FeedItem.fromDoc)
            .where((i) => !i.publishedAt.isAfter(DateTime.now()))
            .where((i) => feedMatchesCountry(i.countryCodes, country))
            .toList(),
      );
});
