import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/header_screen.dart';
import 'profile_template_form_screen.dart';
import 'profile_template_preview_screen.dart';

class ProfileTemplatesScreen extends StatelessWidget {
  const ProfileTemplatesScreen({super.key});
  Future<void> _handleRefresh() async {
    // TODO: Add your refresh/data fetching logic here
    await Future.delayed(const Duration(seconds: 1));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              edgeOffset: 70,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppTheme.color_FFF1F5F9,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset('assets/icons/doc.svg'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                      ProfileTemplatePreviewScreen(
                                          name: context.tr('full_name_hint'),
                                          phone: '+998 90 123 45 67',
                                          company: context.tr('company_hint'),
                                          position: context.tr('position_hint'),
                                          manager: context.tr('manager_hint'),
                                          date: '01.01.2026',
                                          reason: context.tr('reason_hint'),
                                        ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('resignation_application'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2,),
                                    Row(
                                      children: [
                                        const Text(
                                          'DOCX',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.pageBackground,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        const Text(
                                          'PDF',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.pageBackground,
                            border: Border.all(color: AppTheme.color_FFE2E8F0),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            context.tr('template_description'),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
              
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          color: AppTheme.color_FFE2E8F0,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.color_FFE8FFF5,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.tr('purchased'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.color_FF00A86B,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ProfileTemplateFormScreen(),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.color_FF2B7FFF,
                                  borderRadius: BorderRadius.circular(42),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(context.tr('fill_button'), style:  TextStyle(color: AppTheme.surface, fontSize: 16),),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          HeaderScreen(title: context.tr('my_templates')),
        ],
      ),
    ),
  );
}

/*
  The form and preview are separate screens in profile_template_form_screen.dart.
*/
/*
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 62, 12, 74),
              children: const [
                _IntroCard(),
                _FormCard(title: context.tr('personal_info'), fields: ['F.I.Sh.', 'Telefon raqam']),
                _FormCard(title: context.tr('workplace'), fields: [context.tr('organization_name'), context.tr('position'), context.tr('manager_name')]),
                _FormCard(title: context.tr('application_info'), fields: [context.tr('resignation_date'), context.tr('resignation_reason')]),
              ],
            ),
          ),
          HeaderScreen(title: context.tr('resignation_application')),
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => setState(() => _page = 2),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.color_FF2F80FF, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                child: Text(context.tr('continue_button'), style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildPreview(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 62, 12, 70),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Text(
                  context.tr('document_template_body'),
                  style: TextStyle(fontSize: 10, height: 1.5),
                ),
              ),
            ),
          ),
          HeaderScreen(title: context.tr('resignation_application')),
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _page = 1), child: Text(context.tr('edit_button'), style: const TextStyle(fontSize: 10)))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: () {}, child: Text(context.tr('download_button'), style: const TextStyle(fontSize: 10)))),
            ]),
          ),
        ],
      ),
    ),
  );
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
    child: const Row(children: [
    CircleAvatar(radius: 16, backgroundColor: AppTheme.color_FFF1F5F9, child: Icon(Icons.description_outlined, size: 17, color: AppTheme.textSecondary)),
      SizedBox(width: 8),
      Text(context.tr('resignation_application'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _FormCard extends StatelessWidget {
  final String title;
  final List<String> fields;
  const _FormCard({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ...fields.map((field) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: TextField(
          maxLines: field.contains('sababi') ? 2 : 1,
          style: const TextStyle(fontSize: 10),
          decoration: InputDecoration(
            labelText: field,
            hintText: field == 'Telefon raqam' ? '+998 __ ___ __ __' : 'Ma’lumot kiriting...',
            labelStyle: const TextStyle(fontSize: 9),
            hintStyle: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
            isDense: true,
            filled: true,
            fillColor: AppTheme.pageBackground,
            contentPadding: const EdgeInsets.all(9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      )),
    ]),
  );
}
*/
