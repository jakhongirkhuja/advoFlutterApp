import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';
import 'profile_template_preview_screen.dart';

class ProfileTemplateFormScreen extends StatefulWidget {
  const ProfileTemplateFormScreen({super.key});

  @override
  State<ProfileTemplateFormScreen> createState() =>
      _ProfileTemplateFormScreenState();
}

class _ProfileTemplateFormScreenState extends State<ProfileTemplateFormScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _position = TextEditingController();
  final _manager = TextEditingController();
  final _date = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _company,
      _position,
      _manager,
      _date,
      _reason,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const showSearchAction = true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppTheme.pageBackground),
            ),
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 62, 12, 74),
                children: [
                  const _TemplateIntroCard(),
                  _TemplateFormCard(
                    title: 'Shaxsiy ma’lumotlar',
                    fields: {'F.I.Sh.': _name, 'Telefon raqam': _phone},
                  ),
                  _TemplateFormCard(
                    title: 'Ish joyi',
                    fields: {
                      'Tashkilot nomi': _company,
                      'Lavozimingiz': _position,
                      'Rahbarning F.I.Sh.': _manager,
                    },
                  ),
                  _TemplateFormCard(
                    title: 'Ariza ma’lumotlari',
                    fields: {
                      'Ishdan bo‘shash sanasi': _date,
                      'Ishdan bo‘shash sababi (ixtiyoriy)': _reason,
                    },
                  ),
                ],
              ),
            ),
            HeaderScreen(
              title: 'Ishdan bo‘shash arizasi',
              firstActionIconPath: showSearchAction
                  ? 'assets/icons/search.svg'
                  : null,
              onFirstActionTap: showSearchAction
                  ? () => Navigator.pushNamed(context, AppRouter.search)
                  : null,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
            child: Container(
              color: Colors.white,
              height: 68,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileTemplatePreviewScreen(
                        name: _name.text.trim().isEmpty
                            ? 'Ism Familiya Otangizning ismi'
                            : _name.text,
                        phone: _phone.text.trim().isEmpty
                            ? '+998 90 123 45 67'
                            : _phone.text,
                        company: _company.text.trim().isEmpty
                            ? 'ABC MChJ'
                            : _company.text,
                        position: _position.text.trim().isEmpty
                            ? 'Menejer'
                            : _position.text,
                        manager: _manager.text.trim().isEmpty
                            ? 'Rahbarning ism-familiyasi'
                            : _manager.text,
                        date: _date.text.trim().isEmpty
                            ? '01.01.2026'
                            : _date.text,
                        reason: _reason.text.trim().isEmpty
                            ? 'Shaxsiy sabablar'
                            : _reason.text,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Davom etish',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateIntroCard extends StatelessWidget {
  const _TemplateIntroCard();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Image.asset('assets/images/info.png'),
            SizedBox(width: 8),
            Text(
              'Ishdan bo‘shash arizasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(
          'Arizani tayyorlash uchun quyidagi ma’lumotlarni kiriting.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    ),
  );
}

class _TemplateFormCard extends StatelessWidget {
  final String title;
  final Map<String, TextEditingController> fields;

  const _TemplateFormCard({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        ...fields.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  controller: entry.value,
                  maxLines: entry.key.contains('sababi') ? 2 : 1,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: entry.key == 'Telefon raqam'
                        ? '+998 __ ___ __ __'
                        : entry.key == 'Ishdan bo‘shash sanasi'
                        ? 'Masalan: ABC MChJ'
                        : entry.key.contains('sababi')
                        ? 'Sababni kiriting...'
                        : entry.key == 'F.I.Sh.'
                        ? 'Ism Familiya Otangizning ismi'
                        : entry.key == 'Tashkilot nomi'
                        ? 'Masalan: ABC MChJ'
                        : entry.key == 'Lavozimingiz'
                        ? 'Masalan: Menejer'
                        : 'Rahbarning ism-familiyasi',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.pageBackground,
                    contentPadding: const EdgeInsets.all(9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
