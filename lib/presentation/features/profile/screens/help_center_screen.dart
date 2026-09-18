import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/header_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBackground,
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
                children: const [
                  _HelpCard(),
                ],
              ),
              HeaderScreen(title: context.tr('help_center')),
            ],
          ),
        ),
      );
}

class _HelpCard extends StatelessWidget {
  const _HelpCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('faq'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            _Question(title: context.tr('appointment_booking'), answer: context.tr('appointment_booking_answer')),
            _Question(title: context.tr('cancel_appointment'), answer: context.tr('cancel_appointment_answer')),
            _Question(title: context.tr('reminder'), answer: context.tr('reminder_answer')),
            _Question(title: context.tr('payments'), answer: context.tr('payments_answer')),
          ],
        ),
      );
}

class _Question extends StatelessWidget {
  final String title;
  final String answer;
  const _Question({required this.title, required this.answer});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12),
    decoration: BoxDecoration(
      color: AppTheme.color_FFFAF9F8,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(width: 1, color: AppTheme.color_FFE2E8F0)
    ),
    child: Theme(
      // Removes the ripple splash effect on click
      data: Theme.of(context).copyWith(
        splashColor: AppTheme.transparent,
        highlightColor: AppTheme.transparent,
      ),
      child: ExpansionTile(
        shape: const Border(),
        iconColor: AppTheme.color_FF475569,
        backgroundColor: AppTheme.transparent,
        collapsedBackgroundColor: AppTheme.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        children: [
          Container(
            height: 1,
            margin: EdgeInsets.only(bottom: 12),
            color: AppTheme.textChoco.withValues(alpha: 0.2),
          ),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    ),
  );
}
