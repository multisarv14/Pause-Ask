import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether `Firebase.initializeApp()` succeeded. Overridden in `main()`;
/// false in tests and before `flutterfire configure` has been run.
final firebaseReadyProvider = Provider<bool>((ref) => false);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

/// The signed-in Firebase user, or null.
final authStateProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return Stream.value(null);
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
