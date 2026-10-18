import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:pauseask/core/theme/app_colors.dart';
import 'package:pauseask/core/theme/app_theme.dart';
import 'package:pauseask/features/check/check_error.dart';
import 'package:pauseask/features/check/check_models.dart';
import 'package:pauseask/features/check/check_repository.dart';
import 'package:pauseask/features/check/checking_screen.dart';
import 'package:pauseask/features/check/compose_screen.dart';
import 'package:pauseask/features/check/result_screen.dart';
import 'package:pauseask/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingRepo implements CheckRepository {
  _FailingRepo(this.error);
  final CheckError error;
  @override
  Future<CheckOutcome> analyze(CheckDraft draft, {required String language}) =>
      Future.error(error);
}

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
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
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

CheckOutcome outcome(RiskLevel level, {bool long = false}) => CheckOutcome(
  checkId: 'c1',
  result: CheckResult(
    riskLevel: level,
    scamType: 'Digital arrest',
    redFlags: [
      'Someone claims to be from CBI',
      if (long) 'They say your Aadhaar is linked to money laundering and you must stay on a video call',
      'Asks you to move money to a "safe account"',
    ],
    whatToDo: [
      'Do not send any money.',
      'Cut the call and call 1930, the cyber crime helpline.',
      'Tell a family member right now.',
    ],
    summary: 'Police never ask you to transfer money on a video call.',
  ),
);

Color bannerColor(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(RiskBanner),
        matching: find.byType(Container),
      ),
    )
    .first
    .color!;

void main() {
  group('ResultScreen', () {
    final expectations = {
      RiskLevel.high: (
        AppColors.riskHigh,
        'High risk',
        'बहुत ज़्यादा खतरा',
        'मोठा धोका',
      ),
      RiskLevel.suspicious: (
        AppColors.riskSuspicious,
        'Suspicious',
        'संदिग्ध',
        'संशयास्पद',
      ),
      RiskLevel.beCareful: (
        AppColors.riskBeCareful,
        'Be careful',
        'सावधान रहें',
        'सावध राहा',
      ),
    };
    for (final MapEntry(key: level, value: (color, en, hi, mr))
        in expectations.entries) {
      for (final (lang, label) in [('en', en), ('hi', hi), ('mr', mr)]) {
        testWidgets('$level in $lang: colour and label', (tester) async {
          await pump(tester, ResultScreen(outcome: outcome(level)), lang: lang);
          expect(bannerColor(tester), color);
          expect(find.text(label), findsOneWidget);
          expect(
            find.text(
              'Police never ask you to transfer money on a video call.',
            ),
            findsOneWidget,
          );
        });
      }
    }

    testWidgets(
      'shows red flags, 3 numbered steps, read-aloud and family status',
      (tester) async {
        await pump(tester, ResultScreen(outcome: outcome(RiskLevel.high)));
        expect(find.text('Warning signs'), findsOneWidget);
        expect(find.text('What to do now'), findsOneWidget);
        for (final n in ['1', '2', '3']) {
          expect(find.text(n), findsOneWidget);
        }
        expect(find.text('Read aloud'), findsOneWidget);
        expect(find.text('Add family to get help.'), findsOneWidget);
        expect(
          find.textContaining('Only your family can tell you'),
          findsOneWidget,
        );
      },
    );

    testWidgets('banner has a screen-reader label', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, ResultScreen(outcome: outcome(RiskLevel.high)));
      expect(find.bySemanticsLabel('Result: High risk'), findsOneWidget);
      handle.dispose();
    });

    for (final lang in ['en', 'hi', 'mr']) {
      testWidgets('large text on a small phone does not overflow ($lang)', (
        tester,
      ) async {
        // 1.3 large-text mode on top of a 1.3 system font size, 320dp wide.
        await pump(
          tester,
          ResultScreen(outcome: outcome(RiskLevel.suspicious, long: true)),
          lang: lang,
          textScale: 1.69,
          size: const Size(960, 1920),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('CheckingScreen errors', () {
    for (final (error, text) in [
      (CheckError.dailyLimit, "You've used all 10 checks for today"),
      (CheckError.network, 'No internet connection'),
      (CheckError.generic, "We couldn't check this message right now"),
    ]) {
      testWidgets('$error shows a friendly message and the OTP reminder', (
        tester,
      ) async {
        await pump(
          tester,
          const CheckingScreen(
            draft: CheckDraft(text: 'hi', source: CheckSource.typed),
          ),
          overrides: [
            checkRepositoryProvider.overrideWithValue(_FailingRepo(error)),
          ],
        );
        expect(find.textContaining(text), findsOneWidget);
        expect(find.textContaining("don't share any OTP"), findsOneWidget);
        expect(
          find.text('Try again'),
          error == CheckError.dailyLimit ? findsNothing : findsOneWidget,
        );
      });
    }

    testWidgets('daily limit message in Marathi', (tester) async {
      await pump(
        tester,
        const CheckingScreen(
          draft: CheckDraft(text: 'hi', source: CheckSource.typed),
        ),
        lang: 'mr',
        overrides: [
          checkRepositoryProvider.overrideWithValue(
            _FailingRepo(CheckError.dailyLimit),
          ),
        ],
      );
      expect(find.textContaining('आजच्या सर्व 10 तपासण्या'), findsOneWidget);
    });
  });

  group('ComposeScreen', () {
    testWidgets('empty text shows a message instead of checking', (
      tester,
    ) async {
      await pump(tester, const ComposeScreen());
      await tester.tap(find.text('Check now'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please paste or type a message first.'),
        findsOneWidget,
      );
    });

    testWidgets('OCR/voice text is shown for confirm and is editable', (
      tester,
    ) async {
      await pump(
        tester,
        const ComposeScreen(
          draft: CheckDraft(
            text: 'Your KYC expires today',
            source: CheckSource.image,
          ),
        ),
      );
      expect(find.textContaining('You can correct it'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Your KYC expires today!!',
      );
      expect(find.text('Your KYC expires today!!'), findsOneWidget);
    });
  });
}
