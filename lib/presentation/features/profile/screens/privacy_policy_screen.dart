import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/header_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBackground,
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
                children: [
                  _PolicyCard(),
                ],
              ),
              HeaderScreen(title: context.tr('privacy_policy')),
            ],
          ),
        ),
      );
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          context.tr('privacy_content'),
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.25),
        ),
      );
}
