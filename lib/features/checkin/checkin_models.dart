import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// `users/{uid}.checkin` (written only by Cloud Functions) and the copy on
/// the circle member doc that guardians read.
class CheckinSettings {
  const CheckinSettings({
    required this.enabled,
    required this.time,
    required this.alertAfterHours,
    required this.timezone,
    this.lastCheckinAt,
    this.lastMissedAlertDate,
  });

  static const defaults = CheckinSettings(
    enabled: true,
    time: TimeOfDay(hour: 9, minute: 0),
    alertAfterHours: 12,
    timezone: 'Asia/Kolkata',
  );

  static const alertAfterChoices = [1, 2, 4, 6, 8, 12, 24];

  /// Null when settings were never saved (no time / timezone yet).
  static CheckinSettings? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final time = parseTime(raw['time']);
    final zone = raw['timezone'];
    if (time == null || zone is! String) return null;
    return CheckinSettings(
      enabled: raw['enabled'] == true,
      time: time,
      alertAfterHours: (raw['alertAfterHours'] as num?)?.toInt() ?? 12,
      timezone: zone,
      lastCheckinAt: (raw['lastCheckinAt'] as Timestamp?)?.toDate(),
      lastMissedAlertDate: raw['lastMissedAlertDate'] as String?,
    );
  }

  static TimeOfDay? parseTime(Object? value) {
    if (value is! String) return null;
    final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (m == null) return null;
    return TimeOfDay(hour: int.parse(m[1]!), minute: int.parse(m[2]!));
  }

  final bool enabled;
  final TimeOfDay time;
  final int alertAfterHours;
  final String timezone;
  final DateTime? lastCheckinAt;
  final String? lastMissedAlertDate;

  String get timeString =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  CheckinSettings copyWith({
    bool? enabled,
    TimeOfDay? time,
    int? alertAfterHours,
    String? timezone,
  }) => CheckinSettings(
    enabled: enabled ?? this.enabled,
    time: time ?? this.time,
    alertAfterHours: alertAfterHours ?? this.alertAfterHours,
    timezone: timezone ?? this.timezone,
    lastCheckinAt: lastCheckinAt,
    lastMissedAlertDate: lastMissedAlertDate,
  );
}

enum CheckinStatus { ok, notYet, missed, off }

/// 🟢 / ⚪ / 🔴 for a member, judged in the member's own time zone.
/// [okAt] is the check-in time in that zone when status is [CheckinStatus.ok].
({CheckinStatus status, DateTime? okAt}) checkinStatus(
  CheckinSettings? s, {
  DateTime? now,
}) {
  if (s == null || !s.enabled) return (status: CheckinStatus.off, okAt: null);
  tz.Location location;
  try {
    location = tz.getLocation(s.timezone);
  } catch (_) {
    location = tz.local;
  }
  final localNow = tz.TZDateTime.from(now ?? DateTime.now(), location);
  final dayStart = tz.TZDateTime(
    location,
    localNow.year,
    localNow.month,
    localNow.day,
  );
  final last = s.lastCheckinAt;
  if (last != null && !last.isBefore(dayStart)) {
    return (status: CheckinStatus.ok, okAt: tz.TZDateTime.from(last, location));
  }
  final todayKey =
      '${localNow.year}-${localNow.month.toString().padLeft(2, '0')}-${localNow.day.toString().padLeft(2, '0')}';
  if (s.lastMissedAlertDate == todayKey) {
    return (status: CheckinStatus.missed, okAt: null);
  }
  return (status: CheckinStatus.notYet, okAt: null);
}
