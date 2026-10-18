import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp with [text]. Returns false if WhatsApp isn't installed.
Future<bool> shareOnWhatsApp(String text) async {
  final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}

/// WhatsApp first (our main growth loop); the system share sheet otherwise.
Future<void> shareViaWhatsAppOrSheet(String text) async {
  if (await shareOnWhatsApp(text)) return;
  await SharePlus.instance.share(ShareParams(text: text));
}
