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

  /// No description provided for @homeGuardianText.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get an alert when someone in your family needs help with a message.'**
  String get homeGuardianText;

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

  /// No description provided for @pauseAndAsk.
  ///
  /// In en, this message translates to:
  /// **'Pause & Ask'**
  String get pauseAndAsk;

  /// No description provided for @pauseAndAskHint.
  ///
  /// In en, this message translates to:
  /// **'Got a message you\'re not sure about? Check it here.'**
  String get pauseAndAskHint;

  /// No description provided for @tellUsWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened'**
  String get tellUsWhatHappened;

  /// No description provided for @pasteOrType.
  ///
  /// In en, this message translates to:
  /// **'Paste / type message'**
  String get pasteOrType;

  /// No description provided for @pickScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Pick a screenshot'**
  String get pickScreenshot;

  /// No description provided for @shareTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: In WhatsApp or SMS, press and hold the message → Share → PauseAsk.'**
  String get shareTip;

  /// No description provided for @chooseHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to check?'**
  String get chooseHowTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @composeTitle.
  ///
  /// In en, this message translates to:
  /// **'Check a message'**
  String get composeTitle;

  /// No description provided for @composeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type the message here'**
  String get composeHint;

  /// No description provided for @composeConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Look at the text below. You can correct it before checking.'**
  String get composeConfirmHint;

  /// No description provided for @pasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteButton;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @textEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please paste or type a message first.'**
  String get textEmpty;

  /// No description provided for @textTooLong.
  ///
  /// In en, this message translates to:
  /// **'This message is too long. Please keep only the important part (up to {max} characters).'**
  String textTooLong(int max);

  /// No description provided for @readingScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Reading the screenshot…'**
  String get readingScreenshot;

  /// No description provided for @ocrNoText.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any text in this picture. Please try another screenshot or type the message.'**
  String get ocrNoText;

  /// No description provided for @imageStaysOnPhone.
  ///
  /// In en, this message translates to:
  /// **'The picture stays on your phone. Only the text is checked.'**
  String get imageStaysOnPhone;

  /// No description provided for @voiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and say what the message or the caller said.'**
  String get voiceIntro;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening… speak now'**
  String get voiceListening;

  /// No description provided for @voiceTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceTapToStart;

  /// No description provided for @voiceTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get voiceTapToStop;

  /// No description provided for @voiceUseText.
  ///
  /// In en, this message translates to:
  /// **'Use this text'**
  String get voiceUseText;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input for this language isn\'t available on this phone. Download it in the Google app → Settings → Voice → Offline speech recognition, or type the message.'**
  String get voiceNotAvailable;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'PauseAsk needs microphone permission to hear you. You can allow it in your phone\'s Settings.'**
  String get micPermissionDenied;

  /// No description provided for @voiceNothingHeard.
  ///
  /// In en, this message translates to:
  /// **'We didn\'t hear anything. Please try again.'**
  String get voiceNothingHeard;

  /// No description provided for @checkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checkingTitle;

  /// No description provided for @checkingReminder.
  ///
  /// In en, this message translates to:
  /// **'Meanwhile, don\'t send money and don\'t share any OTP.'**
  String get checkingReminder;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskHigh;

  /// No description provided for @riskSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get riskSuspicious;

  /// No description provided for @riskBeCareful.
  ///
  /// In en, this message translates to:
  /// **'Be careful'**
  String get riskBeCareful;

  /// No description provided for @riskSemantics.
  ///
  /// In en, this message translates to:
  /// **'Result: {level}'**
  String riskSemantics(String level);

  /// No description provided for @redFlagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning signs'**
  String get redFlagsTitle;

  /// No description provided for @whatToDoTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do now'**
  String get whatToDoTitle;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @ttsVoiceMissing.
  ///
  /// In en, this message translates to:
  /// **'No voice is installed for this language. Install it in your phone\'s Settings → Text-to-speech.'**
  String get ttsVoiceMissing;

  /// No description provided for @resultDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'PauseAsk can make mistakes. Only your family can tell you a message is OK.'**
  String get resultDisclaimer;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @checkAnother.
  ///
  /// In en, this message translates to:
  /// **'Check another message'**
  String get checkAnother;

  /// No description provided for @checkErrorDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all 10 checks for today. If you\'re worried, call a family member now. You can check again tomorrow.'**
  String get checkErrorDailyLimit;

  /// No description provided for @checkErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please turn on mobile data or Wi-Fi and try again. Until then, don\'t send money or share an OTP.'**
  String get checkErrorNetwork;

  /// No description provided for @checkErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t check this message right now. Please try again. If you\'re worried, call a family member.'**
  String get checkErrorGeneric;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @guardianAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Family needs help'**
  String get guardianAlertTitle;

  /// No description provided for @askedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} asked at {time}'**
  String askedBy(String name, String time);

  /// No description provided for @maskedMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'The message (private details hidden)'**
  String get maskedMessageTitle;

  /// No description provided for @respondStop.
  ///
  /// In en, this message translates to:
  /// **'STOP – don\'t do anything, I\'ll call you'**
  String get respondStop;

  /// No description provided for @respondOk.
  ///
  /// In en, this message translates to:
  /// **'I checked – it\'s OK'**
  String get respondOk;

  /// No description provided for @respondCall.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get respondCall;

  /// No description provided for @replySent.
  ///
  /// In en, this message translates to:
  /// **'Your reply was sent to {name}.'**
  String replySent(String name);

  /// No description provided for @alreadyAnswered.
  ///
  /// In en, this message translates to:
  /// **'Already answered by {name}: {reply}'**
  String alreadyAnswered(String name, String reply);

  /// No description provided for @responseLabelStop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get responseLabelStop;

  /// No description provided for @responseLabelOk.
  ///
  /// In en, this message translates to:
  /// **'It\'s OK'**
  String get responseLabelOk;

  /// No description provided for @responseLabelCall.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get responseLabelCall;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available.'**
  String get noPhone;

  /// No description provided for @responseStopBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t do anything. Don\'t send money or share any OTP. {name} will call you.'**
  String responseStopBody(String name);

  /// No description provided for @responseOkBody.
  ///
  /// In en, this message translates to:
  /// **'{name} checked this message: it\'s OK.'**
  String responseOkBody(String name);

  /// No description provided for @responseCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up the phone'**
  String get responseCallTitle;

  /// No description provided for @responseCallBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling you now. Don\'t do anything until you\'ve talked.'**
  String responseCallBody(String name);

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @familyAlerting.
  ///
  /// In en, this message translates to:
  /// **'Alerting your family…'**
  String get familyAlerting;

  /// No description provided for @familyAlerted.
  ///
  /// In en, this message translates to:
  /// **'Your family has been alerted.'**
  String get familyAlerted;

  /// No description provided for @familyNoGuardian.
  ///
  /// In en, this message translates to:
  /// **'Nobody in your circle can reply yet. Ask a family member to join as a guardian.'**
  String get familyNoGuardian;

  /// No description provided for @familyAddToGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Add family to get help.'**
  String get familyAddToGetHelp;

  /// No description provided for @familyReplied.
  ///
  /// In en, this message translates to:
  /// **'{name} replied: {reply}'**
  String familyReplied(String name, String reply);

  /// No description provided for @viewReply.
  ///
  /// In en, this message translates to:
  /// **'Open reply'**
  String get viewReply;

  /// No description provided for @openRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Family requests'**
  String get openRequestsTitle;

  /// No description provided for @noOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'No open requests. You\'ll get a notification when someone needs help.'**
  String get noOpenRequests;

  /// No description provided for @memberStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Family status'**
  String get memberStatusTitle;

  /// No description provided for @channelAlertsName.
  ///
  /// In en, this message translates to:
  /// **'Family alerts'**
  String get channelAlertsName;

  /// No description provided for @channelAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'When family asks for help or replies to you'**
  String get channelAlertsDescription;

  /// No description provided for @channelGeneralName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get channelGeneralName;

  /// No description provided for @sosButton.
  ///
  /// In en, this message translates to:
  /// **'I need help now'**
  String get sosButton;

  /// No description provided for @sosHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold for 2 seconds'**
  String get sosHoldHint;

  /// No description provided for @sosSending.
  ///
  /// In en, this message translates to:
  /// **'Sending SOS…'**
  String get sosSending;

  /// No description provided for @sosAlerted.
  ///
  /// In en, this message translates to:
  /// **'Your family has been alerted'**
  String get sosAlerted;

  /// No description provided for @sosNoGuardian.
  ///
  /// In en, this message translates to:
  /// **'Nobody in your family circle could be alerted. Please call someone you trust now.'**
  String get sosNoGuardian;

  /// No description provided for @sosCallGuardian.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String sosCallGuardian(String name);

  /// No description provided for @sosCall1930.
  ///
  /// In en, this message translates to:
  /// **'Call 1930 – Cyber Crime Helpline'**
  String get sosCall1930;

  /// No description provided for @sos1930Explain.
  ///
  /// In en, this message translates to:
  /// **'Call 1930 if money was taken or you shared bank details or an OTP. Calling quickly can help stop the money.'**
  String get sos1930Explain;

  /// No description provided for @sosLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve sent SOS 5 times in the last hour. Please call your family directly.'**
  String get sosLimit;

  /// No description provided for @sosFailed.
  ///
  /// In en, this message translates to:
  /// **'SOS could not be sent. Please call your family directly.'**
  String get sosFailed;

  /// No description provided for @sosAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} needs help now'**
  String sosAlertTitle(String name);

  /// No description provided for @sosAlertBody.
  ///
  /// In en, this message translates to:
  /// **'{name} pressed the SOS button. Please call them right away.'**
  String sosAlertBody(String name);

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily \"I\'m OK\"'**
  String get checkinTitle;

  /// No description provided for @checkinExplain.
  ///
  /// In en, this message translates to:
  /// **'Every day at this time we\'ll remind you to tell your family you\'re OK. If you don\'t, they get one gentle alert.'**
  String get checkinExplain;

  /// No description provided for @checkinEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get checkinEnabled;

  /// No description provided for @checkinTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get checkinTime;

  /// No description provided for @checkinAlertAfter.
  ///
  /// In en, this message translates to:
  /// **'Alert family if no check-in after'**
  String get checkinAlertAfter;

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String hoursCount(int count);

  /// No description provided for @checkinChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Changes to family alerts apply from tomorrow.'**
  String get checkinChangeNote;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @checkinReminderMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Tap to tell your family you\'re OK 👍'**
  String get checkinReminderMorning;

  /// No description provided for @checkinReminderOther.
  ///
  /// In en, this message translates to:
  /// **'Hello! Tap to tell your family you\'re OK 👍'**
  String get checkinReminderOther;

  /// No description provided for @checkinThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your family knows you\'re OK today.'**
  String get checkinThanks;

  /// No description provided for @statusOkAt.
  ///
  /// In en, this message translates to:
  /// **'OK today at {time}'**
  String statusOkAt(String time);

  /// No description provided for @statusNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet today'**
  String get statusNotYet;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed today\'s check-in'**
  String get statusMissed;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in is off'**
  String get statusOff;

  /// No description provided for @batteryGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure alerts reach you'**
  String get batteryGuideTitle;

  /// No description provided for @batteryGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop apps in the background to save battery. Then family alerts can arrive late or not at all. Please do these 2 quick steps:'**
  String get batteryGuideIntro;

  /// No description provided for @batteryStepNotifications.
  ///
  /// In en, this message translates to:
  /// **'1. Allow notifications for PauseAsk'**
  String get batteryStepNotifications;

  /// No description provided for @batteryStepBattery.
  ///
  /// In en, this message translates to:
  /// **'2. Set battery to \"No restrictions\" / \"Don\'t optimise\" for PauseAsk'**
  String get batteryStepBattery;

  /// No description provided for @batteryStepAutostart.
  ///
  /// In en, this message translates to:
  /// **'On some phones also turn on \"Autostart\" for PauseAsk in the app settings.'**
  String get batteryStepAutostart;

  /// No description provided for @openNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open notification settings'**
  String get openNotificationSettings;

  /// No description provided for @openBatterySettings.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get openBatterySettings;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get openAppSettings;

  /// No description provided for @notificationHelp.
  ///
  /// In en, this message translates to:
  /// **'Notification help'**
  String get notificationHelp;

  /// No description provided for @historyTitleMine.
  ///
  /// In en, this message translates to:
  /// **'My checks'**
  String get historyTitleMine;

  /// No description provided for @historyTitleFamily.
  ///
  /// In en, this message translates to:
  /// **'Family checks'**
  String get historyTitleFamily;

  /// No description provided for @historyAutoDelete.
  ///
  /// In en, this message translates to:
  /// **'Checks are automatically deleted after 30 days.'**
  String get historyAutoDelete;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No checks yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When a message worries you, tap \"Pause & Ask\". Your checks will appear here.'**
  String get historyEmptyBody;

  /// No description provided for @historyEmptyFamily.
  ///
  /// In en, this message translates to:
  /// **'No checks from your family yet. You\'ll get a notification when someone asks.'**
  String get historyEmptyFamily;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @deleteCheckConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this check?'**
  String get deleteCheckConfirm;

  /// No description provided for @deleteCheckBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed for you and your family.'**
  String get deleteCheckBody;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedMessage;

  /// No description provided for @noReplyYet.
  ///
  /// In en, this message translates to:
  /// **'No reply yet'**
  String get noReplyYet;

  /// No description provided for @checkDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check details'**
  String get checkDetailTitle;

  /// No description provided for @replyButton.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyButton;

  /// No description provided for @feedCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Scam alert of the day'**
  String get feedCardTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Scam alerts'**
  String get feedTitle;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts right now. Please check back soon.'**
  String get feedEmpty;

  /// No description provided for @shareAlert.
  ///
  /// In en, this message translates to:
  /// **'Share this alert'**
  String get shareAlert;

  /// No description provided for @sharePromo.
  ///
  /// In en, this message translates to:
  /// **'Protect your family with PauseAsk: {link}'**
  String sharePromo(String link);

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @checkinDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Your family knows you\'re OK today ({time})'**
  String checkinDoneToday(String time);

  /// No description provided for @checkinNotYetToday.
  ///
  /// In en, this message translates to:
  /// **'Tell your family you\'re OK today'**
  String get checkinNotYetToday;

  /// No description provided for @imOkButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m OK 👍'**
  String get imOkButton;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & alerts'**
  String get settingsFamily;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & legal'**
  String get settingsHelp;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @rolesTitle.
  ///
  /// In en, this message translates to:
  /// **'My role'**
  String get rolesTitle;

  /// No description provided for @rolesSaved.
  ///
  /// In en, this message translates to:
  /// **'Role updated'**
  String get rolesSaved;

  /// No description provided for @testAlert.
  ///
  /// In en, this message translates to:
  /// **'Send me a test alert'**
  String get testAlert;

  /// No description provided for @testAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Test alert sent. It should arrive in a few seconds.'**
  String get testAlertSent;

  /// No description provided for @testAlertNoDevice.
  ///
  /// In en, this message translates to:
  /// **'This phone isn\'t set up for alerts yet. Allow notifications, then close and open PauseAsk again.'**
  String get testAlertNoDevice;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @noEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Please write to {email}.'**
  String noEmailApp(String email);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @readFullOnline.
  ///
  /// In en, this message translates to:
  /// **'Read the full version online'**
  String get readFullOnline;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes:'**
  String get deleteAccountIntro;

  /// No description provided for @deleteItemProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile: name, phone number and settings'**
  String get deleteItemProfile;

  /// No description provided for @deleteItemChecks.
  ///
  /// In en, this message translates to:
  /// **'All your checks and their results'**
  String get deleteItemChecks;

  /// No description provided for @deleteItemCheckins.
  ///
  /// In en, this message translates to:
  /// **'Your daily check-in and SOS data'**
  String get deleteItemCheckins;

  /// No description provided for @deleteItemCircle.
  ///
  /// In en, this message translates to:
  /// **'Your place in the family circle. If you created it, the member who joined earliest becomes the owner.'**
  String get deleteItemCircle;

  /// No description provided for @deleteItemLogin.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in'**
  String get deleteItemLogin;

  /// No description provided for @deleteKeptNote.
  ///
  /// In en, this message translates to:
  /// **'Replies you gave to your family stay on their checks, without your name.'**
  String get deleteKeptNote;

  /// No description provided for @deleteTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteTypeHint;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteForever;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account right now. Please check your internet and try again.'**
  String get deleteFailed;

  /// No description provided for @errorScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorScreenTitle;

  /// No description provided for @errorScreenBody.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this part of PauseAsk had a problem. Your information is not affected. Please go back and try again.'**
  String get errorScreenBody;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goHome;
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
