import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'header_navigation.dart';

class HeaderScreen extends StatelessWidget {
  final String title;

  final bool showBackIcon;
  final String? backIconPath;
  final VoidCallback? onBackTap;

  final String? firstActionIconPath;
  final VoidCallback? onFirstActionTap;
  final String? secondActionIconPath;
  final VoidCallback? onSecondActionTap;

  const HeaderScreen({
    super.key,
    required this.title,
    this.showBackIcon = true,
    this.backIconPath = 'assets/icons/back.svg',
    this.onBackTap,
    this.firstActionIconPath,
    this.onFirstActionTap,
    this.secondActionIconPath,
    this.onSecondActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFirstAction = firstActionIconPath != null;
    final bool hasSecondAction = secondActionIconPath != null;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.pageBackground,
              const Color(0xFFF5F5F5).withValues(alpha: 0.4),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            if (showBackIcon && backIconPath != null)
              HeaderNavigation(
                firstIconPath: backIconPath!,
                moveBack: true,
                firstIconOnTap: onBackTap ?? () => Navigator.maybePop(context),
              ),

            Expanded(
              child: Text(
                title,
                textAlign: showBackIcon? TextAlign.center  : TextAlign.left,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),


            if (hasFirstAction)
              HeaderNavigation(
                firstIconPath: firstActionIconPath!,
                firstIconOnTap: onFirstActionTap ?? () {},
                secondIconPath: hasSecondAction ? secondActionIconPath : null,
                secondIconOnTap: hasSecondAction ? onSecondActionTap : null,
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}