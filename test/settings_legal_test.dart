import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/core/constants/app_constants.dart';
import 'package:pauseask/core/errors/app_errors.dart';
import 'package:pauseask/core/storage/preferences.dart';
import 'package:pauseask/core/theme/app_theme.dart';
import 'package:pauseask/features/auth/phone_auth_controller.dart';
import 'package:pauseask/features/legal/legal_content.dart';
import 'package:pauseask/features/legal/legal_screen.dart';
import 'package:pauseask/features/profile/profile_repository.dart';
import 'package:pauseask/features/profile/user_profile.dart';
import 'package:pauseask/features/settings/account_repository.dart';
import 'package:pauseask/features/settings/delete_account_screen.dart';
import 'package:pauseask/features/settings/settings_screen.dart';
import 'package:pauseask/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAccount implements AccountRepository {
  final roles = <RoleChoice>[];
  int deletes = 0;
  bool testSent = true;
  @override
  Future<void> updateRoles(RoleChoice choice) async => roles.add(choice);
  @override
  Future<bool> sendTestAlert() async => testSent;
  @override
  Future<void> deleteMyAccount() async => deletes++;
}

class FakeAuthController extends PhoneAuthController {
  bool? forgotDevice;
  @override
  Future<void> signOut({bool forgetDevice = false}) async =>
      forgotDevice = forgetDevice;
}

const profile = UserProfile(
  uid: 'me',
  name: 'Asha',
  phone: '+919999900001',
  roles: ['protected'],
  language: 'en',
  largeText: false,
  consentVersion: 1,
);

Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  String lang = 'en',
  List overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({PrefKeys.languageCode: lang});
  final prefs = await SharedPreferences.getInstance();
  // Tall enough that lazy lists build every item.
  tester.view.physicalSize = const Size(1080, 12000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appVersionProvider.overrideWith((ref) async => '1.0.0 (1)'),
        ...overrides,
      ],
      child: MaterialApp(
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
  group('Settings', () {
    testWidgets(
      'all sections are there; support hidden while the email is unset',
      (tester) async {
        await pumpApp(
          tester,
          const SettingsScreen(),
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          ],
        );
        for (final t in [
          'Change language',
          'Large text',
          'My role',
          'My family circle',
          'Daily "I\'m OK"',
          'Send me a test alert',
          'Notification help',
          'Help & FAQ',
          'Privacy policy',
          'Terms of use',
          'Log out',
          'Delete account',
          'Version 1.0.0 (1)',
        ]) {
          expect(find.text(t), findsOneWidget, reason: t);
        }
        expect(
          find.text('Contact support'),
          AppConstants.supportEmail.isEmpty ? findsNothing : findsOneWidget,
        );
      },
    );

    testWidgets('changing role goes through updateRoles', (tester) async {
      final account = FakeAccount();
      await pumpApp(
        tester,
        const SettingsScreen(),
        overrides: [
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          accountRepositoryProvider.overrideWithValue(account),
        ],
      );
      await tester.tap(find.text('Both'));
      await tester.pumpAndSettle();
      expect(account.roles, [RoleChoice.both]);
      expect(find.text('Role updated'), findsOneWidget);
    });

    testWidgets('test alert reports sent / not set up', (tester) async {
      final account = FakeAccount();
      await pumpApp(
        tester,
        const SettingsScreen(),
        overrides: [
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          accountRepositoryProvider.overrideWithValue(account),
        ],
      );
      await tester.tap(find.text('Send me a test alert'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Test alert sent'), findsOneWidget);
      account.testSent = false;
      await tester.tap(find.text('Send me a test alert'));
      await tester.pumpAndSettle();
      expect(find.textContaining("isn't set up for alerts"), findsOneWidget);
    });
  });

  group('Delete account', () {
    for (final typed in ['delete', 'DELETE ME', 'DELET', '']) {
      testWidgets('"$typed" does nothing', (tester) async {
        final account = FakeAccount();
        await pumpApp(
          tester,
          const DeleteAccountScreen(),
          overrides: [accountRepositoryProvider.overrideWithValue(account)],
        );
        await tester.enterText(find.byType(TextField), typed);
        await tester.pump();
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Delete my account'),
        );
        expect(button.onPressed, isNull);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(account.deletes, 0);
      });
    }

    testWidgets('DELETE deletes, then signs out and forgets the device', (
      tester,
    ) async {
      final account = FakeAccount();
      final auth = FakeAuthController();
      await pumpApp(
        tester,
        const DeleteAccountScreen(),
        overrides: [
          accountRepositoryProvider.overrideWithValue(account),
          phoneAuthControllerProvider.overrideWith(() => auth),
        ],
      );
      expect(find.textContaining('All your checks'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(find.text('Delete my account'));
      // The spinner keeps going until the router leaves the screen.
      await tester.pump(const Duration(milliseconds: 500));
      expect(account.deletes, 1);
      expect(auth.forgotDevice, isTrue);
    });

    testWidgets('Marathi explanation', (tester) async {
      await pumpApp(tester, const DeleteAccountScreen(), lang: 'mr');
      expect(find.text('खात्री करण्यासाठी DELETE लिहा'), findsOneWidget);
      expect(find.text('माझं खातं हटवा'), findsOneWidget);
    });
  });

  group('Legal content', () {
    test('privacy / terms / FAQ have the same sections in en, hi and mr', () {
      for (final doc in LegalDoc.values) {
        final en = legalContent[doc]!['en']!.length;
        for (final lang in ['hi', 'mr']) {
          expect(legalContent[doc]![lang]!.length, en, reason: '$doc $lang');
          for (final s in legalContent[doc]![lang]!) {
            expect(
              s.title + s.body,
              matches(RegExp(r'[ऀ-ॿ]')),
              reason: '$doc $lang ${s.title}',
            );
          }
        }
      }
      expect(legalContent[LegalDoc.faq]!['en']!.length, 8);
    });

    test('policy states the key points', () {
      final privacy = legalContent[LegalDoc.privacy]!['en']!
          .map((s) => '${s.title} ${s.body}')
          .join(' ');
      for (final must in [
        '30 days',
        'AI can be wrong',
        'Gemini',
        'DPDP',
        'delete',
        'never sell',
      ]) {
        expect(privacy, contains(must), reason: must);
      }
      final terms = legalContent[LegalDoc.terms]!['en']!
          .map((s) => s.body)
          .join(' ');
      expect(terms, contains('cannot catch every scam'));
      expect(terms, contains('1930'));
    });

    for (final lang in ['en', 'hi', 'mr']) {
      testWidgets('privacy screen fills the company ($lang)', (tester) async {
        await pumpApp(
          tester,
          const LegalScreen(doc: LegalDoc.privacy),
          lang: lang,
        );
        expect(find.textContaining('Multisarv'), findsWidgets);
        expect(find.textContaining('{company}'), findsNothing);
        expect(find.textContaining('{email}'), findsNothing);
      });
    }

    testWidgets('FAQ shows 8 questions (Hindi)', (tester) async {
      await pumpApp(tester, const LegalScreen(doc: LegalDoc.faq), lang: 'hi');
      expect(find.text('क्या यह मेरे SMS पढ़ता है?'), findsOneWidget);
      expect(find.text('अपना डेटा कैसे मिटाएँ?'), findsOneWidget);
    });
  });

  testWidgets('a screen that crashes shows the friendly error view', (
    tester,
  ) async {
    final original = ErrorWidget.builder;
    ErrorWidget.builder = (_) => const FriendlyErrorView();
    try {
      await pumpApp(tester, const CrashTestScreen());
      expect(tester.takeException(), isA<StateError>());
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Go to home'), findsOneWidget);
    } finally {
      ErrorWidget.builder = original; // the test harness checks this
    }
  });
}
