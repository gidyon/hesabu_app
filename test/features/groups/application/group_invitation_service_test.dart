import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/features/groups/application/group_invitation_service.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

void main() {
  group('GroupInvitationService', () {
    test('builds a personalized invite with join link and account number', () {
      final service = GroupInvitationService();

      final message = service.buildInviteMessage(
        group: _group(),
        senderName: 'Eustero',
      );

      expect(message, contains('Dear Friend'));
      expect(message, contains('Eustero Group'));
      expect(message, contains('Group account number: 10800921'));
      expect(
        message,
        contains('hesabuonline://app/groups/join?account_no=10800921'),
      );
      expect(message, endsWith('Eustero'));
    });

    test('opens WhatsApp with the complete invitation message', () async {
      Uri? launchedUri;
      final service = GroupInvitationService(
        whatsAppLauncher: (uri) async {
          launchedUri = uri;
          return true;
        },
      );
      final message = service.buildInviteMessage(group: _group());

      final result = await service.shareViaWhatsApp(message);

      expect(result.succeeded, isTrue);
      expect(launchedUri?.host, 'wa.me');
      expect(launchedUri?.queryParameters['text'], message);
    });

    test('opens one SMS composer for the selected recipients', () async {
      String? composedMessage;
      List<String>? composedRecipients;
      final service = GroupInvitationService(
        smsCapabilityChecker: () async => true,
        smsLauncher: (message, recipients) async {
          composedMessage = message;
          composedRecipients = recipients;
          return true;
        },
      );

      final result = await service.composeBulkSms(
        message: 'Invite text',
        recipients: const ['254700000001', '254700000002'],
      );

      expect(result.succeeded, isTrue);
      expect(composedMessage, 'Invite text');
      expect(composedRecipients, ['254700000001', '254700000002']);
    });

    test('does not open SMS without a recipient', () async {
      var launched = false;
      final service = GroupInvitationService(
        smsCapabilityChecker: () async => true,
        smsLauncher: (_, _) async {
          launched = true;
          return true;
        },
      );

      final result = await service.composeBulkSms(
        message: 'Invite text',
        recipients: const [],
      );

      expect(result.succeeded, isFalse);
      expect(result.errorMessage, contains('Select at least one'));
      expect(launched, isFalse);
    });
  });
}

Group _group() => Group(
  id: '10',
  name: 'Eustero Group',
  membersCount: '10',
  frequency: 'Monthly',
  imageUrl: '',
  balance: 193,
  goal: 0,
  progressPercentage: 0,
  status: 'active',
  role: 'admin',
  accountNo: '10800921',
  location: 'Nairobi',
  description: '',
);
