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
  String get homeGuardianText =>
      'जब परिवार में किसी को किसी मैसेज को लेकर मदद चाहिए होगी, आपको अलर्ट मिलेगा।';

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

  @override
  String get pauseAndAsk => 'रुकिए और पूछिए';

  @override
  String get pauseAndAskHint => 'किसी मैसेज पर शक है? यहाँ जाँचिए।';

  @override
  String get tellUsWhatHappened => 'बोलकर बताइए क्या हुआ';

  @override
  String get pasteOrType => 'मैसेज पेस्ट करें या लिखें';

  @override
  String get pickScreenshot => 'स्क्रीनशॉट चुनें';

  @override
  String get shareTip =>
      'टिप: WhatsApp या SMS में मैसेज को दबाकर रखें → शेयर → PauseAsk चुनें।';

  @override
  String get chooseHowTitle => 'आप कैसे जाँचना चाहते हैं?';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get composeTitle => 'मैसेज जाँचें';

  @override
  String get composeHint => 'मैसेज यहाँ पेस्ट करें या लिखें';

  @override
  String get composeConfirmHint =>
      'नीचे दिया टेक्स्ट देख लें। जाँचने से पहले आप इसे ठीक कर सकते हैं।';

  @override
  String get pasteButton => 'पेस्ट करें';

  @override
  String get checkNow => 'अभी जाँचें';

  @override
  String get textEmpty => 'पहले कोई मैसेज पेस्ट करें या लिखें।';

  @override
  String textTooLong(int max) {
    return 'यह मैसेज बहुत लंबा है। सिर्फ़ ज़रूरी हिस्सा रखें ($max अक्षरों तक)।';
  }

  @override
  String get readingScreenshot => 'स्क्रीनशॉट पढ़ रहे हैं…';

  @override
  String get ocrNoText =>
      'इस तस्वीर में कोई टेक्स्ट नहीं मिला। दूसरा स्क्रीनशॉट चुनें या मैसेज लिखें।';

  @override
  String get imageStaysOnPhone =>
      'तस्वीर आपके फ़ोन में ही रहती है। सिर्फ़ टेक्स्ट जाँचा जाता है।';

  @override
  String get voiceIntro =>
      'माइक दबाइए और बताइए कि मैसेज में या फ़ोन करने वाले ने क्या कहा।';

  @override
  String get voiceListening => 'सुन रहे हैं… अब बोलिए';

  @override
  String get voiceTapToStart => 'बोलने के लिए दबाएँ';

  @override
  String get voiceTapToStop => 'रोकने के लिए दबाएँ';

  @override
  String get voiceUseText => 'यह टेक्स्ट इस्तेमाल करें';

  @override
  String get voiceNotAvailable =>
      'इस फ़ोन पर इस भाषा में बोलकर लिखने की सुविधा नहीं है। Google ऐप → सेटिंग्स → वॉइस → ऑफ़लाइन स्पीच रिकग्निशन में भाषा डाउनलोड करें, या मैसेज लिखें।';

  @override
  String get micPermissionDenied =>
      'आपकी आवाज़ सुनने के लिए PauseAsk को माइक की अनुमति चाहिए। फ़ोन की सेटिंग्स में अनुमति दे सकते हैं।';

  @override
  String get voiceNothingHeard =>
      'हमें कुछ सुनाई नहीं दिया। फिर से कोशिश करें।';

  @override
  String get checkingTitle => 'जाँच हो रही है…';

  @override
  String get checkingReminder => 'तब तक न पैसे भेजें, न कोई OTP बताएँ।';

  @override
  String get riskHigh => 'बहुत ज़्यादा खतरा';

  @override
  String get riskSuspicious => 'संदिग्ध';

  @override
  String get riskBeCareful => 'सावधान रहें';

  @override
  String riskSemantics(String level) {
    return 'नतीजा: $level';
  }

  @override
  String get redFlagsTitle => 'खतरे के संकेत';

  @override
  String get whatToDoTitle => 'अब क्या करें';

  @override
  String get readAloud => 'पढ़कर सुनाएँ';

  @override
  String get stopReading => 'पढ़ना रोकें';

  @override
  String get ttsVoiceMissing =>
      'इस भाषा की आवाज़ फ़ोन में इंस्टॉल नहीं है। फ़ोन की सेटिंग्स → टेक्स्ट-टू-स्पीच में इंस्टॉल करें।';

  @override
  String get resultDisclaimer =>
      'PauseAsk से भी गलती हो सकती है। मैसेज ठीक है या नहीं, यह सिर्फ़ आपका परिवार बता सकता है।';

  @override
  String get done => 'हो गया';

  @override
  String get checkAnother => 'दूसरा मैसेज जाँचें';

  @override
  String get checkErrorDailyLimit =>
      'आज की सभी 10 जाँचें हो चुकी हैं। चिंता हो तो अभी परिवार के किसी सदस्य को फ़ोन करें। कल आप फिर से जाँच सकेंगे।';

  @override
  String get checkErrorNetwork =>
      'इंटरनेट नहीं चल रहा। मोबाइल डेटा या Wi-Fi चालू करके फिर कोशिश करें। तब तक न पैसे भेजें, न OTP बताएँ।';

  @override
  String get checkErrorGeneric =>
      'अभी यह मैसेज जाँच नहीं पाए। फिर से कोशिश करें। चिंता हो तो परिवार के किसी सदस्य को फ़ोन करें।';

  @override
  String get goBack => 'वापस जाएँ';

  @override
  String get guardianAlertTitle => 'परिवार को मदद चाहिए';

  @override
  String askedBy(String name, String time) {
    return '$name ने $time पर पूछा';
  }

  @override
  String get maskedMessageTitle => 'मैसेज (निजी जानकारी छिपाई गई है)';

  @override
  String get respondStop => 'रुकिए – कुछ न करें, आपको अभी फ़ोन आएगा';

  @override
  String get respondOk => 'मैंने जाँच लिया – ठीक है';

  @override
  String get respondCall => 'अभी फ़ोन करें';

  @override
  String replySent(String name) {
    return 'आपका जवाब $name को भेज दिया गया।';
  }

  @override
  String alreadyAnswered(String name, String reply) {
    return '$name पहले ही जवाब दे चुके हैं: $reply';
  }

  @override
  String get responseLabelStop => 'रुकिए';

  @override
  String get responseLabelOk => 'ठीक है';

  @override
  String get responseLabelCall => 'फ़ोन कर रहे हैं';

  @override
  String get noPhone => 'फ़ोन नंबर उपलब्ध नहीं है।';

  @override
  String responseStopBody(String name) {
    return 'कुछ न करें। न पैसे भेजें, न कोई OTP बताएँ। $name आपको फ़ोन करेंगे।';
  }

  @override
  String responseOkBody(String name) {
    return '$name ने यह मैसेज जाँच लिया है: ठीक है।';
  }

  @override
  String get responseCallTitle => 'फ़ोन उठाइए';

  @override
  String responseCallBody(String name) {
    return '$name अभी आपको फ़ोन कर रहे हैं। बात होने तक कुछ न करें।';
  }

  @override
  String get closeButton => 'बंद करें';

  @override
  String get familyAlerting => 'परिवार को खबर भेज रहे हैं…';

  @override
  String get familyAlerted => 'आपके परिवार को खबर भेज दी गई है।';

  @override
  String get familyNoGuardian =>
      'आपके सर्कल में अभी कोई जवाब देने वाला (रक्षक) नहीं है। परिवार के किसी सदस्य को रक्षक के रूप में जोड़िए।';

  @override
  String get familyAddToGetHelp => 'मदद पाने के लिए परिवार को जोड़ें।';

  @override
  String familyReplied(String name, String reply) {
    return '$name का जवाब: $reply';
  }

  @override
  String get viewReply => 'जवाब देखें';

  @override
  String get openRequestsTitle => 'परिवार के सवाल';

  @override
  String get noOpenRequests =>
      'अभी कोई सवाल बाकी नहीं है। किसी को मदद चाहिए होगी तो आपको सूचना मिलेगी।';

  @override
  String get memberStatusTitle => 'परिवार का हाल';

  @override
  String get channelAlertsName => 'परिवार के अलर्ट';

  @override
  String get channelAlertsDescription => 'जब परिवार मदद माँगे या आपको जवाब दे';

  @override
  String get channelGeneralName => 'सामान्य';

  @override
  String get sosButton => 'मुझे अभी मदद चाहिए';

  @override
  String get sosHoldHint => '2 सेकंड तक दबाकर रखें';

  @override
  String get sosSending => 'SOS भेज रहे हैं…';

  @override
  String get sosAlerted => 'आपके परिवार को खबर भेज दी गई है';

  @override
  String get sosNoGuardian =>
      'परिवार सर्कल में किसी को खबर नहीं भेजी जा सकी। कृपया अभी किसी भरोसेमंद व्यक्ति को फ़ोन करें।';

  @override
  String sosCallGuardian(String name) {
    return '$name को फ़ोन करें';
  }

  @override
  String get sosCall1930 => '1930 पर फ़ोन करें – साइबर क्राइम हेल्पलाइन';

  @override
  String get sos1930Explain =>
      'अगर पैसे कट गए हैं या आपने बैंक की जानकारी या OTP बता दिया है, तो 1930 पर फ़ोन करें। जल्दी फ़ोन करने से पैसा रोका जा सकता है।';

  @override
  String get sosLimit =>
      'आप पिछले एक घंटे में 5 बार SOS भेज चुके हैं। कृपया सीधे परिवार को फ़ोन करें।';

  @override
  String get sosFailed =>
      'SOS नहीं भेजा जा सका। कृपया सीधे परिवार को फ़ोन करें।';

  @override
  String sosAlertTitle(String name) {
    return '$name को अभी मदद चाहिए';
  }

  @override
  String sosAlertBody(String name) {
    return '$name ने SOS बटन दबाया है। कृपया तुरंत उन्हें फ़ोन करें।';
  }

  @override
  String get callButton => 'फ़ोन करें';

  @override
  String get checkinTitle => 'रोज़ का \"मैं ठीक हूँ\"';

  @override
  String get checkinExplain =>
      'रोज़ इस समय हम आपको याद दिलाएँगे कि परिवार को बता दें कि आप ठीक हैं। अगर आप नहीं बताते, तो उन्हें एक हल्का-सा अलर्ट जाएगा।';

  @override
  String get checkinEnabled => 'रोज़ की हाज़िरी';

  @override
  String get checkinTime => 'याद दिलाने का समय';

  @override
  String get checkinAlertAfter => 'इतने समय बाद भी न बताएँ तो परिवार को अलर्ट';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे',
      one: '1 घंटा',
    );
    return '$_temp0';
  }

  @override
  String get checkinChangeNote =>
      'परिवार को अलर्ट वाले बदलाव कल से लागू होंगे।';

  @override
  String get saveButton => 'सेव करें';

  @override
  String get saved => 'सेव हो गया';

  @override
  String get checkinReminderMorning =>
      'सुप्रभात! परिवार को बताने के लिए दबाएँ कि आप ठीक हैं 👍';

  @override
  String get checkinReminderOther =>
      'नमस्ते! परिवार को बताने के लिए दबाएँ कि आप ठीक हैं 👍';

  @override
  String get checkinThanks =>
      'धन्यवाद! आपके परिवार को पता है कि आप आज ठीक हैं।';

  @override
  String statusOkAt(String time) {
    return 'आज $time बजे: ठीक हैं';
  }

  @override
  String get statusNotYet => 'आज अभी तक नहीं';

  @override
  String get statusMissed => 'आज की हाज़िरी छूट गई';

  @override
  String get statusOff => 'रोज़ की हाज़िरी बंद है';

  @override
  String get batteryGuideTitle => 'पक्का करें कि अलर्ट आप तक पहुँचें';

  @override
  String get batteryGuideIntro =>
      'कुछ फ़ोन बैटरी बचाने के लिए ऐप बंद कर देते हैं। तब परिवार के अलर्ट देर से आते हैं या आते ही नहीं। कृपया ये 2 आसान काम कर लें:';

  @override
  String get batteryStepNotifications =>
      '1. PauseAsk के लिए नोटिफ़िकेशन चालू करें';

  @override
  String get batteryStepBattery =>
      '2. PauseAsk के लिए बैटरी को \"कोई पाबंदी नहीं\" / \"ऑप्टिमाइज़ न करें\" पर रखें';

  @override
  String get batteryStepAutostart =>
      'कुछ फ़ोन में ऐप सेटिंग्स में PauseAsk के लिए \"ऑटोस्टार्ट\" भी चालू करें।';

  @override
  String get openNotificationSettings => 'नोटिफ़िकेशन सेटिंग्स खोलें';

  @override
  String get openBatterySettings => 'बैटरी सेटिंग्स खोलें';

  @override
  String get openAppSettings => 'ऐप सेटिंग्स खोलें';

  @override
  String get notificationHelp => 'नोटिफ़िकेशन मदद';

  @override
  String get historyTitleMine => 'मेरी जाँचें';

  @override
  String get historyTitleFamily => 'परिवार की जाँचें';

  @override
  String get historyAutoDelete => 'जाँचें 30 दिन बाद अपने-आप मिट जाती हैं।';

  @override
  String get historyEmptyTitle => 'अभी तक कोई जाँच नहीं';

  @override
  String get historyEmptyBody =>
      'जब कोई मैसेज परेशान करे, \"रुकिए और पूछिए\" दबाएँ। आपकी जाँचें यहाँ दिखेंगी।';

  @override
  String get historyEmptyFamily =>
      'परिवार की ओर से अभी कोई जाँच नहीं। कोई पूछेगा तो आपको सूचना मिलेगी।';

  @override
  String get deleteButton => 'मिटाएँ';

  @override
  String get deleteCheckConfirm => 'यह जाँच मिटाएँ?';

  @override
  String get deleteCheckBody =>
      'यह आपके और आपके परिवार, दोनों के लिए हट जाएगी।';

  @override
  String get deletedMessage => 'मिटा दी गई';

  @override
  String get noReplyYet => 'अभी जवाब नहीं आया';

  @override
  String get checkDetailTitle => 'जाँच का विवरण';

  @override
  String get replyButton => 'जवाब दें';

  @override
  String get feedCardTitle => 'आज का स्कैम अलर्ट';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get feedTitle => 'स्कैम अलर्ट';

  @override
  String get feedEmpty => 'अभी कोई अलर्ट नहीं है। जल्द फिर देखें।';

  @override
  String get shareAlert => 'यह अलर्ट शेयर करें';

  @override
  String sharePromo(String link) {
    return 'PauseAsk से अपने परिवार को सुरक्षित रखें: $link';
  }

  @override
  String get readMore => 'और पढ़ें';

  @override
  String get showLess => 'कम दिखाएँ';

  @override
  String greetingMorning(String name) {
    return 'सुप्रभात, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'शुभ संध्या, $name';
  }

  @override
  String checkinDoneToday(String time) {
    return 'आपके परिवार को पता है कि आप आज ठीक हैं ($time)';
  }

  @override
  String get checkinNotYetToday => 'परिवार को बताइए कि आप आज ठीक हैं';

  @override
  String get imOkButton => 'मैं ठीक हूँ 👍';

  @override
  String get settingsGeneral => 'सामान्य';

  @override
  String get settingsFamily => 'परिवार और अलर्ट';

  @override
  String get settingsHelp => 'मदद और नियम';

  @override
  String get settingsAccount => 'अकाउंट';

  @override
  String get rolesTitle => 'मेरी भूमिका';

  @override
  String get rolesSaved => 'भूमिका बदल दी गई';

  @override
  String get testAlert => 'मुझे एक टेस्ट अलर्ट भेजें';

  @override
  String get testAlertSent =>
      'टेस्ट अलर्ट भेज दिया। कुछ सेकंड में आ जाना चाहिए।';

  @override
  String get testAlertNoDevice =>
      'यह फ़ोन अभी अलर्ट के लिए तैयार नहीं है। नोटिफ़िकेशन की अनुमति दें, फिर PauseAsk बंद करके दोबारा खोलें।';

  @override
  String get privacyPolicy => 'प्राइवेसी पॉलिसी';

  @override
  String get termsTitle => 'उपयोग की शर्तें';

  @override
  String get helpFaq => 'मदद और सवाल-जवाब';

  @override
  String get contactSupport => 'सहायता से संपर्क करें';

  @override
  String noEmailApp(String email) {
    return 'कोई ईमेल ऐप नहीं मिला। कृपया $email पर लिखें।';
  }

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get readFullOnline => 'पूरा संस्करण ऑनलाइन पढ़ें';

  @override
  String get deleteAccount => 'अकाउंट मिटाएँ';

  @override
  String get deleteAccountIntro => 'इससे हमेशा के लिए मिट जाएगा:';

  @override
  String get deleteItemProfile => 'आपकी प्रोफ़ाइल: नाम, फ़ोन नंबर और सेटिंग्स';

  @override
  String get deleteItemChecks => 'आपकी सभी जाँचें और उनके नतीजे';

  @override
  String get deleteItemCheckins => 'रोज़ की हाज़िरी और SOS की जानकारी';

  @override
  String get deleteItemCircle =>
      'परिवार सर्कल में आपकी जगह। अगर सर्कल आपने बनाया था, तो सबसे पहले जुड़ने वाला सदस्य उसका प्रमुख बन जाएगा।';

  @override
  String get deleteItemLogin => 'आपका लॉग इन';

  @override
  String get deleteKeptNote =>
      'परिवार को दिए आपके जवाब उनकी जाँचों में रहेंगे, पर आपके नाम के बिना।';

  @override
  String get deleteTypeHint => 'पक्का करने के लिए DELETE लिखें';

  @override
  String get deleteForever => 'मेरा अकाउंट मिटाएँ';

  @override
  String get deleteFailed =>
      'अभी अकाउंट नहीं मिटा पाए। इंटरनेट देखकर फिर कोशिश करें।';

  @override
  String get errorScreenTitle => 'कुछ गड़बड़ हो गई';

  @override
  String get errorScreenBody =>
      'माफ़ कीजिए, PauseAsk के इस हिस्से में दिक्कत आई। आपकी जानकारी पर कोई असर नहीं पड़ा। कृपया वापस जाकर फिर कोशिश करें।';

  @override
  String get goHome => 'होम पर जाएँ';
}
