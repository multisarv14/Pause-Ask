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
  String homeGreeting(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String get homeProtectedText =>
      'एखादा मेसेज खटकला तर थांबा आणि इथे तपासा. तुमच्या कुटुंबाला लगेच कळवलं जाईल.';

  @override
  String get homeGuardianText =>
      'कुटुंबातील कोणाला एखाद्या मेसेजबद्दल मदत हवी असेल, तेव्हा तुम्हाला सूचना मिळेल.';

  @override
  String get homeBothText =>
      'स्वतःचे मेसेज तपासा आणि कुटुंबाने विचारल्यावर त्यांना मदत करा.';

  @override
  String get homeComingSoon => 'आणखी सुविधा लवकरच येत आहेत.';

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
}
