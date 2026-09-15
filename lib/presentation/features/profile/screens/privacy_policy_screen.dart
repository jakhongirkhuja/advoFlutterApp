import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
                children: const [
                  _PolicyCard(),
                ],
              ),
              const HeaderScreen(title: 'Maxfiylik siyosati'),
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
        child: const Text(
          'Oxirgi yangilangan sana: 8-sentabr, 2026-yil\n'
          'ADVO foydalanuvchilarining shaxsiy ma’lumotlarini himoya qilish va ulardan foydalanish tartibini belgilaydi.\n\n'
          '1. Biz qanday ma’lumotlarni yig‘amiz?\n'
          '• Ism va familiya\n'
          '• Telefon raqami va elektron pochta manzili\n'
          '• Profil ma’lumotlari\n'
          '• Joylashuv ma’lumotlari\n\n'
          '2. Ma’lumotlardan qanday foydalanamiz?\n'
          '• ADVO xizmatlarini taqdim etish va yaxshilash;\n'
          '• Foydalanuvchi akkauntini boshqarish;\n'
          '• Xavfsizlikni ta’minlash;\n'
          '• Ilova haqida muhim xabarlarni yuborish.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.25),
        ),
      );
}
