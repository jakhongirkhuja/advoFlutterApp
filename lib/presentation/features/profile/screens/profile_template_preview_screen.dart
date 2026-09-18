import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/header_screen.dart';

class ProfileTemplatePreviewScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String company;
  final String position;
  final String manager;
  final String date;
  final String reason;

  const ProfileTemplatePreviewScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.company,
    required this.position,
    required this.manager,
    required this.date,
    required this.reason,
  });

  String _documentText(BuildContext context) => context
      .tr('document_template_body')
      .replaceAll('{name}', name)
      .replaceAll('{date}', date)
      .replaceAll('{company}', company)
      .replaceAll('{position}', position)
      .replaceAll('{manager}', manager)
      .replaceAll('{reason}', reason);

  @override
  Widget build(BuildContext context) {
    const showSearchAction = true;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 62, 12, 100),
                child: Container(
                  height: 366,
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                      child: Text(
                        _documentText(context),
                          style: const TextStyle(
                            fontSize: 6.2,
                            height: 1.25,
                            color: AppTheme.color_FF1E293B,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                          color: AppTheme.color_FFF1F5F9,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => showDialog<void>(
                              context: context,
                              builder: (_) => Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _documentText(context),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.open_in_full,
                                size: 14,
                                color: AppTheme.color_FF334155,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: const BoxDecoration(color: AppTheme.surface),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: BorderSide.none,
                          backgroundColor: AppTheme.color_FFF1F5F9,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/edit.svg'),
                            SizedBox(width: 6),
                            Text(
                              context.tr('edit_button'),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: AppTheme.color_FF2F80FF,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/upload.svg'),
                            SizedBox(width: 6),
                            Text(
                              context.tr('download_button'),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
