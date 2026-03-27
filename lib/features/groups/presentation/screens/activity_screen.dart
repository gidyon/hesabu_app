import 'package:flutter/material.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final isDark = themeController.isDark;
    final accent = themeController.accentColor.primary;
    final backgroundColor = isDark
        ? themeController.accentColor.darkBackground
        : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.02);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 20),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPushToggle(cardColor, titleColor, accent),
          const SizedBox(height: 24),
          _buildSectionHeader('TODAY', titleColor),
          _buildMemberJoinRequest(cardColor, titleColor, accent),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.account_balance_wallet,
            iconColor: accent,
            title: 'Contribution received',
            subtitle: 'Sarah Kamau sent KES 5,000 to \'Emergency Fund\'',
            time: '45m ago',
            cardColor: cardColor,
            titleColor: titleColor,
            accent: accent,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('YESTERDAY', titleColor),
          _buildActivityCard(
            icon: Icons.payments_outlined,
            iconColor: Colors.amber,
            title: 'Payment disbursed',
            subtitle:
                'KES 20,000 has been sent to David Maina for monthly rotation.',
            time: '1d ago',
            cardColor: cardColor,
            titleColor: titleColor,
            accent: accent,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: 'Monthly statement ready',
            subtitle:
                'Your June summary for \'Education Fund\' is now available for review.',
            time: '1d ago',
            cardColor: cardColor,
            titleColor: titleColor,
            accent: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildPushToggle(Color cardColor, Color titleColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_active, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Receive group activity alerts',
                  style: TextStyle(
                    color: titleColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: true, onChanged: (v) {}, activeColor: accent),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: titleColor.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMemberJoinRequest(
    Color cardColor,
    Color titleColor,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=john',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New member join request',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2m ago',
                          style: TextStyle(
                            color: titleColor.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: titleColor.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'John Doe ',
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: 'wants to join '),
                          TextSpan(
                            text: '\'Chama Bora\'',
                            style: TextStyle(
                              color: titleColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titleColor.withOpacity(0.1),
                    foregroundColor: titleColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required Color cardColor,
    required Color titleColor,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: titleColor.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: titleColor.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
