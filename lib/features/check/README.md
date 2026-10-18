# check

Protected user flow: Pause & Ask → (share | screenshot OCR | voice | paste/type) → confirm/edit → `analyzeCheck` → coloured, read-aloud result.

- `compose_screen.dart`: paste/type, or confirm/edit text from OCR, voice or a long share.
- `ocr_screen.dart` + `services/ocr`: ML Kit Latin + Devanagari, on-device. Images are never uploaded.
- `voice_screen.dart`: speech_to_text with `onDevice: true` in hi/mr/en (IN locales).
- `checking_screen.dart`: calls the function and shows the "don't send money / OTP" reminder.
- `result_screen.dart`: risk banner, red flags, 3 steps, Read aloud (`services/tts`), family status placeholder.
- Shared text goes straight to checking; shared images go through OCR and confirm (`services/share`).
