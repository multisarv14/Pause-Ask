import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase/firebase_bootstrap.dart';

final sosRepositoryProvider = Provider<SosRepository>(
  (ref) => FunctionsSosRepository(appFunctions()),
);

class SosGuardian {
  const SosGuardian({required this.name, required this.phone});

  final String name;
  final String phone;
}

class SosResult {
  const SosResult({required this.guardianCount, this.firstGuardian});

  final int guardianCount;
  final SosGuardian? firstGuardian;
}

enum SosError implements Exception { limit, failed }

abstract interface class SosRepository {
  /// Throws [SosError].
  Future<SosResult> send();
}

class FunctionsSosRepository implements SosRepository {
  FunctionsSosRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<SosResult> send() async {
    try {
      final r = await _functions.httpsCallable('sendSos').call<Object?>();
      final d = Map<String, dynamic>.from(r.data as Map);
      final g = d['firstGuardian'];
      return SosResult(
        guardianCount: (d['guardianCount'] as num?)?.toInt() ?? 0,
        firstGuardian: g is Map
            ? SosGuardian(
                name: g['name'] as String? ?? '',
                phone: g['phone'] as String? ?? '',
              )
            : null,
      );
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final reason = details is Map ? details['reason'] : e.message;
      throw reason == 'SOS_LIMIT' ? SosError.limit : SosError.failed;
    } catch (_) {
      throw SosError.failed;
    }
  }
}
