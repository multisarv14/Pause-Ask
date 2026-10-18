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
  String get homeGuardianText =>
      'You\'ll get an alert when someone in your family needs help with a message.';

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

  @override
  String get pauseAndAsk => 'Pause & Ask';

  @override
  String get pauseAndAskHint =>
      'Got a message you\'re not sure about? Check it here.';

  @override
  String get tellUsWhatHappened => 'Tell us what happened';

  @override
  String get pasteOrType => 'Paste / type message';

  @override
  String get pickScreenshot => 'Pick a screenshot';

  @override
  String get shareTip =>
      'Tip: In WhatsApp or SMS, press and hold the message → Share → PauseAsk.';

  @override
  String get chooseHowTitle => 'How do you want to check?';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get composeTitle => 'Check a message';

  @override
  String get composeHint => 'Paste or type the message here';

  @override
  String get composeConfirmHint =>
      'Look at the text below. You can correct it before checking.';

  @override
  String get pasteButton => 'Paste';

  @override
  String get checkNow => 'Check now';

  @override
  String get textEmpty => 'Please paste or type a message first.';

  @override
  String textTooLong(int max) {
    return 'This message is too long. Please keep only the important part (up to $max characters).';
  }

  @override
  String get readingScreenshot => 'Reading the screenshot…';

  @override
  String get ocrNoText =>
      'We couldn\'t find any text in this picture. Please try another screenshot or type the message.';

  @override
  String get imageStaysOnPhone =>
      'The picture stays on your phone. Only the text is checked.';

  @override
  String get voiceIntro =>
      'Tap the microphone and say what the message or the caller said.';

  @override
  String get voiceListening => 'Listening… speak now';

  @override
  String get voiceTapToStart => 'Tap to speak';

  @override
  String get voiceTapToStop => 'Tap to stop';

  @override
  String get voiceUseText => 'Use this text';

  @override
  String get voiceNotAvailable =>
      'Voice input for this language isn\'t available on this phone. Download it in the Google app → Settings → Voice → Offline speech recognition, or type the message.';

  @override
  String get micPermissionDenied =>
      'PauseAsk needs microphone permission to hear you. You can allow it in your phone\'s Settings.';

  @override
  String get voiceNothingHeard => 'We didn\'t hear anything. Please try again.';

  @override
  String get checkingTitle => 'Checking…';

  @override
  String get checkingReminder =>
      'Meanwhile, don\'t send money and don\'t share any OTP.';

  @override
  String get riskHigh => 'High risk';

  @override
  String get riskSuspicious => 'Suspicious';

  @override
  String get riskBeCareful => 'Be careful';

  @override
  String riskSemantics(String level) {
    return 'Result: $level';
  }

  @override
  String get redFlagsTitle => 'Warning signs';

  @override
  String get whatToDoTitle => 'What to do now';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get ttsVoiceMissing =>
      'No voice is installed for this language. Install it in your phone\'s Settings → Text-to-speech.';

  @override
  String get resultDisclaimer =>
      'PauseAsk can make mistakes. Only your family can tell you a message is OK.';

  @override
  String get done => 'Done';

  @override
  String get checkAnother => 'Check another message';

  @override
  String get checkErrorDailyLimit =>
      'You\'ve used all 10 checks for today. If you\'re worried, call a family member now. You can check again tomorrow.';

  @override
  String get checkErrorNetwork =>
      'No internet connection. Please turn on mobile data or Wi-Fi and try again. Until then, don\'t send money or share an OTP.';

  @override
  String get checkErrorGeneric =>
      'We couldn\'t check this message right now. Please try again. If you\'re worried, call a family member.';

  @override
  String get goBack => 'Go back';

  @override
  String get guardianAlertTitle => 'Family needs help';

  @override
  String askedBy(String name, String time) {
    return '$name asked at $time';
  }

  @override
  String get maskedMessageTitle => 'The message (private details hidden)';

  @override
  String get respondStop => 'STOP – don\'t do anything, I\'ll call you';

  @override
  String get respondOk => 'I checked – it\'s OK';

  @override
  String get respondCall => 'Call now';

  @override
  String replySent(String name) {
    return 'Your reply was sent to $name.';
  }

  @override
  String alreadyAnswered(String name, String reply) {
    return 'Already answered by $name: $reply';
  }

  @override
  String get responseLabelStop => 'STOP';

  @override
  String get responseLabelOk => 'It\'s OK';

  @override
  String get responseLabelCall => 'Calling';

  @override
  String get noPhone => 'Phone number not available.';

  @override
  String responseStopBody(String name) {
    return 'Don\'t do anything. Don\'t send money or share any OTP. $name will call you.';
  }

  @override
  String responseOkBody(String name) {
    return '$name checked this message: it\'s OK.';
  }

  @override
  String get responseCallTitle => 'Pick up the phone';

  @override
  String responseCallBody(String name) {
    return '$name is calling you now. Don\'t do anything until you\'ve talked.';
  }

  @override
  String get closeButton => 'Close';

  @override
  String get familyAlerting => 'Alerting your family…';

  @override
  String get familyAlerted => 'Your family has been alerted.';

  @override
  String get familyNoGuardian =>
      'Nobody in your circle can reply yet. Ask a family member to join as a guardian.';

  @override
  String get familyAddToGetHelp => 'Add family to get help.';

  @override
  String familyReplied(String name, String reply) {
    return '$name replied: $reply';
  }

  @override
  String get viewReply => 'Open reply';

  @override
  String get openRequestsTitle => 'Family requests';

  @override
  String get noOpenRequests =>
      'No open requests. You\'ll get a notification when someone needs help.';

  @override
  String get memberStatusTitle => 'Family status';

  @override
  String get channelAlertsName => 'Family alerts';

  @override
  String get channelAlertsDescription =>
      'When family asks for help or replies to you';

  @override
  String get channelGeneralName => 'General';

  @override
  String get sosButton => 'I need help now';

  @override
  String get sosHoldHint => 'Press and hold for 2 seconds';

  @override
  String get sosSending => 'Sending SOS…';

  @override
  String get sosAlerted => 'Your family has been alerted';

  @override
  String get sosNoGuardian =>
      'Nobody in your family circle could be alerted. Please call someone you trust now.';

  @override
  String sosCallGuardian(String name) {
    return 'Call $name';
  }

  @override
  String get sosCall1930 => 'Call 1930 – Cyber Crime Helpline';

  @override
  String get sos1930Explain =>
      'Call 1930 if money was taken or you shared bank details or an OTP. Calling quickly can help stop the money.';

  @override
  String get sosLimit =>
      'You\'ve sent SOS 5 times in the last hour. Please call your family directly.';

  @override
  String get sosFailed =>
      'SOS could not be sent. Please call your family directly.';

  @override
  String sosAlertTitle(String name) {
    return '$name needs help now';
  }

  @override
  String sosAlertBody(String name) {
    return '$name pressed the SOS button. Please call them right away.';
  }

  @override
  String get callButton => 'Call';

  @override
  String get checkinTitle => 'Daily \"I\'m OK\"';

  @override
  String get checkinExplain =>
      'Every day at this time we\'ll remind you to tell your family you\'re OK. If you don\'t, they get one gentle alert.';

  @override
  String get checkinEnabled => 'Daily check-in';

  @override
  String get checkinTime => 'Reminder time';

  @override
  String get checkinAlertAfter => 'Alert family if no check-in after';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get checkinChangeNote =>
      'Changes to family alerts apply from tomorrow.';

  @override
  String get saveButton => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get checkinReminderMorning =>
      'Good morning! Tap to tell your family you\'re OK 👍';

  @override
  String get checkinReminderOther =>
      'Hello! Tap to tell your family you\'re OK 👍';

  @override
  String get checkinThanks => 'Thank you! Your family knows you\'re OK today.';

  @override
  String statusOkAt(String time) {
    return 'OK today at $time';
  }

  @override
  String get statusNotYet => 'Not yet today';

  @override
  String get statusMissed => 'Missed today\'s check-in';

  @override
  String get statusOff => 'Daily check-in is off';

  @override
  String get batteryGuideTitle => 'Make sure alerts reach you';

  @override
  String get batteryGuideIntro =>
      'Some phones stop apps in the background to save battery. Then family alerts can arrive late or not at all. Please do these 2 quick steps:';

  @override
  String get batteryStepNotifications => '1. Allow notifications for PauseAsk';

  @override
  String get batteryStepBattery =>
      '2. Set battery to \"No restrictions\" / \"Don\'t optimise\" for PauseAsk';

  @override
  String get batteryStepAutostart =>
      'On some phones also turn on \"Autostart\" for PauseAsk in the app settings.';

  @override
  String get openNotificationSettings => 'Open notification settings';

  @override
  String get openBatterySettings => 'Open battery settings';

  @override
  String get openAppSettings => 'Open app settings';

  @override
  String get notificationHelp => 'Notification help';

  @override
  String get historyTitleMine => 'My checks';

  @override
  String get historyTitleFamily => 'Family checks';

  @override
  String get historyAutoDelete =>
      'Checks are automatically deleted after 30 days.';

  @override
  String get historyEmptyTitle => 'No checks yet';

  @override
  String get historyEmptyBody =>
      'When a message worries you, tap \"Pause & Ask\". Your checks will appear here.';

  @override
  String get historyEmptyFamily =>
      'No checks from your family yet. You\'ll get a notification when someone asks.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get deleteCheckConfirm => 'Delete this check?';

  @override
  String get deleteCheckBody => 'It will be removed for you and your family.';

  @override
  String get deletedMessage => 'Deleted';

  @override
  String get noReplyYet => 'No reply yet';

  @override
  String get checkDetailTitle => 'Check details';

  @override
  String get replyButton => 'Reply';

  @override
  String get feedCardTitle => 'Scam alert of the day';

  @override
  String get seeAll => 'See all';

  @override
  String get feedTitle => 'Scam alerts';

  @override
  String get feedEmpty => 'No alerts right now. Please check back soon.';

  @override
  String get shareAlert => 'Share this alert';

  @override
  String sharePromo(String link) {
    return 'Protect your family with PauseAsk: $link';
  }

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String checkinDoneToday(String time) {
    return 'Your family knows you\'re OK today ($time)';
  }

  @override
  String get checkinNotYetToday => 'Tell your family you\'re OK today';

  @override
  String get imOkButton => 'I\'m OK 👍';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsFamily => 'Family & alerts';

  @override
  String get settingsHelp => 'Help & legal';

  @override
  String get settingsAccount => 'Account';

  @override
  String get rolesTitle => 'My role';

  @override
  String get rolesSaved => 'Role updated';

  @override
  String get testAlert => 'Send me a test alert';

  @override
  String get testAlertSent =>
      'Test alert sent. It should arrive in a few seconds.';

  @override
  String get testAlertNoDevice =>
      'This phone isn\'t set up for alerts yet. Allow notifications, then close and open PauseAsk again.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsTitle => 'Terms of use';

  @override
  String get helpFaq => 'Help & FAQ';

  @override
  String get contactSupport => 'Contact support';

  @override
  String noEmailApp(String email) {
    return 'No email app found. Please write to $email.';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get readFullOnline => 'Read the full version online';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountIntro => 'This permanently deletes:';

  @override
  String get deleteItemProfile =>
      'Your profile: name, phone number and settings';

  @override
  String get deleteItemChecks => 'All your checks and their results';

  @override
  String get deleteItemCheckins => 'Your daily check-in and SOS data';

  @override
  String get deleteItemCircle =>
      'Your place in the family circle. If you created it, the member who joined earliest becomes the owner.';

  @override
  String get deleteItemLogin => 'Your sign-in';

  @override
  String get deleteKeptNote =>
      'Replies you gave to your family stay on their checks, without your name.';

  @override
  String get deleteTypeHint => 'Type DELETE to confirm';

  @override
  String get deleteForever => 'Delete my account';

  @override
  String get deleteFailed =>
      'Couldn\'t delete your account right now. Please check your internet and try again.';

  @override
  String get errorScreenTitle => 'Something went wrong';

  @override
  String get errorScreenBody =>
      'Sorry, this part of PauseAsk had a problem. Your information is not affected. Please go back and try again.';

  @override
  String get goHome => 'Go to home';
}
