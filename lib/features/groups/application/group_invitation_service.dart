import 'package:flutter_sms/flutter_sms.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:url_launcher/url_launcher.dart';

typedef WhatsAppLauncher = Future<bool> Function(Uri uri);
typedef SmsCapabilityChecker = Future<bool> Function();
typedef SmsLauncher =
    Future<bool> Function(String message, List<String> recipients);

class InvitationLaunchResult {
  const InvitationLaunchResult.success() : errorMessage = null;

  const InvitationLaunchResult.failure(this.errorMessage);

  final String? errorMessage;

  bool get succeeded => errorMessage == null;
}

class GroupInvitationService {
  GroupInvitationService({
    WhatsAppLauncher? whatsAppLauncher,
    SmsCapabilityChecker? smsCapabilityChecker,
    SmsLauncher? smsLauncher,
  }) : _whatsAppLauncher = whatsAppLauncher ?? _launchWhatsApp,
       _smsCapabilityChecker = smsCapabilityChecker ?? canSendSMS,
       _smsLauncher = smsLauncher ?? _launchSms;

  static const int maximumSmsRecipients = 50;

  final WhatsAppLauncher _whatsAppLauncher;
  final SmsCapabilityChecker _smsCapabilityChecker;
  final SmsLauncher _smsLauncher;

  String buildInviteLink(Group group) {
    return Uri(
      scheme: 'hesabuonline',
      host: 'app',
      path: '/groups/join',
      queryParameters: {'account_no': group.accountNo},
    ).toString();
  }

  String buildInviteMessage({required Group group, String? senderName}) {
    final inviter = senderName?.trim();
    final signature = inviter == null || inviter.isEmpty
        ? 'A ${group.name} member'
        : inviter;

    return '''Dear Friend,

I am inviting you to join our Community's - ${group.name} - on Hesabu Online.

To join, open this link: ${buildInviteLink(group)}
Group account number: ${group.accountNo}

You can also contribute directly through the Hesabu Online Paybill using this group account number.

Thank you very much.

$signature''';
  }

  Future<InvitationLaunchResult> shareViaWhatsApp(String message) async {
    final uri = Uri.https('wa.me', '/', {'text': message});
    try {
      final launched = await _whatsAppLauncher(uri);
      if (!launched) {
        return const InvitationLaunchResult.failure(
          'WhatsApp could not be opened on this device.',
        );
      }
      return const InvitationLaunchResult.success();
    } catch (_) {
      return const InvitationLaunchResult.failure(
        'WhatsApp could not be opened on this device.',
      );
    }
  }

  Future<InvitationLaunchResult> composeBulkSms({
    required String message,
    required List<String> recipients,
  }) async {
    final uniqueRecipients = recipients.toSet().toList(growable: false);
    if (uniqueRecipients.isEmpty) {
      return const InvitationLaunchResult.failure(
        'Select at least one contact first.',
      );
    }
    if (uniqueRecipients.length > maximumSmsRecipients) {
      return const InvitationLaunchResult.failure(
        'Select no more than 50 contacts per SMS batch.',
      );
    }

    try {
      if (!await _smsCapabilityChecker()) {
        return const InvitationLaunchResult.failure(
          'SMS is not available on this device.',
        );
      }

      final launched = await _smsLauncher(message, uniqueRecipients);
      if (!launched) {
        return const InvitationLaunchResult.failure(
          'The SMS composer could not be opened.',
        );
      }
      return const InvitationLaunchResult.success();
    } catch (_) {
      return const InvitationLaunchResult.failure(
        'The SMS composer could not be opened.',
      );
    }
  }

  static Future<bool> _launchWhatsApp(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> _launchSms(String message, List<String> recipients) {
    return launchSmsMulti(message: message, numbers: recipients);
  }
}
