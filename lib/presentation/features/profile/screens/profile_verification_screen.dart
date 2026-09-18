import 'dart:io';

import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/advokat_repository.dart';
import '../../../widgets/header_screen.dart';

enum _VerificationStatus { notUploaded, ready, underReview, verified, rejected }

class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  State<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  bool _isSubmitting = false;
  final Map<String, XFile?> _files = {
    'passport_front': null,
    'passport_back': null,
    'selfie_with_document': null,
  };
  final Map<String, _VerificationStatus> _statuses = {
    'passport_front': _VerificationStatus.notUploaded,
    'passport_back': _VerificationStatus.notUploaded,
    'selfie_with_document': _VerificationStatus.notUploaded,
  };

  bool _isVerified(String title) =>
      _statuses[title] == _VerificationStatus.verified;

  Future<void> _pickFile(String title) async {
    if (_isVerified(title)) return;

    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: context.tr('upload_files'),
          extensions: ['jpg', 'jpeg', 'png'],
        ),
      ],
    );
    if (!mounted || file == null) return;
    setState(() {
      _files[title] = file;
      _statuses[title] = _VerificationStatus.ready;
    });
  }

  Future<void> _submitFiles() async {
    final front = _files['passport_front'];
    final back = _files['passport_back'];
    final selfie = _files['selfie_with_document'];
    if (front == null || back == null || selfie == null || _isSubmitting)
      return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<AdvokatRepository>().submitVerification(
        passportFront: File(front.path),
        passportBack: File(back.path),
        selfie: File(selfie.path),
      );
      if (!mounted) return;
      setState(() {
        for (final title in _files.keys) {
          _statuses[title] = _VerificationStatus.underReview;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('suggestion_failed'))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.surface,
    body: SafeArea(
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AppTheme.pageBackground),
          ),
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 66, 12, 94),
              children: [
                Column(
                  children: [
                    CustomIconDesign(
                      icon: 'assets/icons/verify.svg',
                      mainColor: AppTheme.color_FF15985B,
                      secondaryColor: AppTheme.color_FF40DB93,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Profilingizni tasdiqlang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hujjatlaringizni yuklang va ADVO’da\nko‘proq imkoniyatlardan foydalaning.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 29),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: _files.keys
                        .map(
                          (title) => _UploadCard(
                            title: title,
                            file: _files[title],
                            status: _statuses[title]!,
                            onTap: _isVerified(title)
                                ? null
                                : () => _pickFile(title),
                            icon: 'assets/icons/document_upload.svg',
                          ),
                        )
                        .toList(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/info.png'),
                          Text(
                            context.tr('verification_note'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        spacing: 6,
                        children: [
                          SvgPicture.asset('assets/icons/note_ok.svg'),
                          Text(
                            context.tr('verification_tip_clear'),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.color_FF334155,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        spacing: 6,
                        children: [
                          SvgPicture.asset('assets/icons/note_ok.svg'),
                          Text(
                            context.tr('verification_tip_selfie'),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.color_FF334155,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        spacing: 6,
                        children: [
                          SvgPicture.asset('assets/icons/note_fail.svg'),
                          Text(
                            context.tr('verification_tip_rejected'),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.color_FF334155,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 5),
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SvgPicture.asset(
                              'assets/icons/note_key.svg',
                            ),
                          ),
                        ),
                        TextSpan(
                          text: context.tr('verification_security'),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  context.tr('verification_time'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          HeaderScreen(title: context.tr('verification')),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed:
                      !_isSubmitting &&
                          _files.values.every((file) => file != null)
                      ? _submitFiles
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.color_FF2F80FF,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.surface,
                          ),
                        )
                      : Text(
                          context.tr('submit_button'),
                          style: const TextStyle(fontSize: 16),
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

class _UploadCard extends StatelessWidget {
  final String title;
  final XFile? file;
  final _VerificationStatus status;
  final String icon;
  final VoidCallback? onTap;

  const _UploadCard({
    required this.title,
    required this.file,
    required this.status,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.only(bottom: 6),
    child: Opacity(
      opacity: onTap == null ? 0.65 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),

          decoration: BoxDecoration(
            color: AppTheme.pageBackground,
            border: Border.all(color: AppTheme.color_FFF8FAFC),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppTheme.color_FFF1F5F9),
                padding: EdgeInsets.all(6),
                child: SvgPicture.asset(icon, width: 18, height: 18),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(title),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                file?.name ?? 'Rasmni shu yerga yuklang',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _StatusLabel(status: status),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  final _VerificationStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      _VerificationStatus.notUploaded => (
        'Yuklanmagan',
        AppTheme.textSecondary,
        Icons.upload_file,
      ),
      _VerificationStatus.ready => (
        'Yuklashga tayyor',
        AppTheme.color_FF2F80FF,
        Icons.check_circle_outline,
      ),
      _VerificationStatus.underReview => (
        'Tekshirilmoqda',
        AppTheme.color_FFF59E0B,
        Icons.hourglass_empty,
      ),
      _VerificationStatus.verified => (
        'Tasdiqlangan',
        AppTheme.color_FF15985B,
        Icons.verified,
      ),
      _VerificationStatus.rejected => (
        'Rad etilgan',
        AppTheme.color_FFDC2626,
        Icons.error_outline,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
