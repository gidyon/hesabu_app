import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logos/logonong.png',
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the icon if the image asset is not found
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(size * 0.25),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
                size: size * 0.5,
              ),
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'Hesabu Online',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
