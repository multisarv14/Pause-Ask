/// In-app privacy policy, terms and FAQ in plain language (en / hi / mr).
/// The full public versions live in /docs and on the website; keep both in
/// sync when anything changes. `{email}` and `{company}` are filled in at
/// display time.
library;

typedef LegalSection = ({String title, String body});

enum LegalDoc { privacy, terms, faq }

const Map<LegalDoc, Map<String, List<LegalSection>>> legalContent = {
  LegalDoc.privacy: {
    'en': [
      (
        title: 'In short',
        body: 'PauseAsk never reads your SMS, WhatsApp, contacts or photos on its own. We only see a message when you share, paste, type or speak it into the app. There are no ads and no third-party tracking.',
      ),
      (
        title: 'What we keep',
        body: 'Your name and phone number (to sign in), your role, language and settings, your family circle, the messages you check (with phone numbers, OTPs, account numbers, UPI IDs and emails hidden), the AI result, your family\'s reply, and your daily "I\'m OK" times.',
      ),
      (
        title: 'Pictures and voice',
        body: 'Screenshots are read on your phone and voice is turned into text on your phone. Only the text is sent. The picture and the recording never leave your phone.',
      ),
      (
        title: 'The AI check',
        body: 'The text (with private details hidden) is sent to our server in India (Google Cloud, Mumbai) and then to an AI service (Google Gemini, paid service) only to get the risk result. The AI can be wrong. It never says a message is "safe". Only your family can say it is OK.',
      ),
      (
        title: 'Who can see it',
        body: 'Members of your family circle can see your name, phone number, your checks, results, replies and your daily check-in status. Nobody else can. We never sell your data.',
      ),
      (
        title: 'How long',
        body: 'Checks are deleted automatically after 30 days. Your profile stays until you delete your account.',
      ),
      (
        title: 'Your rights (DPDP Act 2023)',
        body: 'You can ask to see your data, correct it, or delete it. You can delete everything yourself: Settings → Delete account. You can also complain to us, and to the Data Protection Board of India.',
      ),
      (
        title: 'Contact / grievance officer',
        body: '{company}. Email: {email}. We reply within 7 days.',
      ),
    ],
    'hi': [
      (
        title: 'संक्षेप में',
        body: 'PauseAsk अपने-आप कभी आपके SMS, WhatsApp, कॉन्टैक्ट या फ़ोटो नहीं पढ़ता। हम कोई मैसेज सिर्फ़ तभी देखते हैं जब आप खुद उसे ऐप में शेयर, पेस्ट, टाइप करते या बोलते हैं। कोई विज्ञापन नहीं, कोई बाहरी ट्रैकिंग नहीं।',
      ),
      (
        title: 'हम क्या रखते हैं',
        body: 'आपका नाम और फ़ोन नंबर (लॉग इन के लिए), आपकी भूमिका, भाषा और सेटिंग्स, आपका परिवार सर्कल, आपके जाँचे गए मैसेज (फ़ोन नंबर, OTP, खाता नंबर, UPI ID और ईमेल छिपाकर), AI का नतीजा, परिवार का जवाब, और रोज़ के "मैं ठीक हूँ" का समय।',
      ),
      (
        title: 'तस्वीर और आवाज़',
        body: 'स्क्रीनशॉट आपके फ़ोन में ही पढ़ा जाता है और आवाज़ भी फ़ोन में ही टेक्स्ट बनती है। सिर्फ़ टेक्स्ट भेजा जाता है। तस्वीर और रिकॉर्डिंग कभी आपके फ़ोन से बाहर नहीं जाती।',
      ),
      (
        title: 'AI जाँच',
        body: 'टेक्स्ट (निजी जानकारी छिपाकर) भारत में हमारे सर्वर (Google Cloud, मुंबई) पर और फिर सिर्फ़ खतरे का नतीजा पाने के लिए एक AI सेवा (Google Gemini, पेड सेवा) को भेजा जाता है। AI से भी गलती हो सकती है। यह कभी नहीं कहता कि मैसेज "सुरक्षित" है। ठीक है या नहीं, यह सिर्फ़ आपका परिवार बता सकता है।',
      ),
      (
        title: 'कौन देख सकता है',
        body: 'आपके परिवार सर्कल के सदस्य आपका नाम, फ़ोन नंबर, आपकी जाँचें, नतीजे, जवाब और रोज़ की हाज़िरी देख सकते हैं। और कोई नहीं। हम आपका डेटा कभी नहीं बेचते।',
      ),
      (
        title: 'कितने समय तक',
        body: 'जाँचें 30 दिन बाद अपने-आप मिट जाती हैं। आपकी प्रोफ़ाइल तब तक रहती है जब तक आप अकाउंट नहीं मिटाते।',
      ),
      (
        title: 'आपके अधिकार (DPDP कानून 2023)',
        body: 'आप अपना डेटा देखने, सुधारने या मिटाने को कह सकते हैं। आप खुद सब कुछ मिटा सकते हैं: सेटिंग्स → अकाउंट मिटाएँ। आप हमसे और भारत के डेटा प्रोटेक्शन बोर्ड से शिकायत भी कर सकते हैं।',
      ),
      (
        title: 'संपर्क / शिकायत अधिकारी',
        body: '{company}. ईमेल: {email}. हम 7 दिन के अंदर जवाब देते हैं।',
      ),
    ],
    'mr': [
      (
        title: 'थोडक्यात',
        body: 'PauseAsk स्वतःहून कधीही तुमचे SMS, WhatsApp, संपर्क किंवा फोटो वाचत नाही. तुम्ही स्वतः ॲपमध्ये मेसेज शेअर, पेस्ट, टाइप केला किंवा बोललात तरच आम्हाला तो दिसतो. कोणत्याही जाहिराती नाहीत, बाहेरचं ट्रॅकिंग नाही.',
      ),
      (
        title: 'आम्ही काय ठेवतो',
        body: 'तुमचं नाव आणि फोन नंबर (लॉग इनसाठी), तुमची भूमिका, भाषा आणि सेटिंग्ज, तुमचं कुटुंब सर्कल, तुम्ही तपासलेले मेसेज (फोन नंबर, OTP, खाते क्रमांक, UPI ID आणि ईमेल लपवून), AI चा निकाल, कुटुंबाचं उत्तर, आणि रोजच्या "मी ठीक आहे" ची वेळ.',
      ),
      (
        title: 'चित्र आणि आवाज',
        body: 'स्क्रीनशॉट तुमच्या फोनवरच वाचला जातो आणि आवाजाचंही फोनवरच मजकुरात रूपांतर होतं. फक्त मजकूर पाठवला जातो. चित्र आणि रेकॉर्डिंग कधीही तुमच्या फोनबाहेर जात नाही.',
      ),
      (
        title: 'AI तपासणी',
        body: 'मजकूर (खासगी माहिती लपवून) भारतातील आमच्या सर्व्हरवर (Google Cloud, मुंबई) आणि मग फक्त धोक्याचा निकाल मिळवण्यासाठी एका AI सेवेला (Google Gemini, सशुल्क सेवा) पाठवला जातो. AI सुद्धा चुकू शकतो. तो कधीच मेसेज "सुरक्षित" आहे असं सांगत नाही. ठीक आहे की नाही, हे फक्त तुमचं कुटुंब सांगू शकतं.',
      ),
      (
        title: 'कोण पाहू शकतं',
        body: 'तुमच्या कुटुंब सर्कलमधील सदस्य तुमचं नाव, फोन नंबर, तुमच्या तपासण्या, निकाल, उत्तरं आणि रोजची हजेरी पाहू शकतात. इतर कोणीही नाही. आम्ही तुमचा डेटा कधीही विकत नाही.',
      ),
      (
        title: 'किती काळ',
        body: 'तपासण्या 30 दिवसांनी आपोआप हटवल्या जातात. तुम्ही खातं हटवेपर्यंत तुमची प्रोफाइल राहते.',
      ),
      (
        title: 'तुमचे हक्क (DPDP कायदा 2023)',
        body: 'तुम्ही तुमचा डेटा पाहणं, दुरुस्त करणं किंवा हटवणं मागू शकता. सगळं तुम्ही स्वतः हटवू शकता: सेटिंग्ज → खातं हटवा. तुम्ही आमच्याकडे आणि भारताच्या डेटा प्रोटेक्शन बोर्डाकडे तक्रारही करू शकता.',
      ),
      (
        title: 'संपर्क / तक्रार अधिकारी',
        body: '{company}. ईमेल: {email}. आम्ही 7 दिवसांत उत्तर देतो.',
      ),
    ],
  },
  LegalDoc.terms: {
    'en': [
      (
        title: 'What PauseAsk is',
        body: 'A helper to pause before acting on a suspicious message and ask your family with one tap. It also has SOS, a daily "I\'m OK" and scam alerts.',
      ),
      (
        title: 'No guarantee',
        body: 'PauseAsk cannot catch every scam, and the AI can be wrong in both directions. It never says a message is safe. Always verify with a number you already know, never one from the message.',
      ),
      (
        title: 'Not a replacement for help',
        body: 'PauseAsk does not replace the police, your bank or emergency services. If money was taken or you shared bank details, call 1930 (Cyber Crime Helpline) and your bank at once. In an emergency call 112.',
      ),
      (
        title: 'Your part',
        body: 'Use your real name and number, keep your phone locked, and only add people you trust to your circle: they will see your checks.',
      ),
      (
        title: 'Free, with fair limits',
        body: 'PauseAsk is free. Limits: 10 AI checks a day, 1 circle with up to 5 people, 5 SOS an hour.',
      ),
      (
        title: 'Notifications',
        body: 'Alerts depend on your phone, network and battery settings, so we can\'t promise every alert arrives on time.',
      ),
      (
        title: 'Responsibility',
        body: 'As far as Indian law allows, {company} is not responsible for losses from scams or from acting on a result. Indian law applies. Contact: {email}.',
      ),
    ],
    'hi': [
      (
        title: 'PauseAsk क्या है',
        body: 'किसी शक वाले मैसेज पर कुछ करने से पहले रुकने और एक टैप में परिवार से पूछने का मददगार। इसमें SOS, रोज़ का "मैं ठीक हूँ" और स्कैम अलर्ट भी हैं।',
      ),
      (
        title: 'कोई गारंटी नहीं',
        body: 'PauseAsk हर स्कैम नहीं पकड़ सकता, और AI दोनों तरफ़ गलती कर सकता है। यह कभी नहीं कहता कि मैसेज सुरक्षित है। हमेशा उस नंबर से जाँचें जो आप पहले से जानते हैं, मैसेज में दिए नंबर से कभी नहीं।',
      ),
      (
        title: 'मदद की जगह नहीं',
        body: 'PauseAsk पुलिस, बैंक या इमरजेंसी सेवा की जगह नहीं लेता। अगर पैसे कट गए हैं या बैंक की जानकारी बता दी है, तो तुरंत 1930 (साइबर क्राइम हेल्पलाइन) और अपने बैंक को फ़ोन करें। इमरजेंसी में 112 पर फ़ोन करें।',
      ),
      (
        title: 'आपकी ज़िम्मेदारी',
        body: 'अपना असली नाम और नंबर इस्तेमाल करें, फ़ोन लॉक रखें, और सर्कल में सिर्फ़ भरोसेमंद लोगों को जोड़ें: वे आपकी जाँचें देखेंगे।',
      ),
      (
        title: 'मुफ़्त, सही सीमाओं के साथ',
        body: 'PauseAsk मुफ़्त है। सीमाएँ: रोज़ 10 AI जाँचें, 1 सर्कल में 5 लोग तक, घंटे में 5 SOS।',
      ),
      (
        title: 'नोटिफ़िकेशन',
        body: 'अलर्ट आपके फ़ोन, नेटवर्क और बैटरी सेटिंग्स पर निर्भर करते हैं, इसलिए हम हर अलर्ट के समय पर पहुँचने का वादा नहीं कर सकते।',
      ),
      (
        title: 'ज़िम्मेदारी',
        body: 'जहाँ तक भारतीय कानून अनुमति देता है, स्कैम से या किसी नतीजे पर कदम उठाने से हुए नुकसान के लिए {company} ज़िम्मेदार नहीं है। भारतीय कानून लागू होता है। संपर्क: {email}.',
      ),
    ],
    'mr': [
      (
        title: 'PauseAsk म्हणजे काय',
        body: 'संशयास्पद मेसेजवर काही करण्याआधी थांबण्यासाठी आणि एका टॅपमध्ये कुटुंबाला विचारण्यासाठी मदतनीस. यात SOS, रोजचं "मी ठीक आहे" आणि फसवणुकीचे इशारेही आहेत.',
      ),
      (
        title: 'कोणतीही हमी नाही',
        body: 'PauseAsk प्रत्येक फसवणूक ओळखू शकत नाही, आणि AI दोन्ही बाजूंनी चुकू शकतो. तो कधीच मेसेज सुरक्षित आहे असं सांगत नाही. नेहमी ओळखीच्या नंबरवरून खात्री करा, मेसेजमधल्या नंबरवरून कधीच नाही.',
      ),
      (
        title: 'मदतीचा पर्याय नाही',
        body: 'PauseAsk पोलीस, बँक किंवा आपत्कालीन सेवेची जागा घेत नाही. पैसे गेले असतील किंवा बँकेची माहिती सांगितली असेल, तर लगेच 1930 (सायबर क्राइम हेल्पलाइन) आणि तुमच्या बँकेला फोन करा. आपत्कालीन परिस्थितीत 112 वर फोन करा.',
      ),
      (
        title: 'तुमची जबाबदारी',
        body: 'तुमचं खरं नाव आणि नंबर वापरा, फोन लॉक ठेवा, आणि सर्कलमध्ये फक्त विश्वासू लोकांनाच जोडा: ते तुमच्या तपासण्या पाहतील.',
      ),
      (
        title: 'मोफत, योग्य मर्यादांसह',
        body: 'PauseAsk मोफत आहे. मर्यादा: दिवसाला 10 AI तपासण्या, 1 सर्कलमध्ये 5 जणांपर्यंत, तासाला 5 SOS.',
      ),
      (
        title: 'नोटिफिकेशन',
        body: 'सूचना तुमचा फोन, नेटवर्क आणि बॅटरी सेटिंग्जवर अवलंबून असतात, त्यामुळे प्रत्येक सूचना वेळेवर पोहोचेल याची हमी आम्ही देऊ शकत नाही.',
      ),
      (
        title: 'जबाबदारी',
        body: 'भारतीय कायद्याने परवानगी दिलेल्या मर्यादेपर्यंत, फसवणुकीमुळे किंवा एखाद्या निकालावर कृती केल्यामुळे झालेल्या नुकसानीसाठी {company} जबाबदार नाही. भारतीय कायदा लागू होतो. संपर्क: {email}.',
      ),
    ],
  },
  LegalDoc.faq: {
    'en': [
      (
        title: 'What does PauseAsk do?',
        body: 'When a message worries you, PauseAsk explains the risk in simple words and alerts your family, who can reply "STOP", "It\'s OK" or call you, all in one tap.',
      ),
      (
        title: 'Does it read my SMS?',
        body: 'No. PauseAsk never reads your messages on its own. It only sees what you share, paste, type or say into it.',
      ),
      (
        title: 'Who can see my checks?',
        body: 'Only the people in your family circle. Phone numbers, OTPs and account numbers are hidden. Checks are deleted after 30 days.',
      ),
      (
        title: 'How do I add family?',
        body: 'Home → My family circle → Create a circle → Invite family. Send the 6-letter code on WhatsApp. Your family installs PauseAsk and taps "Join with code".',
      ),
      (
        title: 'What if my family doesn\'t reply?',
        body: 'Don\'t act on the message. Don\'t send money or share an OTP. Call a family member yourself. If money was taken, call 1930 and your bank at once.',
      ),
      (
        title: 'Is it free?',
        body: 'Yes. You can do 10 checks a day, and have 1 circle with up to 5 people.',
      ),
      (
        title: 'What languages?',
        body: 'English, Hindi and Marathi. Change it any time in Settings → Change language.',
      ),
      (
        title: 'How do I delete my data?',
        body: 'Settings → Delete account. Everything about you is deleted right away. Checks are also deleted automatically after 30 days.',
      ),
    ],
    'hi': [
      (
        title: 'PauseAsk क्या करता है?',
        body: 'जब कोई मैसेज परेशान करे, PauseAsk आसान शब्दों में खतरा समझाता है और आपके परिवार को अलर्ट भेजता है, जो एक टैप में "रुकिए", "ठीक है" कह सकते हैं या आपको फ़ोन कर सकते हैं।',
      ),
      (
        title: 'क्या यह मेरे SMS पढ़ता है?',
        body: 'नहीं। PauseAsk अपने-आप कभी आपके मैसेज नहीं पढ़ता। यह सिर्फ़ वही देखता है जो आप शेयर, पेस्ट, टाइप करते या बोलते हैं।',
      ),
      (
        title: 'मेरी जाँचें कौन देख सकता है?',
        body: 'सिर्फ़ आपके परिवार सर्कल के लोग। फ़ोन नंबर, OTP और खाता नंबर छिपे रहते हैं। जाँचें 30 दिन बाद मिट जाती हैं।',
      ),
      (
        title: 'परिवार को कैसे जोड़ें?',
        body: 'होम → मेरा परिवार सर्कल → सर्कल बनाएँ → परिवार को बुलाएँ। 6 अक्षरों का कोड WhatsApp पर भेजें। परिवार PauseAsk इंस्टॉल करके "कोड से जुड़ें" दबाए।',
      ),
      (
        title: 'अगर परिवार जवाब न दे तो?',
        body: 'मैसेज पर कुछ न करें। न पैसे भेजें, न OTP बताएँ। खुद परिवार के किसी सदस्य को फ़ोन करें। पैसे कट गए हों तो तुरंत 1930 और अपने बैंक को फ़ोन करें।',
      ),
      (
        title: 'क्या यह मुफ़्त है?',
        body: 'हाँ। आप रोज़ 10 जाँचें कर सकते हैं, और 5 लोगों तक का 1 सर्कल बना सकते हैं।',
      ),
      (
        title: 'कौन-सी भाषाएँ?',
        body: 'अंग्रेज़ी, हिंदी और मराठी। सेटिंग्स → भाषा बदलें में कभी भी बदलें।',
      ),
      (
        title: 'अपना डेटा कैसे मिटाएँ?',
        body: 'सेटिंग्स → अकाउंट मिटाएँ। आपसे जुड़ा सब कुछ तुरंत मिट जाता है। जाँचें वैसे भी 30 दिन बाद अपने-आप मिट जाती हैं।',
      ),
    ],
    'mr': [
      (
        title: 'PauseAsk काय करतं?',
        body: 'एखादा मेसेज खटकला की PauseAsk सोप्या शब्दांत धोका समजावून सांगतं आणि तुमच्या कुटुंबाला सूचना पाठवतं. ते एका टॅपमध्ये "थांबा", "ठीक आहे" म्हणू शकतात किंवा तुम्हाला फोन करू शकतात.',
      ),
      (
        title: 'हे माझे SMS वाचतं का?',
        body: 'नाही. PauseAsk स्वतःहून कधीही तुमचे मेसेज वाचत नाही. तुम्ही जे शेअर, पेस्ट, टाइप करता किंवा बोलता, तेवढंच त्याला दिसतं.',
      ),
      (
        title: 'माझ्या तपासण्या कोण पाहू शकतं?',
        body: 'फक्त तुमच्या कुटुंब सर्कलमधील लोक. फोन नंबर, OTP आणि खाते क्रमांक लपवलेले असतात. तपासण्या 30 दिवसांनी हटवल्या जातात.',
      ),
      (
        title: 'कुटुंबाला कसं जोडायचं?',
        body: 'होम → माझं कुटुंब सर्कल → सर्कल तयार करा → कुटुंबाला बोलवा. 6 अक्षरी कोड WhatsApp वर पाठवा. कुटुंबाने PauseAsk इंस्टॉल करून "कोडने सामील व्हा" दाबावं.',
      ),
      (
        title: 'कुटुंबाने उत्तर दिलं नाही तर?',
        body: 'मेसेजवर काहीही करू नका. पैसे पाठवू नका, OTP सांगू नका. स्वतः कुटुंबातील कोणाला तरी फोन करा. पैसे गेले असतील तर लगेच 1930 आणि तुमच्या बँकेला फोन करा.',
      ),
      (
        title: 'हे मोफत आहे का?',
        body: 'हो. तुम्ही दिवसाला 10 तपासण्या करू शकता, आणि 5 जणांपर्यंतचं 1 सर्कल तयार करू शकता.',
      ),
      (
        title: 'कोणत्या भाषा?',
        body:
            'इंग्रजी, हिंदी आणि मराठी. सेटिंग्ज → भाषा बदला मध्ये कधीही बदला.',
      ),
      (
        title: 'माझा डेटा कसा हटवायचा?',
        body: 'सेटिंग्ज → खातं हटवा. तुमच्याशी संबंधित सगळं लगेच हटवलं जातं. तपासण्या तशाही 30 दिवसांनी आपोआप हटतात.',
      ),
    ],
  },
};
