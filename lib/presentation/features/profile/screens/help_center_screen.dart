import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
              const HeaderScreen(title: 'Yordam markazi'),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tez-tez so‘raladiganlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            _Question(title: 'Qabulga yozilish', answer: 'Qabulga yozilish uchun kerakli advokatni tanlang va xizmat turini belgilang.'),
            _Question(title: 'Qabulni bekor qilish', answer: 'Qabul tafsilotlarini ochib, bekor qilish tugmasini bosing.'),
            _Question(title: 'Dorilar eslatmasi', answer: 'Kerakli eslatmani bildirishnomalar bo‘limidan sozlashingiz mumkin.'),
            _Question(title: 'To‘lovlar', answer: 'To‘lovlar tarixi profilingizdagi tegishli bo‘limda ko‘rsatiladi.'),
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
      color: const Color(0xFFFAF9F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(width: 1, color: Color(0xffE2E8F0))
    ),
    child: Theme(
      // Removes the ripple splash effect on click
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        shape: const Border(),
        iconColor: Color(0xff475569),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
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