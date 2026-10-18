import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'check_error.dart';
import 'check_models.dart';
import '../../services/firebase/firebase_bootstrap.dart';

final checkRepositoryProvider = Provider<CheckRepository>(
  (ref) => FunctionsCheckRepository(appFunctions(), Connectivity()),
);

abstract interface class CheckRepository {
  /// Throws [CheckError].
  Future<CheckOutcome> analyze(CheckDraft draft, {required String language});
}

/// Sends only the (already extracted) text to `analyzeCheck`.
/// Screenshots and audio never leave the phone.
class FunctionsCheckRepository implements CheckRepository {
  FunctionsCheckRepository(this._functions, this._connectivity);

  final FirebaseFunctions _functions;
  final Connectivity _connectivity;

  @override
  Future<CheckOutcome> analyze(
    CheckDraft draft, {
    required String language,
  }) async {
    final text = draft.text.trim();
    if (text.isEmpty) throw CheckError.empty;
    if (text.length > AppConstants.maxCheckTextLength) {
      throw CheckError.tooLong;
    }
    // Fail fast in airplane mode instead of waiting for a timeout.
    final links = await _connectivity.checkConnectivity();
    if (links.every((l) => l == ConnectivityResult.none)) {
      throw CheckError.network;
    }

    try {
      final response = await _functions
          .httpsCallable(
            'analyzeCheck',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 70)),
          )
          .call<Object?>({
            'text': text,
            'source': draft.source.name,
            'language': language,
          });
      final data = Map<String, dynamic>.from(response.data as Map);
      return CheckOutcome(
        checkId: data['checkId'] as String,
        result: CheckResult.fromMap(
          Map<String, dynamic>.from(data['result'] as Map),
        ),
      );
    } catch (e) {
      throw CheckError.from(e);
    }
  }
}
