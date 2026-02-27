import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:go_router/go_router.dart';

class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : AppColors.slate200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.15),
                          accent.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.support_agent, size: 48, color: accent),
                        const SizedBox(height: 12),
                        Text(
                          'How can we help?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Our support team is available\nMon – Sat, 8am – 6pm EAT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _sectionLabel('CONTACT US'),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: [
                        _contactTile(
                          context,
                          Icons.chat_bubble_outline,
                          Colors.green,
                          'WhatsApp Support',
                          'Chat with us directly',
                          showDivider: true,
                        ),
                        _contactTile(
                          context,
                          Icons.email_outlined,
                          Colors.blue,
                          'Email Support',
                          'support@hesabu.co.ke',
                          showDivider: true,
                        ),
                        _contactTile(
                          context,
                          Icons.phone_outlined,
                          accent,
                          'Call Support',
                          '+254 700 000 000',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _sectionLabel('FREQUENTLY ASKED QUESTIONS'),
                  ..._faqs.map(
                    (faq) => _FaqTile(
                      question: faq['q']!,
                      answer: faq['a']!,
                      accent: accent,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.slate500,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _contactTile(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String sub, {
    required bool showDivider,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.08),
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }

  static const _faqs = [
    {
      'q': 'How do I join a group?',
      'a':
          'You can join a group using the Group ID or Group Account Number shared by your administrator. Go to Groups → Join a Group and enter the code.',
    },
    {
      'q': 'How do contributions work?',
      'a':
          'Members contribute funds using the Group Account Number. All contributions are credited directly into the group wallet and attributed to your profile.',
    },
    {
      'q': 'How do I withdraw from the group wallet?',
      'a':
          'Only treasurers and group administrators can make withdrawals. Members can view contribution statements but cannot initiate payouts.',
    },
    {
      'q': 'What payment methods are supported?',
      'a':
          'Hesabu Online supports M-Pesa B2C, B2B, Till numbers, Paybill numbers, and direct mobile number transfers.',
    },
    {
      'q': 'How do I export a contribution report?',
      'a':
          'Go to your group dashboard → Reports → Export to Excel. You can also share summaries directly to WhatsApp groups.',
    },
  ];
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final Color accent;
  final Color cardBg;
  final Color cardBorder;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.accent,
    required this.cardBg,
    required this.cardBorder,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _open ? widget.accent.withOpacity(0.4) : widget.cardBorder,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _open ? widget.accent : AppColors.slate400,
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
