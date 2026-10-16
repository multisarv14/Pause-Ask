import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// Brand name. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'PauseAsk'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Family Scam Check'**
  String get appSubtitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Pause. Ask family. Stay safe.'**
  String get tagline;

  /// No description provided for @largeText.
  ///
  /// In en, this message translates to:
  /// **'Large text'**
  String get largeText;

  /// No description provided for @largeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Make all text bigger and easier to read'**
  String get largeTextHint;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later.'**
  String get languageSubtitle;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Got a suspicious message? Pause.'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Don\'t open links, share an OTP or send money in a hurry. Show the message to PauseAsk first.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Ask your family in one tap'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'We explain the risk in simple words, and your family gets an alert right away so they can help.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Daily \"I\'m OK\" keeps family at peace'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'One tap a day tells your family you\'re fine. If you miss it, they\'ll know to check on you.'**
  String get onboardingSlide3Body;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Before you start, here is what PauseAsk keeps and why.'**
  String get privacyIntro;

  /// No description provided for @privacyPointData.
  ///
  /// In en, this message translates to:
  /// **'We save your name, phone number and your family circle.'**
  String get privacyPointData;

  /// No description provided for @privacyPointChecks.
  ///
  /// In en, this message translates to:
  /// **'When you check a message, only its text is sent. Phone numbers, OTPs and account numbers are hidden first.'**
  String get privacyPointChecks;

  /// No description provided for @privacyPointDelete.
  ///
  /// In en, this message translates to:
  /// **'Your checks are deleted automatically after 30 days.'**
  String get privacyPointDelete;

  /// No description provided for @privacyPointAi.
  ///
  /// In en, this message translates to:
  /// **'The AI can make mistakes. It never says a message is safe — when in doubt, ask your family.'**
  String get privacyPointAi;

  /// No description provided for @privacyAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get privacyAgree;

  /// No description provided for @privacyAgreeHint.
  ///
  /// In en, this message translates to:
  /// **'You need to agree to use PauseAsk.'**
  String get privacyAgreeHint;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your phone number'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 6-digit code by SMS.'**
  String get loginSubtitle;

  /// No description provided for @countryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get countryCodeLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}.'**
  String otpSentTo(String phone);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpLabel;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'You can resend the code in {seconds} seconds'**
  String resendIn(int seconds);

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'That phone number doesn\'t look right. Please check it.'**
  String get errorInvalidPhone;

  /// No description provided for @errorWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong. Please check the SMS and try again.'**
  String get errorWrongCode;

  /// No description provided for @errorCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Please ask for a new one.'**
  String get errorCodeExpired;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check and try again.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameRequired;

  /// No description provided for @roleQuestion.
  ///
  /// In en, this message translates to:
  /// **'How will you use PauseAsk?'**
  String get roleQuestion;

  /// No description provided for @roleProtected.
  ///
  /// In en, this message translates to:
  /// **'I want protection'**
  String get roleProtected;

  /// No description provided for @roleProtectedHint.
  ///
  /// In en, this message translates to:
  /// **'Check suspicious messages and get help from family.'**
  String get roleProtectedHint;

  /// No description provided for @roleGuardian.
  ///
  /// In en, this message translates to:
  /// **'I protect my family'**
  String get roleGuardian;

  /// No description provided for @roleGuardianHint.
  ///
  /// In en, this message translates to:
  /// **'Get alerts and reply with one tap.'**
  String get roleGuardianHint;

  /// No description provided for @roleBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get roleBoth;

  /// No description provided for @roleBothHint.
  ///
  /// In en, this message translates to:
  /// **'Stay protected and protect others too.'**
  String get roleBothHint;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose one option.'**
  String get roleRequired;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeProtectedText.
  ///
  /// In en, this message translates to:
  /// **'If a message worries you, pause and check it here. Your family will be told right away.'**
  String get homeProtectedText;

  /// No description provided for @homeGuardianText.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get an alert when someone in your family needs help with a message.'**
  String get homeGuardianText;

  /// No description provided for @homeBothText.
  ///
  /// In en, this message translates to:
  /// **'Check your own messages, and help your family when they ask.'**
  String get homeBothText;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More features are coming soon.'**
  String get homeComingSoon;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile.'**
  String get profileLoadError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @myCircle.
  ///
  /// In en, this message translates to:
  /// **'My family circle'**
  String get myCircle;

  /// No description provided for @circleTitle.
  ///
  /// In en, this message translates to:
  /// **'Family circle'**
  String get circleTitle;

  /// No description provided for @noCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in a family circle yet'**
  String get noCircleTitle;

  /// No description provided for @noCircleBody.
  ///
  /// In en, this message translates to:
  /// **'Create a circle and invite your family, or join one with a code you received.'**
  String get noCircleBody;

  /// No description provided for @createCircle.
  ///
  /// In en, this message translates to:
  /// **'Create a circle'**
  String get createCircle;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @circleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Circle name'**
  String get circleNameLabel;

  /// No description provided for @circleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Patil Family'**
  String get circleNameHint;

  /// No description provided for @circleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for your circle.'**
  String get circleNameRequired;

  /// No description provided for @createCircleButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createCircleButton;

  /// No description provided for @joinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-character code'**
  String get joinCodeLabel;

  /// No description provided for @joinCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask a family member to send you the code from their PauseAsk app.'**
  String get joinCodeHelp;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinButton;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'Members: {count} / {max}'**
  String membersCount(int count, int max);

  /// No description provided for @badgeOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get badgeOwner;

  /// No description provided for @badgeProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get badgeProtected;

  /// No description provided for @badgeGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get badgeGuardian;

  /// No description provided for @badgeYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get badgeYou;

  /// No description provided for @inviteFamily.
  ///
  /// In en, this message translates to:
  /// **'Invite family'**
  String get inviteFamily;

  /// No description provided for @inviteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeTitle;

  /// No description provided for @inviteCodeExplain.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your family. It works for 7 days.'**
  String get inviteCodeExplain;

  /// No description provided for @inviteViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Invite via WhatsApp'**
  String get inviteViaWhatsApp;

  /// No description provided for @shareOtherWay.
  ///
  /// In en, this message translates to:
  /// **'Share another way'**
  String get shareOtherWay;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @whatsappNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp isn\'t installed. Please use \"Share another way\".'**
  String get whatsappNotInstalled;

  /// WhatsApp/share invite text. Keep the numbered steps.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'ve started using PauseAsk to stay safe from scams. Please join our family circle \"{circleName}\" so I can check with you before acting on a suspicious message.\n\n1. Install PauseAsk: {link}\n2. Open it and tap \"Join with code\"\n3. Enter this code: {code}\n\nThe code works for 7 days.'**
  String inviteMessage(String circleName, String code, String link);

  /// No description provided for @leaveCircle.
  ///
  /// In en, this message translates to:
  /// **'Leave circle'**
  String get leaveCircle;

  /// No description provided for @leaveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this circle?'**
  String get leaveConfirmTitle;

  /// No description provided for @leaveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your family will no longer get your alerts.'**
  String get leaveConfirmBody;

  /// No description provided for @leaveConfirmOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'You are the owner. The member who joined earliest will become the new owner. If you are the only member, the circle will be deleted.'**
  String get leaveConfirmOwnerBody;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the circle?'**
  String removeConfirmTitle(String name);

  /// No description provided for @removeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They will stop getting alerts from this circle.'**
  String get removeConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @circleErrorAlreadyInCircle.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in a family circle. You can be in only one circle.'**
  String get circleErrorAlreadyInCircle;

  /// No description provided for @circleErrorFull.
  ///
  /// In en, this message translates to:
  /// **'This circle is full (max 5 members).'**
  String get circleErrorFull;

  /// No description provided for @circleErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t match any circle. Please check it and try again.'**
  String get circleErrorInvalidCode;

  /// No description provided for @circleErrorCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Ask your family for a new one.'**
  String get circleErrorCodeExpired;

  /// No description provided for @circleErrorCodeUsedUp.
  ///
  /// In en, this message translates to:
  /// **'This code can\'t be used any more. Ask your family for a new one.'**
  String get circleErrorCodeUsedUp;

  /// No description provided for @circleErrorAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in this circle.'**
  String get circleErrorAlreadyMember;

  /// No description provided for @circleErrorNotOwner.
  ///
  /// In en, this message translates to:
  /// **'Only the circle owner can do this.'**
  String get circleErrorNotOwner;

  /// No description provided for @circleErrorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Please wait an hour and try again.'**
  String get circleErrorTooManyAttempts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
