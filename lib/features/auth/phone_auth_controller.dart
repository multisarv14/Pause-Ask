import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_error.dart';
import 'auth_providers.dart';

class PhoneAuthState {
  const PhoneAuthState({
    this.busy = false,
    this.phone,
    this.verificationId,
    this.resendToken,
    this.codeSentAt,
    this.autoFilledCode,
    this.error,
  });

  final bool busy;

  /// E.164 number, e.g. +919876543210.
  final String? phone;
  final String? verificationId;
  final int? resendToken;
  final DateTime? codeSentAt;

  /// Set when Android reads the SMS for us.
  final String? autoFilledCode;
  final AuthError? error;

  PhoneAuthState copyWith({
    bool? busy,
    String? phone,
    String? verificationId,
    int? resendToken,
    DateTime? codeSentAt,
    String? autoFilledCode,
    AuthError? error,
    bool clearError = false,
  }) => PhoneAuthState(
    busy: busy ?? this.busy,
    phone: phone ?? this.phone,
    verificationId: verificationId ?? this.verificationId,
    resendToken: resendToken ?? this.resendToken,
    codeSentAt: codeSentAt ?? this.codeSentAt,
    autoFilledCode: autoFilledCode ?? this.autoFilledCode,
    error: clearError ? null : (error ?? this.error),
  );
}

final phoneAuthControllerProvider =
    NotifierProvider<PhoneAuthController, PhoneAuthState>(
      PhoneAuthController.new,
    );

/// Phone-number OTP sign-in. A successful sign-in shows up in
/// [authStateProvider]; the router then moves on by itself.
class PhoneAuthController extends Notifier<PhoneAuthState> {
  @override
  PhoneAuthState build() => const PhoneAuthState();

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  /// Sends (or re-sends) the SMS code. Completes with true once the code
  /// is on its way, or the phone was verified instantly (Android).
  Future<bool> sendCode(String phone, {bool resend = false}) async {
    state = state.copyWith(busy: true, phone: phone, clearError: true);
    final result = Completer<bool>();
    void finish(bool ok) {
      if (!result.isCompleted) result.complete(ok);
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resend ? state.resendToken : null,
        // Android only: instant verification or SMS auto-retrieval.
        verificationCompleted: (credential) async {
          state = state.copyWith(autoFilledCode: credential.smsCode);
          finish(await _signIn(credential));
        },
        verificationFailed: (e) {
          state = state.copyWith(busy: false, error: AuthError.from(e));
          finish(false);
        },
        codeSent: (verificationId, resendToken) {
          state = state.copyWith(
            busy: false,
            verificationId: verificationId,
            resendToken: resendToken,
            codeSentAt: DateTime.now(),
          );
          finish(true);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (e) {
      state = state.copyWith(busy: false, error: AuthError.from(e));
      finish(false);
    }
    return result.future;
  }

  Future<bool> verifyCode(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) {
      state = state.copyWith(error: AuthError.codeExpired);
      return false;
    }
    state = state.copyWith(busy: true, clearError: true);
    return _signIn(
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  Future<bool> _signIn(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      state = state.copyWith(busy: false);
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: AuthError.from(e));
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    ref.invalidateSelf();
  }
}
