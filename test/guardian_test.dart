import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:pauseask/core/theme/app_colors.dart';
import 'package:pauseask/core/theme/app_theme.dart';
import 'package:pauseask/features/check/check_models.dart';
import 'package:pauseask/features/check/guardian_response_screen.dart';
import 'package:pauseask/features/check/result_screen.dart';
import 'package:pauseask/features/circle/circle_models.dart';
import 'package:pauseask/features/circle/circle_repository.dart';
import 'package:pauseask/features/guardian/guardian_alert_screen.dart';
import 'package:pauseask/features/guardian/guardian_home_section.dart';
import 'package:pauseask/features/guardian/guardian_repository.dart';
import 'package:pauseask/l10n/app_localizations.dart';
import 'package:pauseask/services/tts/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTts extends TtsService {
  final spoken = <String>[];
  @override
  Future<bool> speak(
    String text, {
    required String languageCode,
    VoidCallback? onDone,
  }) async {
    spoken.add('$languageCode:$text');
    return true;
  }

  @override
  Future<void> stop() async {}
}

class FakeGuardianRepo implements GuardianRepository {
  final replies = <GuardianReply>[];
  bool accept = true;
  @override
  Future<RespondResult> respond(String checkId, GuardianReply reply) async {
    replies.add(reply);
    return RespondResult(
      accepted: accept,
      response: GuardianResponse(
        byUid: 'g2',
        byName: accept ? 'Me' : 'Ravi',
        reply: accept ? reply : GuardianReply.stop,
      ),
    );
  }

  @override
  Stream<CheckRecord?> watchCheck(String checkId) => const Stream.empty();
  @override
  Stream<List<CheckRecord>> watchCircleChecks(String circleId) =>
      const Stream.empty();
}

const circle = Circle(
  id: 'c1',
  name: 'Patil Family',
  ownerUid: 'p1',
  memberUids: ['p1', 'g1', 'g2'],
);
const members = [
  CircleMember(
    uid: 'p1',
    name: 'Aai',
    roles: ['protected'],
    phone: '+919999900001',
  ),
  CircleMember(uid: 'g1', name: 'Ravi', roles: ['guardian']),
  CircleMember(uid: 'g2', name: 'Me', roles: ['guardian']),
];

const result = CheckResult(
  riskLevel: RiskLevel.high,
  scamType: 'Digital arrest',
  redFlags: ['Fake CBI officer'],
  whatToDo: ['Do not pay.', 'Call 1930.', 'Tell family.'],
  summary: 'Police never ask for money on a video call.',
);

CheckRecord record({GuardianResponse? response, int? guardianCount = 2}) =>
    CheckRecord(
      id: 'k1',
      uid: 'p1',
      circleId: 'c1',
      maskedText: 'This is CBI. Pay to [UPI] now.',
      result: result,
      createdAt: DateTime(2026, 10, 17, 10, 30),
      guardianResponse: response,
      guardianCount: guardianCount,
    );

Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  String lang = 'en',
  List overrides = const [],
  GoRouter? router,
}) async {
  SharedPreferences.setMockInitialValues({PrefKeys.languageCode: lang});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  Widget app(Widget? h) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(lang),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: h,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: router == null
          ? app(home)
          : MaterialApp.router(
              theme: AppTheme.light(),
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Protected: full-screen guardian reply', () {
    for (final (reply, color, title) in [
      (GuardianReply.stop, AppColors.riskHigh, 'STOP'),
      (GuardianReply.ok, AppColors.guardianOk, "It's OK"),
      (GuardianReply.call, AppColors.primary, 'Pick up the phone'),
    ]) {
      testWidgets('$reply is shown in its colour and read aloud', (
        tester,
      ) async {
        final tts = FakeTts();
        await pumpApp(
          tester,
          const GuardianResponseScreen(checkId: 'k1'),
          overrides: [
            ttsServiceProvider.overrideWithValue(tts),
            checkRecordProvider('k1').overrideWith(
              (ref) => Stream.value(
                record(
                  response: GuardianResponse(
                    byUid: 'g1',
                    byName: 'Ravi',
                    reply: reply,
                  ),
                ),
              ),
            ),
          ],
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, color);
        expect(find.text(title), findsOneWidget);
        expect(find.textContaining('Ravi'), findsOneWidget);
        expect(tts.spoken.single, startsWith('en:$title.'));
      });
    }

    testWidgets('STOP in Marathi is read with the Marathi voice', (
      tester,
    ) async {
      final tts = FakeTts();
      await pumpApp(
        tester,
        const GuardianResponseScreen(checkId: 'k1'),
        lang: 'mr',
        overrides: [
          ttsServiceProvider.overrideWithValue(tts),
          checkRecordProvider('k1').overrideWith(
            (ref) => Stream.value(
              record(
                response: const GuardianResponse(
                  byUid: 'g1',
                  byName: 'रवी',
                  reply: GuardianReply.stop,
                ),
              ),
            ),
          ),
        ],
      );
      expect(find.text('थांबा'), findsOneWidget);
      expect(find.textContaining('रवी तुम्हाला फोन करतील'), findsOneWidget);
      expect(tts.spoken.single, startsWith('mr:थांबा.'));
    });
  });

  group('Protected: result screen family status', () {
    Future<void> pumpResult(
      WidgetTester tester,
      Stream<CheckRecord?> stream, {
      bool inCircle = true,
    }) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const ResultScreen(
              outcome: CheckOutcome(checkId: 'k1', result: result),
            ),
          ),
          GoRoute(
            path: '/check/response/:checkId',
            builder: (_, s) =>
                GuardianResponseScreen(checkId: s.pathParameters['checkId']!),
          ),
        ],
      );
      await pumpApp(
        tester,
        const SizedBox(),
        router: router,
        overrides: [
          ttsServiceProvider.overrideWithValue(FakeTts()),
          myCircleProvider.overrideWith(
            (ref) => Stream.value(inCircle ? circle : null),
          ),
          checkRecordProvider('k1').overrideWith((ref) => stream),
        ],
      );
    }

    testWidgets('alerting → alerted', (tester) async {
      final c = StreamController<CheckRecord?>();
      await pumpResult(tester, c.stream);
      c.add(record(guardianCount: null));
      await tester.pumpAndSettle();
      expect(find.text('Alerting your family…'), findsOneWidget);
      c.add(record(guardianCount: 2));
      await tester.pumpAndSettle();
      expect(find.text('Your family has been alerted.'), findsOneWidget);
      await c.close();
    });

    testWidgets('circle without guardians', (tester) async {
      await pumpResult(tester, Stream.value(record(guardianCount: 0)));
      expect(
        find.textContaining('Nobody in your circle can reply yet'),
        findsOneWidget,
      );
    });

    testWidgets('no circle → "Add family to get help."', (tester) async {
      await pumpResult(
        tester,
        Stream.value(record(guardianCount: 0)),
        inCircle: false,
      );
      expect(find.text('Add family to get help.'), findsOneWidget);
    });

    testWidgets('a reply arriving live opens the full-screen message once', (
      tester,
    ) async {
      final c = StreamController<CheckRecord?>.broadcast();
      await pumpResult(tester, c.stream);
      c.add(record());
      await tester.pumpAndSettle();
      expect(find.byType(GuardianResponseScreen), findsNothing);

      final stop = record(
        response: const GuardianResponse(
          byUid: 'g1',
          byName: 'Ravi',
          reply: GuardianReply.stop,
        ),
      );
      c.add(stop);
      await tester.pumpAndSettle();
      expect(find.byType(GuardianResponseScreen), findsOneWidget);
      expect(find.text('STOP'), findsOneWidget);

      // Close, then another update must not reopen it.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      c.add(stop);
      await tester.pumpAndSettle();
      expect(find.byType(GuardianResponseScreen), findsNothing);
      expect(find.text('Ravi replied: STOP'), findsOneWidget);
      await c.close();
    });
  });

  group('Guardian alert screen', () {
    Future<FakeGuardianRepo> pumpAlert(
      WidgetTester tester,
      CheckRecord rec, {
      bool accept = true,
    }) async {
      final repo = FakeGuardianRepo()..accept = accept;
      await pumpApp(
        tester,
        const GuardianAlertScreen(checkId: 'k1'),
        overrides: [
          guardianRepositoryProvider.overrideWithValue(repo),
          checkRecordProvider('k1').overrideWith((ref) => Stream.value(rec)),
          circleMembersProvider('c1')
              .overrideWith((ref) => Stream.value(members)),
        ],
      );
      return repo;
    }

    testWidgets('shows who asked, masked text, result and three replies', (
      tester,
    ) async {
      await pumpAlert(tester, record());
      expect(find.textContaining('Aai asked at'), findsOneWidget);
      expect(find.text('This is CBI. Pay to [UPI] now.'), findsOneWidget);
      expect(find.text('High risk'), findsOneWidget);
      expect(
        find.text("STOP – don't do anything, I'll call you"),
        findsOneWidget,
      );
      expect(find.text("I checked – it's OK"), findsOneWidget);
      expect(find.text('Call now'), findsOneWidget);
    });

    testWidgets('STOP sends the reply', (tester) async {
      final repo = await pumpAlert(tester, record());
      await tester.tap(find.text("STOP – don't do anything, I'll call you"));
      await tester.pumpAndSettle();
      expect(repo.replies, [GuardianReply.stop]);
      expect(find.text('Your reply was sent to Aai.'), findsOneWidget);
    });

    testWidgets('losing the race shows who answered first', (tester) async {
      await pumpAlert(tester, record(), accept: false);
      await tester.tap(find.text("I checked – it's OK"));
      await tester.pumpAndSettle();
      expect(find.text('Already answered by Ravi: STOP'), findsOneWidget);
    });

    testWidgets('already answered: STOP/OK hidden, Call still there', (
      tester,
    ) async {
      await pumpAlert(
        tester,
        record(
          response: const GuardianResponse(
            byUid: 'g1',
            byName: 'Ravi',
            reply: GuardianReply.ok,
          ),
        ),
      );
      expect(find.text("Already answered by Ravi: It's OK"), findsOneWidget);
      expect(
        find.text("STOP – don't do anything, I'll call you"),
        findsNothing,
      );
      expect(find.text('Call now'), findsOneWidget);
    });

    testWidgets('Hindi buttons', (tester) async {
      await pumpApp(
        tester,
        const GuardianAlertScreen(checkId: 'k1'),
        lang: 'hi',
        overrides: [
          guardianRepositoryProvider.overrideWithValue(FakeGuardianRepo()),
          checkRecordProvider('k1')
              .overrideWith((ref) => Stream.value(record())),
          circleMembersProvider('c1')
              .overrideWith((ref) => Stream.value(members)),
        ],
      );
      expect(
        find.text('रुकिए – कुछ न करें, आपको अभी फ़ोन आएगा'),
        findsOneWidget,
      );
      expect(find.text('मैंने जाँच लिया – ठीक है'), findsOneWidget);
    });
  });

  group('Guardian Home', () {
    Future<void> pumpHome(
      WidgetTester tester,
      List<CheckRecord> checks,
    ) => pumpApp(
      tester,
      const Scaffold(body: SingleChildScrollView(child: GuardianHomeSection())),
      overrides: [
        openCircleChecksProvider.overrideWith((ref) => Stream.value(checks)),
        myCircleProvider.overrideWith((ref) => Stream.value(circle)),
        circleMembersProvider('c1')
            .overrideWith((ref) => Stream.value(members)),
      ],
    );

    testWidgets('lists open requests with name and risk', (tester) async {
      await pumpHome(tester, [record()]);
      expect(find.text('Family requests'), findsOneWidget);
      // In the request list and in the member status card.
      expect(find.text('Aai'), findsNWidgets(2));
      expect(find.textContaining('High risk ·'), findsOneWidget);
      expect(find.text('Family status'), findsOneWidget);
    });

    testWidgets('empty state', (tester) async {
      await pumpHome(tester, []);
      expect(find.textContaining('No open requests'), findsOneWidget);
    });
  });
}
