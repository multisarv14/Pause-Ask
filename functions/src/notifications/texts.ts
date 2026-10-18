/**
 * Push texts in the *receiver's* language. They contain names and the risk
 * level only, never message text (pushes show on the lock screen).
 */

type Lang = "en" | "hi" | "mr";
export type ResponseType = "STOP" | "OK" | "CALL";

const lang = (l: string): Lang => (l === "hi" || l === "mr" ? l : "en");

const RISK: Record<Lang, Record<string, string>> = {
  en: { HIGH: "High risk", SUSPICIOUS: "Suspicious", BE_CAREFUL: "Be careful" },
  hi: { HIGH: "बहुत ज़्यादा खतरा", SUSPICIOUS: "संदिग्ध", BE_CAREFUL: "सावधान रहें" },
  mr: { HIGH: "मोठा धोका", SUSPICIOUS: "संशयास्पद", BE_CAREFUL: "सावध राहा" },
};

export function checkAlertText(language: string, name: string, riskLevel: string) {
  const l = lang(language);
  const risk = RISK[l][riskLevel] ?? RISK[l].BE_CAREFUL;
  return {
    en: { title: `${name} needs your help`, body: `${risk}: a suspicious message. Tap to reply.` },
    hi: { title: `${name} को आपकी मदद चाहिए`, body: `${risk}: एक शक वाला मैसेज। जवाब देने के लिए दबाएँ।` },
    mr: { title: `${name} यांना तुमची मदत हवी आहे`, body: `${risk}: एक संशयास्पद मेसेज. उत्तर देण्यासाठी दाबा.` },
  }[l];
}

export function responseText(language: string, type: ResponseType, by: string) {
  const l = lang(language);
  const texts = {
    STOP: {
      en: { title: "STOP – don't do anything", body: `${by} will call you.` },
      hi: { title: "रुकिए – अभी कुछ न करें", body: `${by} आपको फ़ोन करेंगे।` },
      mr: { title: "थांबा – आत्ता काहीही करू नका", body: `${by} तुम्हाला फोन करतील.` },
    },
    OK: {
      en: { title: `${by} checked: it's OK`, body: "Tap to see the details." },
      hi: { title: `${by} ने जाँच लिया: ठीक है`, body: "पूरी जानकारी के लिए दबाएँ।" },
      mr: { title: `${by} यांनी तपासलं: ठीक आहे`, body: "सविस्तर पाहण्यासाठी दाबा." },
    },
    CALL: {
      en: { title: `${by} is calling you now`, body: "Please pick up the phone." },
      hi: { title: `${by} अभी आपको फ़ोन कर रहे हैं`, body: "कृपया फ़ोन उठाइए।" },
      mr: { title: `${by} आत्ता तुम्हाला फोन करत आहेत`, body: "कृपया फोन उचला." },
    },
  };
  return texts[type][l];
}

export function sosText(language: string, name: string) {
  const l = lang(language);
  return {
    en: { title: `🆘 ${name} needs help now`, body: "Please call them right away." },
    hi: { title: `🆘 ${name} को अभी मदद चाहिए`, body: "कृपया तुरंत उन्हें फ़ोन करें।" },
    mr: { title: `🆘 ${name} यांना आत्ता मदत हवी आहे`, body: "कृपया लगेच त्यांना फोन करा." },
  }[l];
}

export function missedCheckinText(language: string, name: string) {
  const l = lang(language);
  return {
    en: { title: `${name} hasn't checked in today`, body: "Maybe give them a call." },
    hi: { title: `${name} ने आज "मैं ठीक हूँ" नहीं बताया`, body: "हो सके तो उन्हें एक फ़ोन कर लीजिए।" },
    mr: { title: `${name} यांनी आज "मी ठीक आहे" कळवलं नाही`, body: "जमल्यास त्यांना एक फोन करा." },
  }[l];
}

/** Feed push: the alert title is already in the receiver's language. */
export function newFeedItemText(language: string, title: string) {
  const l = lang(language);
  return {
    en: { title: "⚠️ New scam alert", body: title },
    hi: { title: "⚠️ नया स्कैम अलर्ट", body: title },
    mr: { title: "⚠️ नवीन फसवणूक इशारा", body: title },
  }[l];
}

export function testAlertText(language: string) {
  const l = lang(language);
  return {
    en: { title: "PauseAsk test alert ✅", body: "Notifications are working. Family alerts will look like this." },
    hi: { title: "PauseAsk टेस्ट अलर्ट ✅", body: "नोटिफ़िकेशन ठीक चल रहे हैं। परिवार के अलर्ट ऐसे ही दिखेंगे।" },
    mr: { title: "PauseAsk चाचणी सूचना ✅", body: "नोटिफिकेशन व्यवस्थित चालू आहेत. कुटुंबाच्या सूचना अशाच दिसतील." },
  }[l];
}

export function answeredInfoText(language: string, by: string, name: string) {
  const l = lang(language);
  return {
    en: { title: `${by} replied to ${name}`, body: "No need to reply." },
    hi: { title: `${by} ने ${name} को जवाब दे दिया`, body: "आपको जवाब देने की ज़रूरत नहीं।" },
    mr: { title: `${by} यांनी ${name} यांना उत्तर दिलं`, body: "तुम्हाला उत्तर देण्याची गरज नाही." },
  }[l];
}
