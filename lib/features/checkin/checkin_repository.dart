import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'checkin_models.dart';
import '../../services/firebase/firebase_bootstrap.dart';

final checkinRepositoryProvider = Provider<CheckinRepository>(
  (ref) => CheckinRepository(appFunctions()),
);

/// Loads the time-zone database and sets tz.local to the device zone
/// (e.g. Asia/Kolkata). Returns the IANA name. Safe to call more than once.
Future<String> initDeviceTimeZone() async {
  tzdata.initializeTimeZones();
  var name = 'Asia/Kolkata';
  try {
    name = (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (e) {
    debugPrint('Time zone lookup failed, using $name: $e');
  }
  try {
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {
    name = 'Asia/Kolkata';
    tz.setLocalLocation(tz.getLocation(name));
  }
  return name;
}

/// Check-ins and settings go through Cloud Functions (`checkIn`,
/// `saveCheckinSettings`); the app never writes users/{uid}.checkin.
class CheckinRepository {
  CheckinRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<void> checkIn() => _functions.httpsCallable('checkIn').call<Object?>();

  Future<void> save(CheckinSettings s) =>
      _functions.httpsCallable('saveCheckinSettings').call<Object?>({
        'enabled': s.enabled,
        'time': s.timeString,
        'alertAfterHours': s.alertAfterHours,
        'timezone': s.timezone,
      });
}
