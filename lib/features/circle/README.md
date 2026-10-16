# circle

Family Circle: create, invite (6-char code via WhatsApp / share sheet), join with code, member list, leave, owner removes members.

- Reads: Firestore directly (`circle_repository.dart`; rules allow members only).
- Writes: callable Cloud Functions only (`functions/src/circles/circles.ts`).
- Errors: `circle_error.dart` maps `details.reason` to localized text.
