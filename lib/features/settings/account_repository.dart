import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/user_profile.dart';
import '../../services/firebase/firebase_bootstrap.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => FunctionsAccountRepository(appFunctions()),
);

abstract interface class AccountRepository {
  /// Roles change through a function so the circle copy stays in sync.
  Future<void> updateRoles(RoleChoice choice);

  /// True if a push was sent to this phone.
  Future<bool> sendTestAlert();

  /// Deletes profile, checks, usage, circle membership and the Auth user.
  Future<void> deleteMyAccount();
}

class FunctionsAccountRepository implements AccountRepository {
  FunctionsAccountRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<void> updateRoles(RoleChoice choice) => _functions
      .httpsCallable('updateRoles')
      .call<Object?>({'roles': choice.roles});

  @override
  Future<bool> sendTestAlert() async {
    final r = await _functions.httpsCallable('sendTestAlert').call<Object?>();
    return (r.data as Map?)?['sent'] == true;
  }

  @override
  Future<void> deleteMyAccount() =>
      _functions.httpsCallable('deleteMyAccount').call<Object?>();
}
