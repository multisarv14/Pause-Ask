// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PauseAsk';

  @override
  String get appSubtitle => 'Family Scam Check';

  @override
  String get tagline => 'Pause. Ask family. Stay safe.';

  @override
  String get largeText => 'Large text';

  @override
  String get largeTextHint => 'Make all text bigger and easier to read';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change this later.';

  @override
  String get onboardingSlide1Title => 'Got a suspicious message? Pause.';

  @override
  String get onboardingSlide1Body =>
      'Don\'t open links, share an OTP or send money in a hurry. Show the message to PauseAsk first.';

  @override
  String get onboardingSlide2Title => 'Ask your family in one tap';

  @override
  String get onboardingSlide2Body =>
      'We explain the risk in simple words, and your family gets an alert right away so they can help.';

  @override
  String get onboardingSlide3Title => 'Daily \"I\'m OK\" keeps family at peace';

  @override
  String get onboardingSlide3Body =>
      'One tap a day tells your family you\'re fine. If you miss it, they\'ll know to check on you.';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get privacyTitle => 'Your privacy';

  @override
  String get privacyIntro =>
      'Before you start, here is what PauseAsk keeps and why.';

  @override
  String get privacyPointData =>
      'We save your name, phone number and your family circle.';

  @override
  String get privacyPointChecks =>
      'When you check a message, only its text is sent. Phone numbers, OTPs and account numbers are hidden first.';

  @override
  String get privacyPointDelete =>
      'Your checks are deleted automatically after 30 days.';

  @override
  String get privacyPointAi =>
      'The AI can make mistakes. It never says a message is safe — when in doubt, ask your family.';

  @override
  String get privacyAgree => 'I agree';

  @override
  String get privacyAgreeHint => 'You need to agree to use PauseAsk.';

  @override
  String get loginTitle => 'Log in with your phone number';

  @override
  String get loginSubtitle => 'We\'ll send a 6-digit code by SMS.';

  @override
  String get countryCodeLabel => 'Country code';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a 6-digit code to $phone.';
  }

  @override
  String get otpLabel => '6-digit code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'You can resend the code in $seconds seconds';
  }

  @override
  String get changeNumber => 'Change number';

  @override
  String get errorInvalidPhone =>
      'That phone number doesn\'t look right. Please check it.';

  @override
  String get errorWrongCode =>
      'That code is wrong. Please check the SMS and try again.';

  @override
  String get errorCodeExpired =>
      'This code has expired. Please ask for a new one.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts. Please wait a while and try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Please check and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get profileTitle => 'Tell us about you';

  @override
  String get nameLabel => 'Your name';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get roleQuestion => 'How will you use PauseAsk?';

  @override
  String get roleProtected => 'I want protection';

  @override
  String get roleProtectedHint =>
      'Check suspicious messages and get help from family.';

  @override
  String get roleGuardian => 'I protect my family';

  @override
  String get roleGuardianHint => 'Get alerts and reply with one tap.';

  @override
  String get roleBoth => 'Both';

  @override
  String get roleBothHint => 'Stay protected and protect others too.';

  @override
  String get roleRequired => 'Please choose one option.';

  @override
  String get continueButton => 'Continue';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeProtectedText =>
      'If a message worries you, pause and check it here. Your family will be told right away.';

  @override
  String get homeGuardianText =>
      'You\'ll get an alert when someone in your family needs help with a message.';

  @override
  String get homeBothText =>
      'Check your own messages, and help your family when they ask.';

  @override
  String get homeComingSoon => 'More features are coming soon.';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get logout => 'Log out';

  @override
  String get loading => 'Loading…';

  @override
  String get profileLoadError => 'Couldn\'t load your profile.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get myCircle => 'My family circle';

  @override
  String get circleTitle => 'Family circle';

  @override
  String get noCircleTitle => 'You\'re not in a family circle yet';

  @override
  String get noCircleBody =>
      'Create a circle and invite your family, or join one with a code you received.';

  @override
  String get createCircle => 'Create a circle';

  @override
  String get joinWithCode => 'Join with code';

  @override
  String get circleNameLabel => 'Circle name';

  @override
  String get circleNameHint => 'e.g. Patil Family';

  @override
  String get circleNameRequired => 'Please enter a name for your circle.';

  @override
  String get createCircleButton => 'Create';

  @override
  String get joinCodeLabel => '6-character code';

  @override
  String get joinCodeHelp =>
      'Ask a family member to send you the code from their PauseAsk app.';

  @override
  String get joinButton => 'Join';

  @override
  String membersCount(int count, int max) {
    return 'Members: $count / $max';
  }

  @override
  String get badgeOwner => 'Owner';

  @override
  String get badgeProtected => 'Protected';

  @override
  String get badgeGuardian => 'Guardian';

  @override
  String get badgeYou => 'You';

  @override
  String get inviteFamily => 'Invite family';

  @override
  String get inviteCodeTitle => 'Invite code';

  @override
  String get inviteCodeExplain =>
      'Share this code with your family. It works for 7 days.';

  @override
  String get inviteViaWhatsApp => 'Invite via WhatsApp';

  @override
  String get shareOtherWay => 'Share another way';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get whatsappNotInstalled =>
      'WhatsApp isn\'t installed. Please use \"Share another way\".';

  @override
  String inviteMessage(String circleName, String code, String link) {
    return 'Hi! I\'ve started using PauseAsk to stay safe from scams. Please join our family circle \"$circleName\" so I can check with you before acting on a suspicious message.\n\n1. Install PauseAsk: $link\n2. Open it and tap \"Join with code\"\n3. Enter this code: $code\n\nThe code works for 7 days.';
  }

  @override
  String get leaveCircle => 'Leave circle';

  @override
  String get leaveConfirmTitle => 'Leave this circle?';

  @override
  String get leaveConfirmBody => 'Your family will no longer get your alerts.';

  @override
  String get leaveConfirmOwnerBody =>
      'You are the owner. The member who joined earliest will become the new owner. If you are the only member, the circle will be deleted.';

  @override
  String get removeMember => 'Remove';

  @override
  String removeConfirmTitle(String name) {
    return 'Remove $name from the circle?';
  }

  @override
  String get removeConfirmBody =>
      'They will stop getting alerts from this circle.';

  @override
  String get cancel => 'Cancel';

  @override
  String get circleErrorAlreadyInCircle =>
      'You\'re already in a family circle. You can be in only one circle.';

  @override
  String get circleErrorFull => 'This circle is full (max 5 members).';

  @override
  String get circleErrorInvalidCode =>
      'That code doesn\'t match any circle. Please check it and try again.';

  @override
  String get circleErrorCodeExpired =>
      'This code has expired. Ask your family for a new one.';

  @override
  String get circleErrorCodeUsedUp =>
      'This code can\'t be used any more. Ask your family for a new one.';

  @override
  String get circleErrorAlreadyMember => 'You\'re already in this circle.';

  @override
  String get circleErrorNotOwner => 'Only the circle owner can do this.';

  @override
  String get circleErrorTooManyAttempts =>
      'Too many wrong codes. Please wait an hour and try again.';
}
