import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
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
      backgroundColor: AppTheme.surface,
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
                    title: context.tr('personal_info'),
                    fields: {'full_name': _name, 'phone_label': _phone},
                  ),
                  _TemplateFormCard(
                    title: context.tr('workplace'),
                    fields: {
                      'organization_name': _company,
                      'position': _position,
                      'manager_name': _manager,
                    },
                  ),
                  _TemplateFormCard(
                    title: context.tr('application_info'),
                    fields: {
                      'resignation_date': _date,
                      'resignation_reason': _reason,
                    },
                  ),
                ],
              ),
            ),
            HeaderScreen(
              title: context.tr('resignation_application'),
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
              color: AppTheme.surface,
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
                            ? context.tr('full_name_hint')
                            : _name.text,
                        phone: _phone.text.trim().isEmpty
                            ? context.tr('phone_hint')
                            : _phone.text,
                        company: _company.text.trim().isEmpty
                            ? context.tr('company_hint')
                            : _company.text,
                        position: _position.text.trim().isEmpty
                            ? context.tr('position_hint')
                            : _position.text,
                        manager: _manager.text.trim().isEmpty
                            ? context.tr('manager_hint')
                            : _manager.text,
                        date: _date.text.trim().isEmpty
                            ? context.tr('date_hint')
                            : _date.text,
                        reason: _reason.text.trim().isEmpty
                            ? context.tr('reason_hint')
                            : _reason.text,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.color_FF2F80FF,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      context.tr('continue_button'),
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
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Image.asset('assets/images/info.png'),
            SizedBox(width: 8),
            Text(
              context.tr('resignation_application'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(
          context.tr('application_fill_instruction'),
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
      color: AppTheme.surface,
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
                Text(context.tr(entry.key), style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  controller: entry.value,
                  maxLines: entry.key == 'resignation_reason' ? 2 : 1,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: switch (entry.key) {
                      'phone_label' => context.tr('phone_hint'),
                      'resignation_date' => context.tr('date_hint'),
                      'resignation_reason' => context.tr('reason_hint'),
                      'full_name' => context.tr('full_name_hint'),
                      'organization_name' => context.tr('company_hint'),
                      'position' => context.tr('position_hint'),
                      _ => context.tr('manager_hint'),
                    },
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
                      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1),
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
