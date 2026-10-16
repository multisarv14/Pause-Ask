// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'PauseAsk';

  @override
  String get appSubtitle => 'परिवार स्कैम जाँच';

  @override
  String get tagline => 'रुकिए। परिवार से पूछिए। सुरक्षित रहिए।';

  @override
  String get largeText => 'बड़े अक्षर';

  @override
  String get largeTextHint => 'सारे अक्षर बड़े और पढ़ने में आसान बनाएँ';

  @override
  String get languageTitle => 'अपनी भाषा चुनें';

  @override
  String get languageSubtitle => 'आप इसे बाद में भी बदल सकते हैं।';

  @override
  String get onboardingSlide1Title => 'कोई शक वाला मैसेज आया है? ज़रा रुकिए।';

  @override
  String get onboardingSlide1Body =>
      'जल्दबाज़ी में लिंक न खोलें, OTP न बताएँ और पैसे न भेजें। पहले मैसेज PauseAsk को दिखाइए।';

  @override
  String get onboardingSlide2Title => 'एक टैप में परिवार से पूछिए';

  @override
  String get onboardingSlide2Body =>
      'हम आसान शब्दों में खतरा समझाते हैं, और आपके परिवार को तुरंत अलर्ट मिलता है ताकि वे मदद कर सकें।';

  @override
  String get onboardingSlide3Title =>
      'रोज़ का \"मैं ठीक हूँ\" — परिवार रहे बेफ़िक्र';

  @override
  String get onboardingSlide3Body =>
      'दिन में बस एक टैप से परिवार को पता चल जाता है कि आप ठीक हैं। अगर आप भूल जाएँ, तो वे आपका हालचाल ले लेंगे।';

  @override
  String get next => 'आगे';

  @override
  String get skip => 'छोड़ें';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get privacyTitle => 'आपकी प्राइवेसी';

  @override
  String get privacyIntro =>
      'शुरू करने से पहले जान लीजिए कि PauseAsk कौन-सी जानकारी रखता है और क्यों।';

  @override
  String get privacyPointData =>
      'हम आपका नाम, फ़ोन नंबर और आपका परिवार सर्कल सेव करते हैं।';

  @override
  String get privacyPointChecks =>
      'जब आप कोई मैसेज जाँचते हैं, तो सिर्फ़ उसका टेक्स्ट भेजा जाता है। फ़ोन नंबर, OTP और खाता नंबर पहले ही छिपा दिए जाते हैं।';

  @override
  String get privacyPointDelete =>
      'आपकी जाँचें 30 दिन बाद अपने-आप मिट जाती हैं।';

  @override
  String get privacyPointAi =>
      'AI से भी गलती हो सकती है। यह कभी नहीं कहता कि मैसेज सुरक्षित है — शक हो तो परिवार से पूछिए।';

  @override
  String get privacyAgree => 'मैं सहमत हूँ';

  @override
  String get privacyAgreeHint =>
      'PauseAsk इस्तेमाल करने के लिए आपकी सहमति ज़रूरी है।';

  @override
  String get loginTitle => 'अपने फ़ोन नंबर से लॉग इन करें';

  @override
  String get loginSubtitle => 'हम SMS से 6 अंकों का कोड भेजेंगे।';

  @override
  String get countryCodeLabel => 'देश कोड';

  @override
  String get phoneLabel => 'फ़ोन नंबर';

  @override
  String get sendCode => 'कोड भेजें';

  @override
  String get otpTitle => 'कोड डालें';

  @override
  String otpSentTo(String phone) {
    return 'हमने $phone पर 6 अंकों का कोड भेजा है।';
  }

  @override
  String get otpLabel => '6 अंकों का कोड';

  @override
  String get verify => 'पुष्टि करें';

  @override
  String get resendCode => 'कोड दोबारा भेजें';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड बाद कोड दोबारा भेज सकते हैं';
  }

  @override
  String get changeNumber => 'नंबर बदलें';

  @override
  String get errorInvalidPhone =>
      'यह फ़ोन नंबर सही नहीं लग रहा। कृपया एक बार जाँच लें।';

  @override
  String get errorWrongCode => 'यह कोड गलत है। SMS देखकर फिर से डालें।';

  @override
  String get errorCodeExpired =>
      'इस कोड का समय खत्म हो गया है। नया कोड मँगाएँ।';

  @override
  String get errorTooManyAttempts =>
      'बहुत बार कोशिश हो चुकी है। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorNetwork =>
      'इंटरनेट नहीं चल रहा। कनेक्शन देखकर फिर कोशिश करें।';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई। कृपया फिर से कोशिश करें।';

  @override
  String get profileTitle => 'अपने बारे में बताइए';

  @override
  String get nameLabel => 'आपका नाम';

  @override
  String get nameRequired => 'कृपया अपना नाम लिखें।';

  @override
  String get roleQuestion => 'आप PauseAsk का इस्तेमाल कैसे करेंगे?';

  @override
  String get roleProtected => 'मुझे सुरक्षा चाहिए';

  @override
  String get roleProtectedHint => 'शक वाले मैसेज जाँचें और परिवार से मदद पाएँ।';

  @override
  String get roleGuardian => 'परिवार की सुरक्षा मेरी ज़िम्मेदारी';

  @override
  String get roleGuardianHint => 'अलर्ट पाएँ और एक टैप में जवाब दें।';

  @override
  String get roleBoth => 'दोनों';

  @override
  String get roleBothHint => 'खुद भी सुरक्षित रहें और दूसरों का भी ध्यान रखें।';

  @override
  String get roleRequired => 'कृपया कोई एक विकल्प चुनें।';

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String homeGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get homeProtectedText =>
      'कोई मैसेज परेशान करे, तो रुकिए और यहाँ जाँचिए। आपके परिवार को तुरंत खबर मिल जाएगी।';

  @override
  String get homeGuardianText =>
      'जब परिवार में किसी को किसी मैसेज को लेकर मदद चाहिए होगी, आपको अलर्ट मिलेगा।';

  @override
  String get homeBothText =>
      'अपने मैसेज खुद जाँचें, और परिवार के पूछने पर उनकी मदद करें।';

  @override
  String get homeComingSoon => 'और सुविधाएँ जल्द आ रही हैं।';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get profileLoadError => 'आपकी प्रोफ़ाइल लोड नहीं हो पाई।';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get myCircle => 'मेरा परिवार सर्कल';

  @override
  String get circleTitle => 'परिवार सर्कल';

  @override
  String get noCircleTitle => 'आप अभी किसी परिवार सर्कल में नहीं हैं';

  @override
  String get noCircleBody =>
      'नया सर्कल बनाइए और परिवार को बुलाइए, या मिले हुए कोड से किसी सर्कल में जुड़िए।';

  @override
  String get createCircle => 'सर्कल बनाएँ';

  @override
  String get joinWithCode => 'कोड से जुड़ें';

  @override
  String get circleNameLabel => 'सर्कल का नाम';

  @override
  String get circleNameHint => 'जैसे: शर्मा परिवार';

  @override
  String get circleNameRequired => 'कृपया सर्कल का नाम लिखें।';

  @override
  String get createCircleButton => 'बनाएँ';

  @override
  String get joinCodeLabel => '6 अक्षरों का कोड';

  @override
  String get joinCodeHelp =>
      'परिवार के किसी सदस्य से कहिए कि अपने PauseAsk ऐप से आपको कोड भेजें।';

  @override
  String get joinButton => 'जुड़ें';

  @override
  String membersCount(int count, int max) {
    return 'सदस्य: $count / $max';
  }

  @override
  String get badgeOwner => 'प्रमुख';

  @override
  String get badgeProtected => 'संरक्षित';

  @override
  String get badgeGuardian => 'रक्षक';

  @override
  String get badgeYou => 'आप';

  @override
  String get inviteFamily => 'परिवार को बुलाएँ';

  @override
  String get inviteCodeTitle => 'निमंत्रण कोड';

  @override
  String get inviteCodeExplain =>
      'यह कोड अपने परिवार को भेजिए। यह 7 दिन तक चलेगा।';

  @override
  String get inviteViaWhatsApp => 'WhatsApp से बुलाएँ';

  @override
  String get shareOtherWay => 'किसी और तरीके से भेजें';

  @override
  String get copyCode => 'कोड कॉपी करें';

  @override
  String get codeCopied => 'कोड कॉपी हो गया';

  @override
  String get whatsappNotInstalled =>
      'WhatsApp इंस्टॉल नहीं है। कृपया \"किसी और तरीके से भेजें\" दबाएँ।';

  @override
  String inviteMessage(String circleName, String code, String link) {
    return 'नमस्ते! स्कैम से बचने के लिए मैंने PauseAsk ऐप शुरू किया है। कृपया हमारे परिवार सर्कल \"$circleName\" से जुड़िए, ताकि कोई शक वाला मैसेज आए तो मैं पहले आपसे पूछ सकूँ।\n\n1. PauseAsk इंस्टॉल करें: $link\n2. ऐप खोलें और \"कोड से जुड़ें\" दबाएँ\n3. यह कोड डालें: $code\n\nयह कोड 7 दिन तक चलेगा।';
  }

  @override
  String get leaveCircle => 'सर्कल छोड़ें';

  @override
  String get leaveConfirmTitle => 'क्या आप यह सर्कल छोड़ना चाहते हैं?';

  @override
  String get leaveConfirmBody =>
      'इसके बाद आपके परिवार को आपके अलर्ट नहीं मिलेंगे।';

  @override
  String get leaveConfirmOwnerBody =>
      'आप इस सर्कल के प्रमुख हैं। आपके बाद सबसे पहले जुड़ने वाला सदस्य नया प्रमुख बनेगा। अगर आप अकेले सदस्य हैं, तो सर्कल मिट जाएगा।';

  @override
  String get removeMember => 'हटाएँ';

  @override
  String removeConfirmTitle(String name) {
    return '$name को सर्कल से हटाएँ?';
  }

  @override
  String get removeConfirmBody =>
      'उन्हें इस सर्कल के अलर्ट मिलना बंद हो जाएगा।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get circleErrorAlreadyInCircle =>
      'आप पहले से एक परिवार सर्कल में हैं। एक समय में एक ही सर्कल में रह सकते हैं।';

  @override
  String get circleErrorFull =>
      'यह सर्कल भर चुका है (ज़्यादा से ज़्यादा 5 सदस्य)।';

  @override
  String get circleErrorInvalidCode =>
      'यह कोड किसी सर्कल से मेल नहीं खाता। जाँचकर फिर से कोशिश करें।';

  @override
  String get circleErrorCodeExpired =>
      'इस कोड का समय खत्म हो गया है। परिवार से नया कोड माँगिए।';

  @override
  String get circleErrorCodeUsedUp =>
      'यह कोड अब इस्तेमाल नहीं हो सकता। परिवार से नया कोड माँगिए।';

  @override
  String get circleErrorAlreadyMember => 'आप पहले से इसी सर्कल में हैं।';

  @override
  String get circleErrorNotOwner => 'यह सिर्फ़ सर्कल के प्रमुख कर सकते हैं।';

  @override
  String get circleErrorTooManyAttempts =>
      'बहुत बार गलत कोड डाला गया। एक घंटे बाद फिर कोशिश करें।';
}
