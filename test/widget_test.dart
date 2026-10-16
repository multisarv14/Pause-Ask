import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/app.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase isn't initialised in tests (firebaseReadyProvider == false), so
// the user is always signed out — enough to exercise the first-run flow.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Locale deviceLocale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  tester.platformDispatcher.localesTestValue = [deviceLocale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(1080, 2400);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
      child: const PauseAskApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fresh install: language → onboarding → privacy → login', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Got a suspicious message? Pause.'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Ask your family in one tap'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Your privacy'), findsOneWidget);

    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(find.text('Log in with your phone number'), findsOneWidget);
  });

  testWidgets('choosing Hindi switches the UI immediately and is saved', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('हिंदी'));
    await tester.pumpAndSettle();
    expect(find.text('कोई शक वाला मैसेज आया है? ज़रा रुकिए।'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrefKeys.languageCode), 'hi');
  });

  testWidgets('remembered Marathi + finished onboarding opens login', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: {
        PrefKeys.languageCode: 'mr',
        PrefKeys.onboardingDone: true,
        PrefKeys.consentVersion: 1,
        PrefKeys.consentAcceptedAt: 0,
      },
    );
    expect(find.text('तुमच्या फोन नंबरने लॉग इन करा'), findsOneWidget);
  });

  testWidgets('invalid phone number shows a clear message', (tester) async {
    await pumpApp(
      tester,
      prefs: {
        PrefKeys.languageCode: 'en',
        PrefKeys.onboardingDone: true,
        PrefKeys.consentVersion: 1,
        PrefKeys.consentAcceptedAt: 0,
      },
    );
    await tester.enterText(find.byType(TextField).last, '123');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(
      find.text("That phone number doesn't look right. Please check it."),
      findsOneWidget,
    );
  });
}
