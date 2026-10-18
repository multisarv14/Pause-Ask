import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import 'checkin_models.dart';

/// Payload of the daily reminder; tapping it counts as a check-in.
const checkinReminderPayloadType = 'checkin';
const _reminderId = 7001;

/// Next [time] in the device zone (today if still ahead, else tomorrow).
tz.TZDateTime nextReminderAt(TimeOfDay time, {tz.TZDateTime? now}) {
  final n = now ?? tz.TZDateTime.now(tz.local);
  var at = tz.TZDateTime(
    n.location,
    n.year,
    n.month,
    n.day,
    time.hour,
    time.minute,
  );
  if (!at.isAfter(n)) at = at.add(const Duration(days: 1));
  return at;
}

/// Schedules (or cancels) the daily "I'm OK" reminder on the phone.
/// Uses inexact alarms, so Android may deliver it a few minutes late; exact
/// alarms need an extra permission Play restricts to alarm/calendar apps.
Future<void> syncCheckinReminder(
  CheckinSettings settings,
  AppLocalizations l10n,
) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.cancel(id: _reminderId);
  if (!settings.enabled) return;
  await plugin.zonedSchedule(
    id: _reminderId,
    scheduledDate: nextReminderAt(settings.time),
    title: 'PauseAsk',
    body: settings.time.hour < 12
        ? l10n.checkinReminderMorning
        : l10n.checkinReminderOther,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'general',
        'general',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // every day
    payload: jsonEncode({'type': checkinReminderPayloadType}),
  );
}
