import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/core/constants/app_constants.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:pauseask/core/theme/app_colors.dart';
import 'package:pauseask/core/theme/app_theme.dart';
import 'package:pauseask/core/utils/country.dart';
import 'package:pauseask/features/auth/auth_providers.dart';
import 'package:pauseask/features/check/check_models.dart';
import 'package:pauseask/features/feed/feed_repository.dart';
import 'package:pauseask/features/feed/feed_widgets.dart';
import 'package:pauseask/features/history/history_repository.dart';
import 'package:pauseask/features/history/history_screens.dart';
import 'package:pauseask/features/home/home_screen.dart';
import 'package:pauseask/features/profile/profile_repository.dart';
import 'package:pauseask/features/profile/user_profile.dart';
import 'package:pauseask/features/checkin/checkin_models.dart';
import 'package:pauseask/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

class FakeHistoryRepo implements HistoryRepository {
  final deleted = <String>[];
  @override
  Future<void> deleteCheck(String checkId) async => deleted.add(checkId);
}

const result = CheckResult(
  riskLevel: RiskLevel.high,
  scamType: 'KYC',
  redFlags: ['Link to a fake bank page'],
  whatToDo: ['Do not click.', 'Call your bank.', 'Tell family.'],
  summary: 'Banks never ask for KYC through SMS links.',
);

CheckRecord check(String id, {String uid = 'me', GuardianResponse? reply}) =>
    CheckRecord(
      id: id,
      uid: uid,
      circleId: null,
      maskedText: 'Update KYC at http://bank-kyc.in',
      result: result,
      createdAt: DateTime(2026, 10, 17, 9, 5),
      guardianResponse: reply,
    );

FeedItem item(String id, String en, {String? hi, int daysAgo = 0}) => FeedItem(
  id: id,
  title: {'en': en, 'hi': ?hi},
  body: {'en': 'Body of $en', if (hi != null) 'hi': 'विवरण $hi'},
  scamType: 'x',
  countryCodes: const ['ALL'],
  publishedAt: DateTime(2026, 10, 17).subtract(Duration(days: daysAgo)),
);

Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  String lang = 'en',
  double textScale = 1.0,
  Size size = const Size(1080, 2400),
  List overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({PrefKeys.languageCode: lang});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: Locale(lang),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('History', () {
    testWidgets('own checks: colour, date, summary, reply, note, delete', (
      tester,
    ) async {
      final repo = FakeHistoryRepo();
      await pumpApp(
        tester,
        const HistoryScreen(),
        overrides: [
          currentUidProvider.overrideWithValue('me'),
          historyShowsFamilyProvider.overrideWithValue(false),
          historyRepositoryProvider.overrideWithValue(repo),
          historyChecksProvider.overrideWith(
            (ref) => Stream.value([
              check(
                'c1',
                reply: const GuardianResponse(
                  byUid: 'g',
                  byName: 'Ravi',
                  reply: GuardianReply.stop,
                ),
              ),
              check('c2'),
            ]),
          ),
        ],
      );
      expect(find.text('My checks'), findsOneWidget);
      expect(
        find.text('Checks are automatically deleted after 30 days.'),
        findsOneWidget,
      );
      expect(find.textContaining('High risk · 17 Oct'), findsNWidgets(2));
      expect(
        find.text('Banks never ask for KYC through SMS links.'),
        findsNWidgets(2),
      );
      expect(find.text('Ravi replied: STOP'), findsOneWidget);
      expect(find.text('No reply yet'), findsOneWidget);
      final bar = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == AppColors.riskHigh);
      expect(bar.length, 2);

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete this check?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(repo.deleted, ['c1']);
    });

    testWidgets('family view: names shown, no delete on others\' checks', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const HistoryScreen(),
        overrides: [
          currentUidProvider.overrideWithValue('me'),
          historyShowsFamilyProvider.overrideWithValue(true),
          historyChecksProvider.overrideWith(
            (ref) => Stream.value([check('c3', uid: 'aai')]),
          ),
        ],
      );
      expect(find.text('Family checks'), findsOneWidget);
      expect(find.byTooltip('Delete'), findsNothing);
    });

    testWidgets('friendly empty state (Marathi)', (tester) async {
      await pumpApp(
        tester,
        const HistoryScreen(),
        lang: 'mr',
        overrides: [
          historyShowsFamilyProvider.overrideWithValue(false),
          historyChecksProvider.overrideWith(
            (ref) => Stream.value(const <CheckRecord>[]),
          ),
        ],
      );
      expect(find.text('अजून एकही तपासणी नाही'), findsOneWidget);
      expect(find.textContaining('थांबा आणि विचारा'), findsOneWidget);
    });
  });

  group('Scam feed', () {
    test('country from phone', () {
      expect(countryFromPhone('+91 98765 43210'), 'IN');
      expect(countryFromPhone('+971501234567'), 'AE');
      expect(countryFromPhone('+447700900123'), 'GB');
      expect(countryFromPhone('+33612345678'), 'OTHER');
      expect(feedMatchesCountry(['ALL'], 'OTHER'), isTrue);
      expect(feedMatchesCountry(['IN'], 'GB'), isFalse);
    });

    testWidgets('home card shows the latest alert in the user\'s language', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Scaffold(body: SingleChildScrollView(child: FeedCard())),
        lang: 'hi',
        overrides: [
          feedProvider.overrideWith(
            (ref) => Stream.value([
              item('new', 'KYC scam', hi: 'KYC धोखा'),
              item('old', 'Old one', hi: 'पुराना', daysAgo: 3),
            ]),
          ),
        ],
      );
      expect(find.text('आज का स्कैम अलर्ट'), findsOneWidget);
      expect(find.text('KYC धोखा'), findsOneWidget);
      expect(find.text('पुराना'), findsNothing);
      expect(find.text('यह अलर्ट शेयर करें'), findsOneWidget);
      expect(find.text('सभी देखें'), findsOneWidget);
    });

    testWidgets('falls back to English when a translation is missing', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Scaffold(body: SingleChildScrollView(child: FeedCard())),
        lang: 'mr',
        overrides: [
          feedProvider.overrideWith(
            (ref) => Stream.value([item('a', 'Only English')]),
          ),
        ],
      );
      expect(find.text('Only English'), findsOneWidget);
    });

    testWidgets('"See all" lists newest first with a share button each', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const FeedScreen(),
        overrides: [
          feedProvider.overrideWith(
            (ref) => Stream.value([
              item('a', 'First'),
              item('b', 'Second', daysAgo: 1),
            ]),
          ),
        ],
      );
      final first = tester.getTopLeft(find.text('First')).dy;
      final second = tester.getTopLeft(find.text('Second')).dy;
      expect(first, lessThan(second));
      expect(find.text('Share this alert'), findsNWidgets(2));
    });

    test('share text has the alert, the promo and the store link', () {
      final l10n = lookupAppLocalizations(const Locale('mr'));
      final text = feedShareText(l10n, item('a', 'KYC', hi: 'KYC'), 'mr');
      expect(text, contains('KYC'));
      expect(text, contains('PauseAsk ने तुमच्या कुटुंबाचं रक्षण करा'));
      expect(text, contains(AppConstants.playStoreUrl));
    });
  });

  group('Home', () {
    test('greeting by time of day', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        homeGreeting(l10n, 'Asha', now: DateTime(2026, 1, 1, 8)),
        'Good morning, Asha',
      );
      expect(
        homeGreeting(l10n, 'Asha', now: DateTime(2026, 1, 1, 14)),
        'Good afternoon, Asha',
      );
      expect(
        homeGreeting(l10n, 'Asha', now: DateTime(2026, 1, 1, 20)),
        'Good evening, Asha',
      );
    });

    for (final lang in ['en', 'hi', 'mr']) {
      testWidgets(
        'both-role home fits in large text on a small phone ($lang)',
        (tester) async {
          await pumpApp(
            tester,
            const HomeScreen(),
            lang: lang,
            textScale: 1.69,
            size: const Size(960, 1920),
            overrides: [
              userProfileProvider.overrideWith(
                (ref) => Stream.value(
                  const UserProfile(
                    uid: 'me',
                    name: 'Shakuntala Deshpande',
                    phone: '+919999900001',
                    roles: ['protected', 'guardian'],
                    language: 'en',
                    largeText: true,
                    consentVersion: 1,
                    checkin: CheckinSettingsFixture.on,
                  ),
                ),
              ),
              feedProvider.overrideWith(
                (ref) => Stream.value([
                  item(
                    'a',
                    'Fake "digital arrest" video calls',
                    hi: 'नकली "डिजिटल अरेस्ट" वीडियो कॉल',
                  ),
                ]),
              ),
            ],
          );
          expect(tester.takeException(), isNull);
          // Scroll through the whole page so every section is laid out.
          await tester.drag(
            find.byType(ListView).first,
            const Offset(0, -5000),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}

abstract final class CheckinSettingsFixture {
  static const on = CheckinSettings(
    enabled: true,
    time: TimeOfDay(hour: 9, minute: 0),
    alertAfterHours: 12,
    timezone: 'Asia/Kolkata',
  );
}
