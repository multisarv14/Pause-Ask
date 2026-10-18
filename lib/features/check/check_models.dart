import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Where the text came from. Values match the `analyzeCheck` input.
enum CheckSource { share, image, voice, typed }

/// There is no "safe" level: only a guardian can say a message is OK.
enum RiskLevel {
  high('HIGH', AppColors.riskHigh, AppColors.onRiskHigh, Icons.dangerous),
  suspicious(
    'SUSPICIOUS',
    AppColors.riskSuspicious,
    AppColors.onRiskSuspicious,
    Icons.warning_amber_rounded,
  ),
  beCareful(
    'BE_CAREFUL',
    AppColors.riskBeCareful,
    AppColors.onRiskBeCareful,
    Icons.info_outline,
  );

  const RiskLevel(this.wire, this.color, this.onColor, this.icon);

  final String wire;
  final Color color;
  final Color onColor;
  final IconData icon;

  /// Unknown values fall back to [beCareful], never to anything "safer".
  static RiskLevel fromWire(Object? value) => RiskLevel.values.firstWhere(
    (r) => r.wire == value,
    orElse: () => RiskLevel.beCareful,
  );

  String label(AppLocalizations l10n) => switch (this) {
    high => l10n.riskHigh,
    suspicious => l10n.riskSuspicious,
    beCareful => l10n.riskBeCareful,
  };
}

/// Text the user is about to check (after share / OCR / voice / typing).
class CheckDraft {
  const CheckDraft({required this.text, required this.source});

  final String text;
  final CheckSource source;
}

/// `result` returned by `analyzeCheck`.
class CheckResult {
  const CheckResult({
    required this.riskLevel,
    required this.scamType,
    required this.redFlags,
    required this.whatToDo,
    required this.summary,
  });

  factory CheckResult.fromMap(Map<String, dynamic> m) => CheckResult(
    riskLevel: RiskLevel.fromWire(m['riskLevel']),
    scamType: m['scamType'] as String? ?? '',
    redFlags: List<String>.from(m['redFlags'] as List? ?? const []),
    whatToDo: List<String>.from(m['whatToDo'] as List? ?? const []),
    summary: m['summary'] as String? ?? '',
  );

  final RiskLevel riskLevel;
  final String scamType;
  final List<String> redFlags;
  final List<String> whatToDo;
  final String summary;
}

class CheckOutcome {
  const CheckOutcome({required this.checkId, required this.result});

  final String checkId;
  final CheckResult result;
}

/// A guardian's one-tap reply. Only a human can say "OK".
enum GuardianReply {
  stop('STOP', AppColors.riskHigh, AppColors.onRiskHigh, Icons.pan_tool),
  ok('OK', AppColors.guardianOk, AppColors.onGuardianOk, Icons.check_circle),
  call('CALL', AppColors.primary, AppColors.onPrimary, Icons.phone_in_talk);

  const GuardianReply(this.wire, this.color, this.onColor, this.icon);

  final String wire;
  final Color color;
  final Color onColor;
  final IconData icon;

  static GuardianReply? fromWire(Object? value) =>
      GuardianReply.values.where((r) => r.wire == value).firstOrNull;

  String label(AppLocalizations l10n) => switch (this) {
    stop => l10n.responseLabelStop,
    ok => l10n.responseLabelOk,
    call => l10n.responseLabelCall,
  };
}

/// `checks/{id}.guardianResponse` — the first guardian reply.
class GuardianResponse {
  const GuardianResponse({
    required this.byUid,
    required this.byName,
    required this.reply,
    this.at,
  });

  static GuardianResponse? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final reply = GuardianReply.fromWire(raw['type']);
    if (reply == null) return null;
    final at = raw['at'];
    return GuardianResponse(
      byUid: raw['byUid'] as String? ?? '',
      byName: raw['byName'] as String? ?? '',
      reply: reply,
      at: at is Timestamp
          ? at.toDate()
          : at is int
          ? DateTime.fromMillisecondsSinceEpoch(at)
          : null,
    );
  }

  final String byUid;
  final String byName;
  final GuardianReply reply;
  final DateTime? at;
}

/// A stored check as members of the circle can read it.
class CheckRecord {
  const CheckRecord({
    required this.id,
    required this.uid,
    required this.circleId,
    required this.maskedText,
    required this.result,
    required this.createdAt,
    this.guardianResponse,
    this.guardianCount,
  });

  factory CheckRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final alert = d['alert'];
    return CheckRecord(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      circleId: d['circleId'] as String?,
      maskedText: d['maskedText'] as String? ?? '',
      result: CheckResult.fromMap(
        Map<String, dynamic>.from(d['result'] as Map? ?? const {}),
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      guardianResponse: GuardianResponse.fromMap(d['guardianResponse']),
      guardianCount: alert is Map
          ? (alert['guardianCount'] as num?)?.toInt()
          : null,
    );
  }

  final String id;
  final String uid;
  final String? circleId;
  final String maskedText;
  final CheckResult result;
  final DateTime createdAt;
  final GuardianResponse? guardianResponse;

  /// Set by `onCheckCreated`; null while alerts are still being sent.
  final int? guardianCount;
}
