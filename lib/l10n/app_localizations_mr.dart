// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'PauseAsk';

  @override
  String get appSubtitle => 'कौटुंबिक फसवणूक तपासणी';

  @override
  String get tagline => 'थांबा. कुटुंबाला विचारा. सुरक्षित राहा.';

  @override
  String get largeText => 'मोठी अक्षरे';

  @override
  String get largeTextHint => 'सर्व मजकूर मोठा आणि वाचायला सोपा करा';

  @override
  String get languageTitle => 'तुमची भाषा निवडा';

  @override
  String get languageSubtitle => 'हे तुम्ही नंतरही बदलू शकता.';

  @override
  String get onboardingSlide1Title => 'काही संशयास्पद मेसेज आला? जरा थांबा.';

  @override
  String get onboardingSlide1Body =>
      'घाईघाईत लिंक उघडू नका, OTP सांगू नका आणि पैसे पाठवू नका. आधी तो मेसेज PauseAsk ला दाखवा.';

  @override
  String get onboardingSlide2Title => 'एका टॅपमध्ये कुटुंबाला विचारा';

  @override
  String get onboardingSlide2Body =>
      'आम्ही धोका सोप्या शब्दांत समजावून सांगतो आणि तुमच्या कुटुंबाला लगेच सूचना मिळते, म्हणजे ते मदत करू शकतात.';

  @override
  String get onboardingSlide3Title => 'रोजचं \"मी ठीक आहे\" — कुटुंब निश्चिंत';

  @override
  String get onboardingSlide3Body =>
      'दिवसातून फक्त एक टॅप केला की कुटुंबाला कळतं तुम्ही ठीक आहात. विसरलात, तर ते तुमची विचारपूस करतील.';

  @override
  String get next => 'पुढे';

  @override
  String get skip => 'वगळा';

  @override
  String get getStarted => 'सुरू करा';

  @override
  String get privacyTitle => 'तुमची गोपनीयता';

  @override
  String get privacyIntro =>
      'सुरू करण्याआधी जाणून घ्या की PauseAsk कोणती माहिती ठेवतं आणि का.';

  @override
  String get privacyPointData =>
      'आम्ही तुमचं नाव, फोन नंबर आणि तुमचं कुटुंब सर्कल सेव्ह करतो.';

  @override
  String get privacyPointChecks =>
      'तुम्ही मेसेज तपासता तेव्हा फक्त त्याचा मजकूर पाठवला जातो. फोन नंबर, OTP आणि खाते क्रमांक आधीच लपवले जातात.';

  @override
  String get privacyPointDelete =>
      'तुमच्या तपासण्या 30 दिवसांनी आपोआप हटवल्या जातात.';

  @override
  String get privacyPointAi =>
      'AI सुद्धा चुकू शकतो. तो कधीच मेसेज सुरक्षित आहे असं सांगत नाही — शंका असेल तर कुटुंबाला विचारा.';

  @override
  String get privacyAgree => 'मला मान्य आहे';

  @override
  String get privacyAgreeHint =>
      'PauseAsk वापरण्यासाठी तुमची संमती आवश्यक आहे.';

  @override
  String get loginTitle => 'तुमच्या फोन नंबरने लॉग इन करा';

  @override
  String get loginSubtitle => 'आम्ही SMS ने 6 अंकी कोड पाठवू.';

  @override
  String get countryCodeLabel => 'देश कोड';

  @override
  String get phoneLabel => 'फोन नंबर';

  @override
  String get sendCode => 'कोड पाठवा';

  @override
  String get otpTitle => 'कोड टाका';

  @override
  String otpSentTo(String phone) {
    return 'आम्ही $phone वर 6 अंकी कोड पाठवला आहे.';
  }

  @override
  String get otpLabel => '6 अंकी कोड';

  @override
  String get verify => 'पडताळा';

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंदांनंतर कोड पुन्हा पाठवता येईल';
  }

  @override
  String get changeNumber => 'नंबर बदला';

  @override
  String get errorInvalidPhone =>
      'हा फोन नंबर बरोबर वाटत नाही. कृपया एकदा तपासा.';

  @override
  String get errorWrongCode => 'हा कोड चुकीचा आहे. SMS पाहून पुन्हा टाका.';

  @override
  String get errorCodeExpired => 'या कोडची वेळ संपली आहे. नवीन कोड मागवा.';

  @override
  String get errorTooManyAttempts =>
      'खूप वेळा प्रयत्न झाले आहेत. थोड्या वेळाने पुन्हा प्रयत्न करा.';

  @override
  String get errorNetwork =>
      'इंटरनेट चालू नाही. कनेक्शन तपासून पुन्हा प्रयत्न करा.';

  @override
  String get errorGeneric => 'काहीतरी चुकलं. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get profileTitle => 'तुमच्याबद्दल सांगा';

  @override
  String get nameLabel => 'तुमचं नाव';

  @override
  String get nameRequired => 'कृपया तुमचं नाव लिहा.';

  @override
  String get roleQuestion => 'तुम्ही PauseAsk कसं वापरणार?';

  @override
  String get roleProtected => 'मला संरक्षण हवं आहे';

  @override
  String get roleProtectedHint =>
      'संशयास्पद मेसेज तपासा आणि कुटुंबाची मदत मिळवा.';

  @override
  String get roleGuardian => 'कुटुंबाचं रक्षण माझी जबाबदारी';

  @override
  String get roleGuardianHint => 'सूचना मिळवा आणि एका टॅपमध्ये उत्तर द्या.';

  @override
  String get roleBoth => 'दोन्ही';

  @override
  String get roleBothHint => 'स्वतःही सुरक्षित राहा आणि इतरांचीही काळजी घ्या.';

  @override
  String get roleRequired => 'कृपया एक पर्याय निवडा.';

  @override
  String get continueButton => 'पुढे चला';

  @override
  String get homeGuardianText =>
      'कुटुंबातील कोणाला एखाद्या मेसेजबद्दल मदत हवी असेल, तेव्हा तुम्हाला सूचना मिळेल.';

  @override
  String get changeLanguage => 'भाषा बदला';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get loading => 'लोड होत आहे…';

  @override
  String get profileLoadError => 'तुमची प्रोफाइल लोड झाली नाही.';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get myCircle => 'माझं कुटुंब सर्कल';

  @override
  String get circleTitle => 'कुटुंब सर्कल';

  @override
  String get noCircleTitle => 'तुम्ही अजून कोणत्याही कुटुंब सर्कलमध्ये नाही';

  @override
  String get noCircleBody =>
      'नवीन सर्कल तयार करा आणि कुटुंबाला बोलवा, किंवा मिळालेल्या कोडने एखाद्या सर्कलमध्ये सामील व्हा.';

  @override
  String get createCircle => 'सर्कल तयार करा';

  @override
  String get joinWithCode => 'कोडने सामील व्हा';

  @override
  String get circleNameLabel => 'सर्कलचं नाव';

  @override
  String get circleNameHint => 'उदा. पाटील कुटुंब';

  @override
  String get circleNameRequired => 'कृपया सर्कलचं नाव लिहा.';

  @override
  String get createCircleButton => 'तयार करा';

  @override
  String get joinCodeLabel => '6 अक्षरी कोड';

  @override
  String get joinCodeHelp =>
      'कुटुंबातील एखाद्या सदस्याला त्यांच्या PauseAsk ॲपमधून कोड पाठवायला सांगा.';

  @override
  String get joinButton => 'सामील व्हा';

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
  String get badgeYou => 'तुम्ही';

  @override
  String get inviteFamily => 'कुटुंबाला बोलवा';

  @override
  String get inviteCodeTitle => 'निमंत्रण कोड';

  @override
  String get inviteCodeExplain =>
      'हा कोड तुमच्या कुटुंबाला पाठवा. तो 7 दिवस चालेल.';

  @override
  String get inviteViaWhatsApp => 'WhatsApp ने बोलवा';

  @override
  String get shareOtherWay => 'दुसऱ्या पद्धतीने पाठवा';

  @override
  String get copyCode => 'कोड कॉपी करा';

  @override
  String get codeCopied => 'कोड कॉपी झाला';

  @override
  String get whatsappNotInstalled =>
      'WhatsApp इंस्टॉल नाही. कृपया \"दुसऱ्या पद्धतीने पाठवा\" दाबा.';

  @override
  String inviteMessage(String circleName, String code, String link) {
    return 'नमस्कार! फसवणुकीपासून वाचण्यासाठी मी PauseAsk ॲप वापरायला सुरुवात केली आहे. कृपया आपल्या कुटुंब सर्कल \"$circleName\" मध्ये सामील व्हा, म्हणजे एखादा संशयास्पद मेसेज आला तर मला आधी तुम्हाला विचारता येईल.\n\n1. PauseAsk इंस्टॉल करा: $link\n2. ॲप उघडा आणि \"कोडने सामील व्हा\" दाबा\n3. हा कोड टाका: $code\n\nहा कोड 7 दिवस चालेल.';
  }

  @override
  String get leaveCircle => 'सर्कल सोडा';

  @override
  String get leaveConfirmTitle => 'हे सर्कल सोडायचं आहे का?';

  @override
  String get leaveConfirmBody =>
      'त्यानंतर तुमच्या कुटुंबाला तुमच्या सूचना मिळणार नाहीत.';

  @override
  String get leaveConfirmOwnerBody =>
      'तुम्ही या सर्कलचे प्रमुख आहात. तुमच्यानंतर सर्वात आधी सामील झालेला सदस्य नवीन प्रमुख होईल. तुम्ही एकटेच सदस्य असाल, तर सर्कल हटवलं जाईल.';

  @override
  String get removeMember => 'काढा';

  @override
  String removeConfirmTitle(String name) {
    return '$name यांना सर्कलमधून काढायचं?';
  }

  @override
  String get removeConfirmBody => 'त्यांना या सर्कलच्या सूचना मिळणं बंद होईल.';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get circleErrorAlreadyInCircle =>
      'तुम्ही आधीच एका कुटुंब सर्कलमध्ये आहात. एका वेळी एकाच सर्कलमध्ये राहता येतं.';

  @override
  String get circleErrorFull => 'हे सर्कल भरलं आहे (जास्तीत जास्त 5 सदस्य).';

  @override
  String get circleErrorInvalidCode =>
      'हा कोड कोणत्याही सर्कलशी जुळत नाही. तपासून पुन्हा प्रयत्न करा.';

  @override
  String get circleErrorCodeExpired =>
      'या कोडची मुदत संपली आहे. कुटुंबाकडून नवीन कोड मागा.';

  @override
  String get circleErrorCodeUsedUp =>
      'हा कोड आता वापरता येणार नाही. कुटुंबाकडून नवीन कोड मागा.';

  @override
  String get circleErrorAlreadyMember => 'तुम्ही आधीच याच सर्कलमध्ये आहात.';

  @override
  String get circleErrorNotOwner => 'हे फक्त सर्कल प्रमुख करू शकतात.';

  @override
  String get circleErrorTooManyAttempts =>
      'खूप वेळा चुकीचा कोड टाकला गेला. एका तासाने पुन्हा प्रयत्न करा.';

  @override
  String get pauseAndAsk => 'थांबा आणि विचारा';

  @override
  String get pauseAndAskHint => 'एखाद्या मेसेजबद्दल शंका आहे? इथे तपासा.';

  @override
  String get tellUsWhatHappened => 'काय झालं ते बोलून सांगा';

  @override
  String get pasteOrType => 'मेसेज पेस्ट करा किंवा लिहा';

  @override
  String get pickScreenshot => 'स्क्रीनशॉट निवडा';

  @override
  String get shareTip =>
      'टीप: WhatsApp किंवा SMS मध्ये मेसेजवर बोट दाबून ठेवा → शेअर → PauseAsk निवडा.';

  @override
  String get chooseHowTitle => 'तुम्हाला कसं तपासायचं आहे?';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get composeTitle => 'मेसेज तपासा';

  @override
  String get composeHint => 'मेसेज इथे पेस्ट करा किंवा लिहा';

  @override
  String get composeConfirmHint =>
      'खालचा मजकूर नीट पाहा. तपासण्याआधी तुम्ही तो दुरुस्त करू शकता.';

  @override
  String get pasteButton => 'पेस्ट करा';

  @override
  String get checkNow => 'आता तपासा';

  @override
  String get textEmpty => 'आधी एखादा मेसेज पेस्ट करा किंवा लिहा.';

  @override
  String textTooLong(int max) {
    return 'हा मेसेज खूप मोठा आहे. फक्त महत्त्वाचा भाग ठेवा ($max अक्षरांपर्यंत).';
  }

  @override
  String get readingScreenshot => 'स्क्रीनशॉट वाचत आहोत…';

  @override
  String get ocrNoText =>
      'या चित्रात कोणताही मजकूर सापडला नाही. दुसरा स्क्रीनशॉट निवडा किंवा मेसेज लिहा.';

  @override
  String get imageStaysOnPhone =>
      'चित्र तुमच्या फोनवरच राहतं. फक्त मजकूर तपासला जातो.';

  @override
  String get voiceIntro =>
      'माइक दाबा आणि मेसेजमध्ये किंवा फोन करणाऱ्याने काय सांगितलं ते बोला.';

  @override
  String get voiceListening => 'ऐकत आहोत… आता बोला';

  @override
  String get voiceTapToStart => 'बोलण्यासाठी दाबा';

  @override
  String get voiceTapToStop => 'थांबवण्यासाठी दाबा';

  @override
  String get voiceUseText => 'हा मजकूर वापरा';

  @override
  String get voiceNotAvailable =>
      'या फोनवर या भाषेत बोलून लिहिण्याची सुविधा नाही. Google ॲप → सेटिंग्ज → व्हॉइस → ऑफलाइन स्पीच रेकग्निशन मध्ये भाषा डाउनलोड करा, किंवा मेसेज लिहा.';

  @override
  String get micPermissionDenied =>
      'तुमचा आवाज ऐकण्यासाठी PauseAsk ला माइकची परवानगी हवी. फोनच्या सेटिंग्जमध्ये परवानगी देऊ शकता.';

  @override
  String get voiceNothingHeard =>
      'आम्हाला काही ऐकू आलं नाही. पुन्हा प्रयत्न करा.';

  @override
  String get checkingTitle => 'तपासत आहोत…';

  @override
  String get checkingReminder =>
      'तोपर्यंत पैसे पाठवू नका आणि कोणालाही OTP सांगू नका.';

  @override
  String get riskHigh => 'मोठा धोका';

  @override
  String get riskSuspicious => 'संशयास्पद';

  @override
  String get riskBeCareful => 'सावध राहा';

  @override
  String riskSemantics(String level) {
    return 'निकाल: $level';
  }

  @override
  String get redFlagsTitle => 'धोक्याची लक्षणं';

  @override
  String get whatToDoTitle => 'आता काय करावं';

  @override
  String get readAloud => 'वाचून दाखवा';

  @override
  String get stopReading => 'वाचन थांबवा';

  @override
  String get ttsVoiceMissing =>
      'या भाषेचा आवाज फोनमध्ये इंस्टॉल नाही. फोनच्या सेटिंग्ज → टेक्स्ट-टू-स्पीच मध्ये इंस्टॉल करा.';

  @override
  String get resultDisclaimer =>
      'PauseAsk सुद्धा चुकू शकतं. मेसेज ठीक आहे की नाही, हे फक्त तुमचं कुटुंब सांगू शकतं.';

  @override
  String get done => 'झालं';

  @override
  String get checkAnother => 'दुसरा मेसेज तपासा';

  @override
  String get checkErrorDailyLimit =>
      'आजच्या सर्व 10 तपासण्या झाल्या आहेत. काळजी वाटत असेल तर आत्ता कुटुंबातील कोणाला तरी फोन करा. उद्या पुन्हा तपासता येईल.';

  @override
  String get checkErrorNetwork =>
      'इंटरनेट चालू नाही. मोबाइल डेटा किंवा Wi-Fi सुरू करून पुन्हा प्रयत्न करा. तोपर्यंत पैसे पाठवू नका आणि OTP सांगू नका.';

  @override
  String get checkErrorGeneric =>
      'आत्ता हा मेसेज तपासता आला नाही. पुन्हा प्रयत्न करा. काळजी वाटत असेल तर कुटुंबातील कोणाला तरी फोन करा.';

  @override
  String get goBack => 'मागे जा';

  @override
  String get guardianAlertTitle => 'कुटुंबाला मदत हवी आहे';

  @override
  String askedBy(String name, String time) {
    return '$name यांनी $time वाजता विचारलं';
  }

  @override
  String get maskedMessageTitle => 'मेसेज (खासगी माहिती लपवली आहे)';

  @override
  String get respondStop => 'थांबा – काहीही करू नका, तुम्हाला आत्ता फोन येईल';

  @override
  String get respondOk => 'मी तपासलं – ठीक आहे';

  @override
  String get respondCall => 'आत्ता फोन करा';

  @override
  String replySent(String name) {
    return 'तुमचं उत्तर $name यांना पाठवलं.';
  }

  @override
  String alreadyAnswered(String name, String reply) {
    return '$name यांनी आधीच उत्तर दिलं आहे: $reply';
  }

  @override
  String get responseLabelStop => 'थांबा';

  @override
  String get responseLabelOk => 'ठीक आहे';

  @override
  String get responseLabelCall => 'फोन करत आहेत';

  @override
  String get noPhone => 'फोन नंबर उपलब्ध नाही.';

  @override
  String responseStopBody(String name) {
    return 'काहीही करू नका. पैसे पाठवू नका, OTP सांगू नका. $name तुम्हाला फोन करतील.';
  }

  @override
  String responseOkBody(String name) {
    return '$name यांनी हा मेसेज तपासला आहे: ठीक आहे.';
  }

  @override
  String get responseCallTitle => 'फोन उचला';

  @override
  String responseCallBody(String name) {
    return '$name आत्ता तुम्हाला फोन करत आहेत. बोलणं होईपर्यंत काहीही करू नका.';
  }

  @override
  String get closeButton => 'बंद करा';

  @override
  String get familyAlerting => 'कुटुंबाला कळवत आहोत…';

  @override
  String get familyAlerted => 'तुमच्या कुटुंबाला कळवलं आहे.';

  @override
  String get familyNoGuardian =>
      'तुमच्या सर्कलमध्ये अजून उत्तर देणारा (रक्षक) कोणी नाही. कुटुंबातील एखाद्या सदस्याला रक्षक म्हणून जोडा.';

  @override
  String get familyAddToGetHelp => 'मदत मिळवण्यासाठी कुटुंबाला जोडा.';

  @override
  String familyReplied(String name, String reply) {
    return '$name यांचं उत्तर: $reply';
  }

  @override
  String get viewReply => 'उत्तर पाहा';

  @override
  String get openRequestsTitle => 'कुटुंबाचे प्रश्न';

  @override
  String get noOpenRequests =>
      'सध्या कोणताही प्रश्न बाकी नाही. कोणाला मदत हवी असेल तर तुम्हाला सूचना मिळेल.';

  @override
  String get memberStatusTitle => 'कुटुंबाची स्थिती';

  @override
  String get channelAlertsName => 'कुटुंबाच्या सूचना';

  @override
  String get channelAlertsDescription =>
      'कुटुंब मदत मागतं किंवा तुम्हाला उत्तर देतं तेव्हा';

  @override
  String get channelGeneralName => 'सामान्य';

  @override
  String get sosButton => 'मला आत्ता मदत हवी आहे';

  @override
  String get sosHoldHint => '2 सेकंद दाबून ठेवा';

  @override
  String get sosSending => 'SOS पाठवत आहोत…';

  @override
  String get sosAlerted => 'तुमच्या कुटुंबाला कळवलं आहे';

  @override
  String get sosNoGuardian =>
      'कुटुंब सर्कलमधील कोणालाही कळवता आलं नाही. कृपया आत्ता एखाद्या विश्वासू व्यक्तीला फोन करा.';

  @override
  String sosCallGuardian(String name) {
    return '$name यांना फोन करा';
  }

  @override
  String get sosCall1930 => '1930 वर फोन करा – सायबर क्राइम हेल्पलाइन';

  @override
  String get sos1930Explain =>
      'पैसे गेले असतील किंवा तुम्ही बँकेची माहिती किंवा OTP सांगितला असेल, तर 1930 वर फोन करा. लवकर फोन केल्यास पैसे थांबवता येऊ शकतात.';

  @override
  String get sosLimit =>
      'तुम्ही गेल्या तासाभरात 5 वेळा SOS पाठवलं आहे. कृपया थेट कुटुंबाला फोन करा.';

  @override
  String get sosFailed => 'SOS पाठवता आलं नाही. कृपया थेट कुटुंबाला फोन करा.';

  @override
  String sosAlertTitle(String name) {
    return '$name यांना आत्ता मदत हवी आहे';
  }

  @override
  String sosAlertBody(String name) {
    return '$name यांनी SOS बटण दाबलं आहे. कृपया लगेच त्यांना फोन करा.';
  }

  @override
  String get callButton => 'फोन करा';

  @override
  String get checkinTitle => 'रोजचं \"मी ठीक आहे\"';

  @override
  String get checkinExplain =>
      'रोज या वेळी आम्ही तुम्हाला आठवण करून देऊ की कुटुंबाला तुम्ही ठीक आहात हे कळवा. तुम्ही नाही कळवलं, तर त्यांना एक साधी सूचना जाईल.';

  @override
  String get checkinEnabled => 'रोजची हजेरी';

  @override
  String get checkinTime => 'आठवणीची वेळ';

  @override
  String get checkinAlertAfter =>
      'इतक्या वेळानंतरही कळवलं नाही तर कुटुंबाला सूचना';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तास',
      one: '1 तास',
    );
    return '$_temp0';
  }

  @override
  String get checkinChangeNote =>
      'कुटुंबाला सूचना देण्यातले बदल उद्यापासून लागू होतील.';

  @override
  String get saveButton => 'सेव्ह करा';

  @override
  String get saved => 'सेव्ह झालं';

  @override
  String get checkinReminderMorning =>
      'सुप्रभात! तुम्ही ठीक आहात हे कुटुंबाला कळवण्यासाठी दाबा 👍';

  @override
  String get checkinReminderOther =>
      'नमस्कार! तुम्ही ठीक आहात हे कुटुंबाला कळवण्यासाठी दाबा 👍';

  @override
  String get checkinThanks =>
      'धन्यवाद! तुम्ही आज ठीक आहात हे तुमच्या कुटुंबाला कळलं आहे.';

  @override
  String statusOkAt(String time) {
    return 'आज $time वाजता: ठीक आहेत';
  }

  @override
  String get statusNotYet => 'आज अजून नाही';

  @override
  String get statusMissed => 'आजची हजेरी चुकली';

  @override
  String get statusOff => 'रोजची हजेरी बंद आहे';

  @override
  String get batteryGuideTitle =>
      'सूचना तुमच्यापर्यंत पोहोचतील याची खात्री करा';

  @override
  String get batteryGuideIntro =>
      'काही फोन बॅटरी वाचवण्यासाठी ॲप्स बंद करतात. मग कुटुंबाच्या सूचना उशिरा येतात किंवा येतच नाहीत. कृपया या 2 सोप्या गोष्टी करा:';

  @override
  String get batteryStepNotifications => '1. PauseAsk साठी नोटिफिकेशन सुरू करा';

  @override
  String get batteryStepBattery =>
      '2. PauseAsk साठी बॅटरी \"कोणतेही निर्बंध नाहीत\" / \"ऑप्टिमाइझ करू नका\" वर ठेवा';

  @override
  String get batteryStepAutostart =>
      'काही फोनमध्ये ॲप सेटिंग्जमध्ये PauseAsk साठी \"ऑटोस्टार्ट\" सुद्धा सुरू करा.';

  @override
  String get openNotificationSettings => 'नोटिफिकेशन सेटिंग्ज उघडा';

  @override
  String get openBatterySettings => 'बॅटरी सेटिंग्ज उघडा';

  @override
  String get openAppSettings => 'ॲप सेटिंग्ज उघडा';

  @override
  String get notificationHelp => 'नोटिफिकेशन मदत';

  @override
  String get historyTitleMine => 'माझ्या तपासण्या';

  @override
  String get historyTitleFamily => 'कुटुंबाच्या तपासण्या';

  @override
  String get historyAutoDelete => 'तपासण्या 30 दिवसांनी आपोआप हटवल्या जातात.';

  @override
  String get historyEmptyTitle => 'अजून एकही तपासणी नाही';

  @override
  String get historyEmptyBody =>
      'एखादा मेसेज खटकला की \"थांबा आणि विचारा\" दाबा. तुमच्या तपासण्या इथे दिसतील.';

  @override
  String get historyEmptyFamily =>
      'कुटुंबाकडून अजून एकही तपासणी नाही. कोणी विचारलं की तुम्हाला सूचना मिळेल.';

  @override
  String get deleteButton => 'हटवा';

  @override
  String get deleteCheckConfirm => 'ही तपासणी हटवायची?';

  @override
  String get deleteCheckBody =>
      'ती तुमच्यासाठी आणि तुमच्या कुटुंबासाठीही हटवली जाईल.';

  @override
  String get deletedMessage => 'हटवली';

  @override
  String get noReplyYet => 'अजून उत्तर आलं नाही';

  @override
  String get checkDetailTitle => 'तपासणीचा तपशील';

  @override
  String get replyButton => 'उत्तर द्या';

  @override
  String get feedCardTitle => 'आजचा फसवणूक इशारा';

  @override
  String get seeAll => 'सर्व पाहा';

  @override
  String get feedTitle => 'फसवणूक इशारे';

  @override
  String get feedEmpty => 'सध्या कोणताही इशारा नाही. लवकरच पुन्हा पाहा.';

  @override
  String get shareAlert => 'हा इशारा शेअर करा';

  @override
  String sharePromo(String link) {
    return 'PauseAsk ने तुमच्या कुटुंबाचं रक्षण करा: $link';
  }

  @override
  String get readMore => 'आणखी वाचा';

  @override
  String get showLess => 'कमी दाखवा';

  @override
  String greetingMorning(String name) {
    return 'सुप्रभात, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'शुभ संध्याकाळ, $name';
  }

  @override
  String checkinDoneToday(String time) {
    return 'तुम्ही आज ठीक आहात हे कुटुंबाला कळलं आहे ($time)';
  }

  @override
  String get checkinNotYetToday => 'आज तुम्ही ठीक आहात हे कुटुंबाला कळवा';

  @override
  String get imOkButton => 'मी ठीक आहे 👍';

  @override
  String get settingsGeneral => 'सामान्य';

  @override
  String get settingsFamily => 'कुटुंब आणि सूचना';

  @override
  String get settingsHelp => 'मदत आणि नियम';

  @override
  String get settingsAccount => 'खातं';

  @override
  String get rolesTitle => 'माझी भूमिका';

  @override
  String get rolesSaved => 'भूमिका बदलली';

  @override
  String get testAlert => 'मला एक चाचणी सूचना पाठवा';

  @override
  String get testAlertSent => 'चाचणी सूचना पाठवली. काही सेकंदांत यायला हवी.';

  @override
  String get testAlertNoDevice =>
      'हा फोन अजून सूचनांसाठी तयार नाही. नोटिफिकेशनची परवानगी द्या, मग PauseAsk बंद करून पुन्हा उघडा.';

  @override
  String get privacyPolicy => 'गोपनीयता धोरण';

  @override
  String get termsTitle => 'वापराच्या अटी';

  @override
  String get helpFaq => 'मदत आणि प्रश्नोत्तरे';

  @override
  String get contactSupport => 'मदतीसाठी संपर्क करा';

  @override
  String noEmailApp(String email) {
    return 'ईमेल ॲप सापडलं नाही. कृपया $email वर लिहा.';
  }

  @override
  String appVersion(String version) {
    return 'आवृत्ती $version';
  }

  @override
  String get readFullOnline => 'पूर्ण आवृत्ती ऑनलाइन वाचा';

  @override
  String get deleteAccount => 'खातं हटवा';

  @override
  String get deleteAccountIntro => 'यामुळे कायमचं हटवलं जाईल:';

  @override
  String get deleteItemProfile => 'तुमची प्रोफाइल: नाव, फोन नंबर आणि सेटिंग्ज';

  @override
  String get deleteItemChecks => 'तुमच्या सर्व तपासण्या आणि त्यांचे निकाल';

  @override
  String get deleteItemCheckins => 'रोजची हजेरी आणि SOS ची माहिती';

  @override
  String get deleteItemCircle =>
      'कुटुंब सर्कलमधील तुमची जागा. सर्कल तुम्ही तयार केलं असेल, तर सर्वात आधी सामील झालेला सदस्य त्याचा प्रमुख होईल.';

  @override
  String get deleteItemLogin => 'तुमचं लॉग इन';

  @override
  String get deleteKeptNote =>
      'तुम्ही कुटुंबाला दिलेली उत्तरं त्यांच्या तपासण्यांमध्ये राहतील, पण तुमच्या नावाशिवाय.';

  @override
  String get deleteTypeHint => 'खात्री करण्यासाठी DELETE लिहा';

  @override
  String get deleteForever => 'माझं खातं हटवा';

  @override
  String get deleteFailed =>
      'आत्ता खातं हटवता आलं नाही. इंटरनेट तपासून पुन्हा प्रयत्न करा.';

  @override
  String get errorScreenTitle => 'काहीतरी चुकलं';

  @override
  String get errorScreenBody =>
      'माफ करा, PauseAsk च्या या भागात अडचण आली. तुमच्या माहितीवर काहीही परिणाम झालेला नाही. कृपया मागे जाऊन पुन्हा प्रयत्न करा.';

  @override
  String get goHome => 'होमवर जा';
}
