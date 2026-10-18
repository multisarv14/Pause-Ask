# PauseAsk – Play Store release guide (v1.0.0+1)

Everything needed for Play Console, based on what the app **actually** does. Check each
answer again against the current Play Console wording when you fill it in; Google renames
fields from time to time.

## 1. App details

| Field | Value |
|---|---|
| App name (≤30) | **PauseAsk – Family Scam Check** |
| Package | `com.multisarv.pauseask` |
| Category | Tools (alternative: Lifestyle) |
| Contains ads | **No** |
| In-app purchases | No |
| Target audience | **18+** only |
| Privacy policy URL | `https://<projectId>.web.app/privacy` (after `firebase deploy --only hosting`) |
| Account deletion URL | `https://<projectId>.web.app/delete-account` |
| Support email | the email you set in `AppConstants.supportEmail` |
| Developer | Multisarv |

## 2. Store listing

**Short description (≤80):**
Family scam check: AI explains the risk, your family helps you decide.

### Full description – English

Got a message that worries you? Pause. Ask family. Stay safe.

PauseAsk helps older parents and anyone less sure about phones to stop before acting on a suspicious message, and to ask their family with one tap.

HOW IT WORKS
• Share a suspicious SMS or WhatsApp message to PauseAsk, pick a screenshot, or just say what happened.
• PauseAsk explains the risk in simple words: High risk, Suspicious or Be careful, with 3 clear steps on what to do now.
• Your family gets an instant alert and replies with one tap: "STOP – I'll call you", "I checked – it's OK" or "Call now".
• Their answer appears full-screen on your phone and can be read aloud.

MADE FOR FAMILIES
• Family circle of up to 5 people. Invite them with a 6-letter code on WhatsApp.
• SOS button: hold for 2 seconds to alert your whole family at once.
• Daily "I'm OK": one tap tells your family you're fine. If you forget, they get one gentle reminder.
• Scam alert of the day: real scams going around, in your language, easy to share.

PRIVACY FIRST
• PauseAsk never reads your SMS or WhatsApp. It only sees what you choose to share.
• Screenshots and voice stay on your phone; only the text is checked.
• Phone numbers, OTPs, account numbers and UPI IDs are hidden before checking.
• Checks are deleted automatically after 30 days. No ads.

EASY TO USE
• English, हिंदी and मराठी
• Large text mode, big buttons, read-aloud results

Important: PauseAsk can't catch every scam and the AI can be wrong. It never says a message is "safe": only your family can. If you have lost money, call the Cyber Crime Helpline 1930 and your bank immediately.

### पूरा विवरण – हिंदी

कोई मैसेज परेशान कर रहा है? रुकिए। परिवार से पूछिए। सुरक्षित रहिए।

PauseAsk बुज़ुर्ग माता-पिता और फ़ोन से कम परिचित लोगों के लिए है, ताकि किसी शक वाले मैसेज पर कुछ करने से पहले वे रुकें और एक टैप में परिवार से पूछ सकें।

यह कैसे काम करता है
• शक वाला SMS या WhatsApp मैसेज PauseAsk पर शेयर करें, स्क्रीनशॉट चुनें, या बस बोलकर बताएँ क्या हुआ।
• PauseAsk आसान शब्दों में खतरा समझाता है: बहुत ज़्यादा खतरा, संदिग्ध या सावधान रहें, और अब क्या करना है इसके 3 साफ़ कदम।
• आपके परिवार को तुरंत अलर्ट जाता है और वे एक टैप में जवाब देते हैं: "रुकिए", "ठीक है" या "अभी फ़ोन करें"।
• उनका जवाब आपके फ़ोन पर पूरी स्क्रीन पर दिखता है और पढ़कर सुनाया जा सकता है।

परिवार के लिए बना
• 5 लोगों तक का परिवार सर्कल। WhatsApp पर 6 अक्षरों के कोड से बुलाएँ।
• SOS बटन: 2 सेकंड दबाकर रखें और पूरे परिवार को एक साथ खबर जाए।
• रोज़ का "मैं ठीक हूँ": एक टैप से परिवार को पता चल जाता है कि आप ठीक हैं।
• आज का स्कैम अलर्ट: आजकल चल रहे असली स्कैम, आपकी भाषा में, शेयर करने में आसान।

प्राइवेसी सबसे पहले
• PauseAsk आपके SMS या WhatsApp कभी नहीं पढ़ता। यह सिर्फ़ वही देखता है जो आप शेयर करते हैं।
• स्क्रीनशॉट और आवाज़ आपके फ़ोन में ही रहते हैं; सिर्फ़ टेक्स्ट जाँचा जाता है।
• जाँच से पहले फ़ोन नंबर, OTP, खाता नंबर और UPI ID छिपा दिए जाते हैं।
• जाँचें 30 दिन बाद अपने-आप मिट जाती हैं। कोई विज्ञापन नहीं।

ज़रूरी: PauseAsk हर स्कैम नहीं पकड़ सकता और AI से भी गलती हो सकती है। यह कभी नहीं कहता कि मैसेज "सुरक्षित" है, यह सिर्फ़ आपका परिवार बता सकता है। पैसे कट गए हों तो तुरंत साइबर क्राइम हेल्पलाइन 1930 और अपने बैंक को फ़ोन करें।

### संपूर्ण वर्णन – मराठी

एखादा मेसेज खटकतोय? थांबा. कुटुंबाला विचारा. सुरक्षित राहा.

PauseAsk ज्येष्ठ आई-वडील आणि फोनची फारशी सवय नसलेल्यांसाठी आहे: संशयास्पद मेसेजवर काही करण्याआधी थांबा आणि एका टॅपमध्ये कुटुंबाला विचारा.

हे कसं काम करतं
• संशयास्पद SMS किंवा WhatsApp मेसेज PauseAsk वर शेअर करा, स्क्रीनशॉट निवडा, किंवा काय झालं ते बोलून सांगा.
• PauseAsk सोप्या शब्दांत धोका समजावून सांगतं: मोठा धोका, संशयास्पद किंवा सावध राहा, आणि आता काय करावं याच्या 3 स्पष्ट पायऱ्या.
• तुमच्या कुटुंबाला लगेच सूचना जाते आणि ते एका टॅपमध्ये उत्तर देतात: "थांबा", "ठीक आहे" किंवा "आत्ता फोन करा".
• त्यांचं उत्तर तुमच्या फोनवर पूर्ण स्क्रीनवर दिसतं आणि वाचूनही दाखवलं जातं.

कुटुंबासाठी बनवलेलं
• 5 जणांपर्यंतचं कुटुंब सर्कल. WhatsApp वर 6 अक्षरी कोडने बोलवा.
• SOS बटण: 2 सेकंद दाबून ठेवा आणि संपूर्ण कुटुंबाला एकदम कळवा.
• रोजचं "मी ठीक आहे": एका टॅपमध्ये कुटुंबाला कळतं की तुम्ही ठीक आहात.
• आजचा फसवणूक इशारा: सध्या सुरू असलेल्या खऱ्या फसवणुकी, तुमच्या भाषेत, शेअर करायला सोप्या.

गोपनीयता आधी
• PauseAsk तुमचे SMS किंवा WhatsApp कधीही वाचत नाही. तुम्ही शेअर करता तेवढंच त्याला दिसतं.
• स्क्रीनशॉट आणि आवाज तुमच्या फोनवरच राहतात; फक्त मजकूर तपासला जातो.
• तपासण्याआधी फोन नंबर, OTP, खाते क्रमांक आणि UPI ID लपवले जातात.
• तपासण्या 30 दिवसांनी आपोआप हटवल्या जातात. कोणत्याही जाहिराती नाहीत.

महत्त्वाचं: PauseAsk प्रत्येक फसवणूक ओळखू शकत नाही आणि AI सुद्धा चुकू शकतो. तो कधीच मेसेज "सुरक्षित" आहे असं सांगत नाही, हे फक्त तुमचं कुटुंब सांगू शकतं. पैसे गेले असतील तर लगेच सायबर क्राइम हेल्पलाइन 1930 आणि तुमच्या बँकेला फोन करा.

### Graphics checklist
- App icon 512×512 (from `assets/branding/icon.png`)
- Feature graphic 1024×500 (`assets/branding/feature_graphic.png`)
- 4–8 phone screenshots: Home (Protected), red HIGH result, Guardian alert with 3 buttons, full-screen STOP, Family circle, Scam alert. Take them in Marathi/Hindi too for the localized listings.

## 3. Data safety form

Answers reflect the code as of v1.0.0. If you add analytics/crash reporting later, update this.

**Does the app collect or share user data?** Yes (collects). **Is all data encrypted in transit?** Yes (HTTPS / Firebase).
**Can users request deletion?** Yes, in the app (Settings → Delete account) and at the delete-account URL.

| Play category → type | Collected | Shared | Optional? | Purposes | Notes |
|---|---|---|---|---|---|
| Personal info → **Name** | Yes | No | Required | App functionality, Account management | Shown to the user's family circle |
| Personal info → **Phone number** | Yes | No | Required | App functionality, Account management | Phone OTP sign-in; shown to the circle for "Call now" |
| Messages → **Other in-app messages** *(and/or App activity → Other user-generated content)* | Yes | No | Optional (only what the user submits) | App functionality | Text the user shares/pastes/types/speaks to check, with numbers/OTPs/accounts/UPI/email masked; kept 30 days |
| App activity → **App interactions** | Yes | No | Optional | App functionality | Daily check-in times, SOS presses, guardian replies |
| Device or other IDs | Yes | No | Required | App functionality | Firebase Installation ID used to deliver notifications |

**Not collected:** location, contacts, SMS inbox, call logs, photos/videos (screenshots are read on-device), audio (speech-to-text runs on-device), financial info, health, web history, advertising ID, crash logs/diagnostics (no third-party analytics in v1).

**About the AI provider and "sharing":** the masked text is sent to Google Gemini **only to process it on our behalf**. Under Play's definitions, transfers to a **service provider** acting for you are *not* "sharing", and data the user sends to their own family circle is a *user-initiated* transfer. So "Shared = No" is correct, **but** both are disclosed in the privacy policy. If your legal review prefers, you can tick "Shared → Messages" with purpose "App functionality" instead; it doesn't change anything else.

**Processed ephemerally?** No: checks are stored for 30 days.

## 4. Content rating (IARC questionnaire)

- Category: **Utility, Productivity, Communication or Other**
- Violence, sexual content, profanity, drugs, gambling: **No** (the feed *describes* scams, e.g. "fake police threat", without graphic content)
- **Users can interact / exchange information: Yes** (family circle members see each other's checks and replies; limited to people the user invites)
- Shares user's location: No · Digital purchases: No · Unrestricted internet access: No
- Expected rating: Everyone / PEGI 3 equivalent, but **target audience is 18+** (set in "Target audience and content").

Other declarations: Ads **No** · News app **No** · Government app **No** · Financial features **No** (the app gives safety advice, not financial services) · Health **No** · Data safety as above.

## 5. Permissions (justification for review notes)

| Permission | Why |
|---|---|
| `INTERNET` | Talk to Firebase (sign-in, checks, alerts) |
| `POST_NOTIFICATIONS` | Family alerts, guardian replies, SOS and the daily "I'm OK" reminder |
| `RECORD_AUDIO` | Only when the user taps "Tell us what happened"; speech is converted to text **on the device** |
| `RECEIVE_BOOT_COMPLETED` | Re-schedule the daily "I'm OK" reminder after a phone restart |
| `com.google.android.c2dm.RECEIVE` *(added by Firebase Messaging)* | Receive pushes |

**No SMS, call-log, contacts, location or storage permissions.** Shared messages arrive through the Android share sheet; screenshots through the system photo picker. (Mention this in review notes: it avoids the restricted SMS permission policy.)

## 6. Signing (do this once, keep the key forever)

1. Create the upload keystore **outside the repo**:
   ```sh
   keytool -genkey -v -keystore ~/keys/pauseask-upload.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (git-ignored, never commit):
   ```properties
   storeFile=/Users/<you>/keys/pauseask-upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. Back up the `.jks` file **and** both passwords in a password manager / secure drive. Losing them means you can't update the app (Play App Signing lets you reset the *upload* key via support, but it takes days).
4. Build: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.
   Without `key.properties` the build is debug-signed (Gradle prints a warning) and Play will reject it.
5. Let Play manage the **app signing key** (Play App Signing, default).
6. Add **both** SHA-1/SHA-256 fingerprints to Firebase → Project settings → Android app:
   - upload key: `keytool -list -v -keystore ~/keys/pauseask-upload.jks -alias upload`
   - Play app signing key: Play Console → Test and release → App integrity → App signing
   Then re-download `google-services.json`. Without these, **phone login fails** in the Play build.

Build settings already in the project: versionName **1.0.0**, versionCode **1** (`pubspec.yaml`), **minSdk 24** (Android 7.0), **targetSdk 36 / compileSdk 36** (Android 16: Google Play requires API 36 for new apps and updates since 31 Aug 2026), R8 shrinking with `android/app/proguard-rules.pro`. For each new upload increase the `+N` build number in `pubspec.yaml`.

## 7. App Check (turn on last)

1. Firebase console → **App Check** → Apps → Android app → **Play Integrity** → Register (needs the SHA-256 of the **Play app signing** key).
2. Debug builds use the debug provider: run a debug build, copy the token printed in logcat (`Enter this debug secret into the allow list…`) into **App Check → Manage debug tokens**.
3. Watch **App Check → Metrics** for a few days of internal testing: verified requests should be ~100%.
4. Then enforce:
   - **Cloud Functions:** set `ENFORCE_APP_CHECK=true` in `functions/.env` and `firebase deploy --only functions`.
   - **Firestore:** App Check → APIs → Cloud Firestore → **Enforce**.
5. If something breaks, set it back to `false` / Unenforce; no app update needed.

## 8. Testing tracks

1. Play Console → **Create app** (name, default language English (India), App, Free).
2. Complete **Set up your app**: privacy policy URL, app access (explain phone-OTP login and give a **test phone number + OTP** from Firebase Auth → Phone → test numbers for the reviewers), ads = No, content rating, target audience 18+, data safety, government/financial/health = No, account deletion URL.
3. **Internal testing** → create release → upload `app-release.aab` → add testers (email list, up to 100) → share the opt-in link. Use this for your own family first.
4. Run `docs/test-plan.md` Part 2 on the internal build; then enable App Check enforcement (section 7).
5. **Closed testing** → new track (e.g. "Family beta") → promote the release → add **12+ testers** (Gmail IDs or a Google Group).
   - A **personal** developer account created after Nov 2023 must keep at least **12 testers opted in for 14 continuous days** before applying for production.
   - An **organization** account (Multisarv, needs a D-U-N-S number) doesn't have this requirement.
6. Collect feedback (Play's private feedback + WhatsApp group), fix, upload new builds (bump `+N`).
7. **Production** → apply for access (personal accounts) → roll out, ideally staged (10% → 50% → 100%).
