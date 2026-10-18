import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/router/startup_guard.dart';
import '../../core/storage/preferences.dart';
import '../../core/widgets/app_keys.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/checkin/checkin_models.dart';
import '../../features/checkin/checkin_repository.dart';
import '../../features/checkin/reminder_service.dart';
import '../../features/settings/battery_guide_screen.dart';
import '../../features/profile/profile_repository.dart';
import '../../l10n/app_localizations.dart';

/// Android channels (ids must match functions/src/lib/push.ts).
abstract final class NotificationChannels {
  static const alerts = 'alerts';
  static const general = 'general';
}

/// Push `data.type` values sent by the functions.
abstract final class PushTypes {
  static const checkAlert = 'check_alert';
  static const checkAnswered = 'check_answered';
  static const guardianResponse = 'guardian_response';
  static const sos = 'sos';
  static const missedCheckin = 'missed_checkin';
  static const feed = 'feed';
}

/// Check ids whose guardian reply was already shown full-screen, so the push
/// and the live Firestore listener don't open it twice.
final shownResponsesProvider = NotifierProvider<ShownResponses, Set<String>>(
  ShownResponses.new,
);

class ShownResponses extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// True the first time [checkId] is marked.
  bool markShown(String checkId) {
    if (state.contains(checkId)) return false;
    state = {...state, checkId};
    return true;
  }
}

/// Opens the full-screen guardian reply once per check.
void openGuardianResponse(ShownResponses shown, GoRouter router, String id) {
  if (shown.markShown(id)) router.push(AppRoutes.checkResponse(id));
}

/// Removes this device from guardian alerts (on logout). Best effort.
Future<void> unregisterDevice(Ref ref, String uid) async {
  if (!ref.read(firebaseReadyProvider)) return;
  try {
    await ref.read(profileRepositoryProvider).updateFcmToken(uid, null);
    await FirebaseMessaging.instance.unregister();
  } catch (_) {}
}

/// Sets up FCM once the user is signed in with a profile: permission
/// (Android 13+), channels, token in users/{uid}, and opening the right
/// screen from a notification.
class NotificationsBootstrap extends ConsumerStatefulWidget {
  const NotificationsBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationsBootstrap> createState() =>
      _NotificationsBootstrapState();
}

class _NotificationsBootstrapState extends ConsumerState<NotificationsBootstrap>
    with WidgetsBindingObserver {
  final _local = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription<Object?>> _subs = [];
  String? _setUpFor;
  bool _localReady = false;

  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSetUp());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSubs();
    super.dispose();
  }

  void _cancelSubs() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  Future<void> _maybeSetUp() async {
    if (!_supported || !ref.read(firebaseReadyProvider)) return;
    final uid = ref.read(authStateProvider).value?.uid;
    final ready = ref.read(startupStepProvider) == StartupStep.ready;
    if (!ready || uid == null) {
      if (uid == null && _setUpFor != null) {
        _cancelSubs();
        _setUpFor = null;
      }
      return;
    }
    if (_setUpFor == uid) return;
    _setUpFor = uid;
    try {
      await _setUp(uid);
    } catch (e) {
      debugPrint('Notification setup failed: $e');
    }
  }

  Future<void> _setUp(String uid) async {
    final messaging = FirebaseMessaging.instance;
    final l10n = lookupAppLocalizations(
      Locale(ref.read(languageProvider) ?? 'en'),
    );

    if (!_localReady) {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (r) => _openPayload(r.payload),
      );
      _localReady = true;
    }
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.alerts,
        l10n.channelAlertsName,
        description: l10n.channelAlertsDescription,
        importance: Importance.max,
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.general,
        l10n.channelGeneralName,
        importance: Importance.defaultImportance,
      ),
    );

    // Android 13+ shows the system permission dialog here.
    await messaging.requestPermission();

    // users/{uid}.fcmToken holds this install's Firebase Installation ID
    // (FID); onRegistered also fires again if it ever changes.
    final profiles = ref.read(profileRepositoryProvider);
    _cancelSubs();
    _subs
      ..add(
        messaging.onRegistered.listen(
          (fid) => profiles.updateFcmToken(uid, fid).ignore(),
        ),
      )
      ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m.data)));
    await messaging.register();

    // App was started by tapping a notification.
    final initial = await messaging.getInitialMessage();
    if (initial != null) _open(initial.data);
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _openPayload(launch!.notificationResponse?.payload);
    }

    await _syncCheckin(l10n);
    await _maybeShowBatteryGuide();
  }

  /// Protected users: make sure check-in settings exist (default ON, 9:00,
  /// 12 h, device time zone), keep the daily reminder scheduled, and count
  /// opening the app as today's check-in.
  Future<void> _syncCheckin(AppLocalizations l10n) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || !profile.isProtected) return;
    try {
      final zone = await initDeviceTimeZone();
      var settings = profile.checkin;
      if (settings == null || settings.timezone != zone) {
        settings = (settings ?? CheckinSettings.defaults).copyWith(
          timezone: zone,
        );
        await ref.read(checkinRepositoryProvider).save(settings);
      }
      await syncCheckinReminder(settings, l10n);
      await _appOpenCheckin();
    } catch (e) {
      debugPrint('Check-in sync failed: $e');
    }
  }

  /// Opening the app counts as "I'm OK" (at most once an hour).
  Future<void> _appOpenCheckin() async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || !profile.isProtected) return;
    if (profile.checkin?.enabled == false) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final last = prefs.getInt(PrefKeys.lastAppCheckinMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - last < const Duration(hours: 1).inMilliseconds) return;
    try {
      await ref.read(checkinRepositoryProvider).checkIn();
      await prefs.setInt(PrefKeys.lastAppCheckinMs, now);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _setUpFor != null) {
      _appOpenCheckin();
    }
  }

  /// One-time guide on phones that kill background apps.
  Future<void> _maybeShowBatteryGuide() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(PrefKeys.batteryGuideShown) ?? false) return;
    if (!await needsBatteryGuide()) return;
    await prefs.setBool(PrefKeys.batteryGuideShown, true);
    ref.read(appRouterProvider).push(AppRoutes.batteryGuide);
  }

  /// Tapping the daily reminder = check-in, with a thank-you.
  Future<void> _reminderTapped() async {
    final l10n = lookupAppLocalizations(
      Locale(ref.read(languageProvider) ?? 'en'),
    );
    try {
      await ref.read(checkinRepositoryProvider).checkIn();
      await ref
          .read(sharedPreferencesProvider)
          .setInt(
            PrefKeys.lastAppCheckinMs,
            DateTime.now().millisecondsSinceEpoch,
          );
      rootMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.checkinThanks)),
      );
    } catch (_) {
      rootMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  /// FCM doesn't display notifications while the app is open; show it
  /// ourselves. A guardian's reply also opens full-screen right away.
  void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    final type = message.data['type'];
    if (n != null) {
      final channel = type == PushTypes.checkAnswered
          ? NotificationChannels.general
          : NotificationChannels.alerts;
      _local.show(
        id: message.hashCode & 0x7fffffff,
        title: n.title,
        body: n.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel,
            channel,
            importance: channel == NotificationChannels.alerts
                ? Importance.max
                : Importance.defaultImportance,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
    if (type == PushTypes.guardianResponse) _open(message.data);
  }

  void _openPayload(String? payload) {
    if (payload == null) return;
    try {
      _open(Map<String, dynamic>.from(jsonDecode(payload) as Map));
    } catch (_) {}
  }

  void _open(Map<String, dynamic> data) {
    final router = ref.read(appRouterProvider);
    switch (data['type']) {
      case checkinReminderPayloadType:
        _reminderTapped();
        return;
      case PushTypes.sos:
        final uid = data['fromUid'];
        if (uid is String && uid.isNotEmpty) {
          router.push(AppRoutes.sosAlert(uid));
        }
        return;
      case PushTypes.missedCheckin:
        router.go(AppRoutes.home);
        return;
      case PushTypes.feed:
        router.push(AppRoutes.feed);
        return;
    }
    final checkId = data['checkId'];
    if (checkId is! String || checkId.isEmpty) return;
    switch (data['type']) {
      case PushTypes.checkAlert || PushTypes.checkAnswered:
        router.push(AppRoutes.guardianCheck(checkId));
      case PushTypes.guardianResponse:
        openGuardianResponse(
          ref.read(shownResponsesProvider.notifier),
          router,
          checkId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(startupStepProvider, (_, _) => _maybeSetUp());
    ref.listen(authStateProvider, (_, _) => _maybeSetUp());
    return widget.child;
  }
}
