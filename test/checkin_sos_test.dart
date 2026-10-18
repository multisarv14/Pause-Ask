import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:pauseask/core/theme/app_theme.dart';
import 'package:pauseask/features/checkin/checkin_models.dart';
import 'package:pauseask/features/checkin/member_status_card.dart';
import 'package:pauseask/features/checkin/reminder_service.dart';
import 'package:pauseask/features/circle/circle_models.dart';
import 'package:pauseask/features/profile/profile_repository.dart';
import 'package:pauseask/features/profile/user_profile.dart';
import 'package:pauseask/features/settings/battery_guide_screen.dart';
import 'package:pauseask/features/sos/sos_button.dart';
import 'package:pauseask/features/sos/sos_repository.dart';
import 'package:pauseask/features/sos/sos_screens.dart';
import 'package:pauseask/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class FakeSos implements SosRepository {
  int calls = 0;
  @override
  Future<SosResult> send() async {
    calls++;
    return const SosResult(
      guardianCount: 1,
      firstGuardian: SosGuardian(name: 'Ravi', phone: '+919999900002'),
    );
  }
}

CheckinSettings settings({
  DateTime? last,
  String? missed,
  bool enabled = true,
}) => CheckinSettings(
  enabled: enabled,
  time: const TimeOfDay(hour: 9, minute: 0),
  alertAfterHours: 12,
  timezone: 'Asia/Kolkata',
  lastCheckinAt: last,
  lastMissedAlertDate: missed,
);

// 17 Oct 2026, 15:00 IST.
final now = DateTime.utc(2026, 10, 17, 9, 30);

Future<void> pumpApp(
  WidgetTester tester, {
  Widget? home,
  GoRouter? router,
  String lang = 'en',
  List overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({PrefKeys.languageCode: lang});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: router != null
          ? MaterialApp.router(
              theme: AppTheme.light(),
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            )
          : MaterialApp(
              theme: AppTheme.light(),
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: home,
            ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('checkinStatus (member time zone)', () {
    test('OK today, with the IST time', () {
      final r = checkinStatus(
        settings(last: DateTime.utc(2026, 10, 17, 3, 42)),
        now: now,
      );
      expect(r.status, CheckinStatus.ok);
      expect((r.okAt!.hour, r.okAt!.minute), (9, 12)); // 03:42 UTC = 09:12 IST
    });

    test('a check-in before IST midnight counts for yesterday only', () {
      // 18:00 UTC on the 16th = 23:30 IST on the 16th.
      final r = checkinStatus(
        settings(last: DateTime.utc(2026, 10, 16, 18, 0)),
        now: now,
      );
      expect(r.status, CheckinStatus.notYet);
    });

    test('missed today', () {
      expect(
        checkinStatus(settings(missed: '2026-10-17'), now: now).status,
        CheckinStatus.missed,
      );
      expect(
        checkinStatus(settings(missed: '2026-10-16'), now: now).status,
        CheckinStatus.notYet,
      );
    });

    test('off', () {
      expect(
        checkinStatus(settings(enabled: false), now: now).status,
        CheckinStatus.off,
      );
      expect(checkinStatus(null, now: now).status, CheckinStatus.off);
    });
  });

  test('daily reminder: today if still ahead, otherwise tomorrow', () {
    final ist = tz.getLocation('Asia/Kolkata');
    final morning = tz.TZDateTime(ist, 2026, 10, 17, 8, 0);
    final evening = tz.TZDateTime(ist, 2026, 10, 17, 10, 0);
    const nine = TimeOfDay(hour: 9, minute: 0);
    expect(
      nextReminderAt(nine, now: morning),
      tz.TZDateTime(ist, 2026, 10, 17, 9),
    );
    expect(
      nextReminderAt(nine, now: evening),
      tz.TZDateTime(ist, 2026, 10, 18, 9),
    );
  });

  test('battery guide brands', () {
    expect(isAggressiveBrand('Xiaomi', 'Redmi'), isTrue);
    expect(isAggressiveBrand('samsung', 'samsung'), isTrue);
    expect(isAggressiveBrand('OPPO', 'oppo'), isTrue);
    expect(isAggressiveBrand('Google', 'google'), isFalse);
  });

  group('MemberStatusCard', () {
    CircleMember member(CheckinSettings? s) => CircleMember(
      uid: 'p1',
      name: 'Aai',
      roles: const ['protected'],
      phone: '+919999900001',
      checkin: s,
    );

    testWidgets('🟢 OK today at 9:12 AM, with a call button', (tester) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: MemberStatusCard(
            member: member(settings(last: DateTime.utc(2026, 10, 17, 3, 42))),
            now: now,
          ),
        ),
      );
      expect(find.text('🟢'), findsOneWidget);
      // intl puts a narrow no-break space before AM.
      expect(
        find.textContaining(RegExp(r'^OK today at 9:12\sAM$')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('🔴 missed and ⚪ not yet', (tester) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: Column(
            children: [
              MemberStatusCard(
                member: member(settings(missed: '2026-10-17')),
                now: now,
              ),
              MemberStatusCard(member: member(settings()), now: now),
            ],
          ),
        ),
      );
      expect(find.text("Missed today's check-in"), findsOneWidget);
      expect(find.text('Not yet today'), findsOneWidget);
    });

    testWidgets('Marathi', (tester) async {
      await pumpApp(
        tester,
        lang: 'mr',
        home: Scaffold(
          body: MemberStatusCard(
            member: member(settings(missed: '2026-10-17')),
            now: now,
          ),
        ),
      );
      expect(find.text('आजची हजेरी चुकली'), findsOneWidget);
    });
  });

  group('SOS', () {
    GoRouter router() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Center(child: SosButton())),
        ),
        GoRoute(
          path: '/sos/sent',
          builder: (_, s) => SosSentScreen(result: s.extra! as SosResult),
        ),
      ],
    );

    testWidgets('a quick tap does not send', (tester) async {
      final sos = FakeSos();
      await pumpApp(
        tester,
        router: router(),
        overrides: [sosRepositoryProvider.overrideWithValue(sos)],
      );
      await tester.tap(find.text('I need help now'));
      await tester.pumpAndSettle();
      expect(sos.calls, 0);
      expect(find.text('Press and hold for 2 seconds'), findsWidgets);
    });

    testWidgets('releasing after 1 second does not send', (tester) async {
      final sos = FakeSos();
      await pumpApp(
        tester,
        router: router(),
        overrides: [sosRepositoryProvider.overrideWithValue(sos)],
      );
      final g = await tester.startGesture(
        tester.getCenter(find.text('I need help now')),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await g.up();
      await tester.pumpAndSettle();
      expect(sos.calls, 0);
    });

    testWidgets('holding 2 seconds sends and shows the alerted screen', (
      tester,
    ) async {
      final sos = FakeSos();
      await pumpApp(
        tester,
        router: router(),
        overrides: [
          sosRepositoryProvider.overrideWithValue(sos),
          userProfileProvider.overrideWith(
            (ref) => Stream.value(
              const UserProfile(
                uid: 'p1',
                name: 'Aai',
                phone: '+919999900001',
                roles: ['protected'],
                language: 'en',
                largeText: false,
                consentVersion: 1,
              ),
            ),
          ),
        ],
      );
      final g = await tester.startGesture(
        tester.getCenter(find.text('I need help now')),
      );
      // Let the press register, then advance frame by frame for 2 s.
      for (var i = 0; i < 22; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await g.up();
      await tester.pumpAndSettle();
      expect(sos.calls, 1);
      expect(find.text('Your family has been alerted'), findsOneWidget);
      expect(find.text('Call Ravi'), findsOneWidget);
      expect(find.text('Call 1930 – Cyber Crime Helpline'), findsOneWidget);
    });

    testWidgets('1930 is hidden for non-Indian numbers', (tester) async {
      await pumpApp(
        tester,
        home: const SosSentScreen(result: SosResult(guardianCount: 0)),
        overrides: [
          userProfileProvider.overrideWith(
            (ref) => Stream.value(
              const UserProfile(
                uid: 'p1',
                name: 'Mum',
                phone: '+447700900123',
                roles: ['protected'],
                language: 'en',
                largeText: false,
                consentVersion: 1,
              ),
            ),
          ),
        ],
      );
      expect(find.textContaining('1930'), findsNothing);
      expect(
        find.textContaining('Nobody in your family circle could be alerted'),
        findsOneWidget,
      );
    });
  });
}
