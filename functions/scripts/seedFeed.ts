// Seeds 8 sample "Scam alert" feed items (en / hi / mr) into scamFeed.
// Fixed ids, so running it again updates the same 8 docs.
//
//   Emulator: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node scripts/seedFeed.ts demo-pauseask
//   Real project (after `gcloud auth application-default login`):
//             node scripts/seedFeed.ts <projectId>
//
// Needs Node 22.18+ (runs TypeScript directly). With older Node: npx tsx scripts/seedFeed.ts
import { initializeApp } from "firebase-admin/app";
import { Timestamp, getFirestore } from "firebase-admin/firestore";

type L = { en: string; hi: string; mr: string };
interface SeedItem {
  id: string;
  scamType: string;
  countryCodes: string[];
  title: L;
  body: L;
}

export const SEED_FEED: SeedItem[] = [
  {
    id: "seed-digital-arrest",
    scamType: "digital_arrest",
    countryCodes: ["IN"],
    title: {
      en: "Fake \"digital arrest\" video calls",
      hi: "नकली \"डिजिटल अरेस्ट\" वीडियो कॉल",
      mr: "खोटे \"डिजिटल अरेस्ट\" व्हिडिओ कॉल",
    },
    body: {
      en: "Callers pretending to be CBI, police or customs say your Aadhaar is linked to a crime and keep you on a video call for hours. Then they ask you to move money to a \"safe account\". Real police never arrest anyone on a video call or ask for money. Cut the call and tell your family.",
      hi: "खुद को CBI, पुलिस या कस्टम अधिकारी बताने वाले लोग कहते हैं कि आपका आधार किसी अपराध से जुड़ा है और घंटों वीडियो कॉल पर रोके रखते हैं। फिर \"सेफ़ अकाउंट\" में पैसे भेजने को कहते हैं। असली पुलिस कभी वीडियो कॉल पर गिरफ़्तार नहीं करती और न ही पैसे माँगती है। फ़ोन काटिए और परिवार को बताइए।",
      mr: "CBI, पोलीस किंवा कस्टम अधिकारी असल्याचं सांगून काही लोक म्हणतात की तुमचं आधार एखाद्या गुन्ह्याशी जोडलेलं आहे आणि तासन्‌तास व्हिडिओ कॉलवर थांबवून ठेवतात. मग \"सेफ अकाउंट\"मध्ये पैसे पाठवायला सांगतात. खरे पोलीस कधीही व्हिडिओ कॉलवर अटक करत नाहीत आणि पैसे मागत नाहीत. फोन ठेवा आणि कुटुंबाला सांगा.",
    },
  },
  {
    id: "seed-electricity-bill",
    scamType: "electricity_bill",
    countryCodes: ["IN"],
    title: {
      en: "\"Your electricity will be cut tonight\"",
      hi: "\"आज रात आपकी बिजली कट जाएगी\"",
      mr: "\"आज रात्री तुमची वीज कापली जाईल\"",
    },
    body: {
      en: "An SMS says your power will be disconnected tonight because the last bill was not updated, and gives a number to call. The \"officer\" then asks you to install an app or pay a small amount. Electricity boards don't send such messages from personal numbers. Check your bill only in the official app or at the office.",
      hi: "SMS आता है कि पिछला बिल अपडेट नहीं हुआ, इसलिए आज रात बिजली कट जाएगी, और एक नंबर पर फ़ोन करने को कहा जाता है। फिर वह \"अधिकारी\" कोई ऐप डाउनलोड करवाता है या थोड़े पैसे भरने को कहता है। बिजली विभाग ऐसे मैसेज निजी नंबरों से नहीं भेजता। बिल सिर्फ़ आधिकारिक ऐप या दफ़्तर में ही जाँचें।",
      mr: "मागचं बिल अपडेट झालं नाही म्हणून आज रात्री वीज कापली जाईल, असा SMS येतो आणि एका नंबरवर फोन करायला सांगतो. मग तो \"अधिकारी\" एखादं ॲप डाउनलोड करायला लावतो किंवा थोडे पैसे भरायला सांगतो. वीज कंपनी असे मेसेज खासगी नंबरवरून पाठवत नाही. बिल फक्त अधिकृत ॲपमध्ये किंवा ऑफिसमध्येच तपासा.",
    },
  },
  {
    id: "seed-kyc-update",
    scamType: "kyc_update",
    countryCodes: ["IN"],
    title: {
      en: "\"Your KYC has expired\" messages",
      hi: "\"आपका KYC खत्म हो गया है\" वाले मैसेज",
      mr: "\"तुमचं KYC संपलं आहे\" असे मेसेज",
    },
    body: {
      en: "Messages say your bank account or SIM will be blocked today unless you update KYC through a link. The link opens a fake bank page that steals your password and OTP. Banks never ask for KYC through SMS links. Visit your branch or use the bank's own app.",
      hi: "मैसेज आता है कि लिंक से KYC अपडेट नहीं किया तो आज ही आपका बैंक खाता या सिम बंद हो जाएगा। लिंक एक नकली बैंक पेज खोलता है जो आपका पासवर्ड और OTP चुरा लेता है। बैंक कभी SMS लिंक से KYC नहीं माँगते। अपनी ब्रांच जाएँ या बैंक का अपना ऐप इस्तेमाल करें।",
      mr: "लिंकवरून KYC अपडेट केलं नाही तर आजच तुमचं बँक खातं किंवा सिम बंद होईल, असा मेसेज येतो. ती लिंक एक खोटं बँक पेज उघडते आणि तुमचा पासवर्ड आणि OTP चोरते. बँका कधीही SMS लिंकवरून KYC मागत नाहीत. तुमच्या शाखेत जा किंवा बँकेचंच ॲप वापरा.",
    },
  },
  {
    id: "seed-courier-customs",
    scamType: "courier_customs",
    countryCodes: ["ALL"],
    title: {
      en: "A parcel in your name with \"drugs\"?",
      hi: "आपके नाम के पार्सल में \"ड्रग्स\"?",
      mr: "तुमच्या नावाच्या पार्सलमध्ये \"ड्रग्ज\"?",
    },
    body: {
      en: "A recorded call says a parcel in your name has drugs or fake passports, then connects you to a fake officer who demands money to \"clear your name\". No courier company or customs office settles cases over the phone. Hang up and call the courier's official number yourself.",
      hi: "रिकॉर्डेड कॉल आता है कि आपके नाम के पार्सल में ड्रग्स या नकली पासपोर्ट मिले हैं, फिर एक नकली अधिकारी से बात करवाई जाती है जो \"नाम साफ़ करने\" के लिए पैसे माँगता है। कोई कूरियर कंपनी या कस्टम विभाग फ़ोन पर मामले नहीं निपटाता। फ़ोन काटें और कूरियर के आधिकारिक नंबर पर खुद फ़ोन करें।",
      mr: "रेकॉर्ड केलेला कॉल येतो की तुमच्या नावाच्या पार्सलमध्ये ड्रग्ज किंवा खोटे पासपोर्ट सापडले आहेत, मग एका खोट्या अधिकाऱ्याशी बोलणं करून दिलं जातं जो \"नाव साफ करण्यासाठी\" पैसे मागतो. कोणतीही कुरिअर कंपनी किंवा कस्टम विभाग फोनवर प्रकरण मिटवत नाही. फोन ठेवा आणि कुरिअरच्या अधिकृत नंबरवर स्वतः फोन करा.",
    },
  },
  {
    id: "seed-task-job",
    scamType: "task_job",
    countryCodes: ["ALL"],
    title: {
      en: "\"Earn daily by liking videos\"",
      hi: "\"वीडियो लाइक करके रोज़ कमाई\"",
      mr: "\"व्हिडिओ लाइक करून रोज कमाई\"",
    },
    body: {
      en: "You're offered easy money for liking YouTube videos or rating hotels. The first payments are small and real, then you're asked to \"invest\" for bigger tasks and the money disappears. Real jobs never ask you to pay first. Leave the group and block the number.",
      hi: "YouTube वीडियो लाइक करने या होटल को रेटिंग देने के बदले आसान कमाई का ऑफ़र मिलता है। शुरू में थोड़े पैसे सच में मिलते हैं, फिर बड़े टास्क के लिए \"निवेश\" करवाया जाता है और पैसा गायब हो जाता है। असली नौकरी में पहले पैसे नहीं भरने पड़ते। ग्रुप छोड़ दें और नंबर ब्लॉक करें।",
      mr: "YouTube व्हिडिओ लाइक करणं किंवा हॉटेलला रेटिंग देणं यासाठी सोप्या कमाईची ऑफर येते. सुरुवातीला थोडे पैसे खरंच मिळतात, मग मोठ्या टास्कसाठी \"गुंतवणूक\" करायला लावतात आणि पैसे गायब होतात. खऱ्या नोकरीत आधी पैसे भरावे लागत नाहीत. ग्रुप सोडा आणि नंबर ब्लॉक करा.",
    },
  },
  {
    id: "seed-investment-group",
    scamType: "investment_group",
    countryCodes: ["ALL"],
    title: {
      en: "WhatsApp \"stock tips\" groups",
      hi: "WhatsApp पर \"शेयर टिप्स\" वाले ग्रुप",
      mr: "WhatsApp वर \"शेअर टिप्स\" देणारे ग्रुप",
    },
    body: {
      en: "You're added to a group where \"experts\" share stock tips and screenshots of huge profits. They ask you to trade through their own app. The profits you see are fake and you can't withdraw your money. Invest only through registered brokers you already know.",
      hi: "आपको एक ग्रुप में जोड़ा जाता है जहाँ \"एक्सपर्ट\" शेयर टिप्स और भारी मुनाफ़े के स्क्रीनशॉट दिखाते हैं। फिर अपने ही ऐप से ट्रेड करवाते हैं। ऐप में दिखने वाला मुनाफ़ा नकली होता है और पैसा निकाला नहीं जा सकता। निवेश सिर्फ़ पहले से जाने-पहचाने रजिस्टर्ड ब्रोकर से ही करें।",
      mr: "तुम्हाला एका ग्रुपमध्ये जोडलं जातं जिथे \"तज्ज्ञ\" शेअर टिप्स आणि मोठ्या नफ्याचे स्क्रीनशॉट दाखवतात. मग त्यांच्याच ॲपमधून ट्रेड करायला लावतात. ॲपमध्ये दिसणारा नफा खोटा असतो आणि पैसे काढता येत नाहीत. गुंतवणूक फक्त ओळखीच्या नोंदणीकृत ब्रोकरमार्फतच करा.",
    },
  },
  {
    id: "seed-hi-papa",
    scamType: "family_impersonation",
    countryCodes: ["ALL"],
    title: {
      en: "\"Hi Papa, this is my new number\"",
      hi: "\"पापा, ये मेरा नया नंबर है\"",
      mr: "\"बाबा, हा माझा नवीन नंबर आहे\"",
    },
    body: {
      en: "A message from an unknown number pretends to be your son or daughter: their phone broke and they urgently need money. Before paying, call your child on their old number, or ask a question only they would know.",
      hi: "अनजान नंबर से मैसेज आता है जैसे आपका बेटा या बेटी लिख रहे हों: फ़ोन टूट गया है और तुरंत पैसे चाहिए। पैसे भेजने से पहले बच्चे को उसके पुराने नंबर पर फ़ोन करें, या ऐसा सवाल पूछें जिसका जवाब सिर्फ़ वही जानता हो।",
      mr: "अनोळखी नंबरवरून मेसेज येतो, जणू तुमचा मुलगा किंवा मुलगी लिहित आहे: फोन तुटला आहे आणि लगेच पैसे हवे आहेत. पैसे पाठवण्याआधी मुलाला त्याच्या जुन्या नंबरवर फोन करा, किंवा असा प्रश्न विचारा ज्याचं उत्तर फक्त त्यालाच माहीत असेल.",
    },
  },
  {
    id: "seed-upi-refund",
    scamType: "upi_collect",
    countryCodes: ["IN"],
    title: {
      en: "\"Enter your UPI PIN to get a refund\"",
      hi: "\"रिफ़ंड पाने के लिए UPI PIN डालें\"",
      mr: "\"रिफंड मिळवण्यासाठी UPI PIN टाका\"",
    },
    body: {
      en: "Someone says they sent you money by mistake, or offers a refund or cashback, and sends a UPI request. Entering your PIN sends money OUT of your account — you never need a PIN to receive money. Decline the request and check with your bank.",
      hi: "कोई कहता है कि गलती से आपको पैसे भेज दिए, या रिफ़ंड/कैशबैक का ऑफ़र देता है, और UPI रिक्वेस्ट भेजता है। PIN डालते ही पैसा आपके खाते से चला जाता है — पैसे पाने के लिए कभी PIN नहीं लगता। रिक्वेस्ट मना करें और बैंक से पूछें।",
      mr: "कोणी म्हणतं की चुकून तुम्हाला पैसे पाठवले, किंवा रिफंड/कॅशबॅकची ऑफर देतं, आणि UPI रिक्वेस्ट पाठवतं. PIN टाकला की पैसे तुमच्या खात्यातून जातात — पैसे मिळवण्यासाठी कधीच PIN लागत नाही. रिक्वेस्ट नाकारा आणि बँकेकडे चौकशी करा.",
    },
  },
];

async function main() {
  const projectId = process.argv[2] ?? process.env.GCLOUD_PROJECT;
  if (!projectId) {
    console.error("Usage: node scripts/seedFeed.ts <projectId>");
    process.exit(1);
  }
  initializeApp({ projectId });
  const db = getFirestore();
  const now = Date.now();
  const batch = db.batch();
  SEED_FEED.forEach((item, i) => {
    const { id, ...rest } = item;
    batch.set(db.doc(`scamFeed/${id}`), {
      ...rest,
      active: true,
      // Newest first in the order above: one day apart.
      publishedAt: Timestamp.fromMillis(now - i * 86_400_000),
    });
  });
  await batch.commit();
  console.log(`Seeded ${SEED_FEED.length} feed items into ${projectId}` +
    (process.env.FIRESTORE_EMULATOR_HOST ? " (emulator)" : ""));
}

// Run only when executed directly (tests import SEED_FEED).
if (process.argv[1]?.endsWith("seedFeed.ts")) await main();
