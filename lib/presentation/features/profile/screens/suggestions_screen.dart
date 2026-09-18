import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_selector/file_selector.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _suggestionController = TextEditingController();
  XFile? _selectedFile;

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.color_FFF4F8FE,
    body: SafeArea(
      child: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 88, 16, 90),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('upload_screenshot'),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.color_FFF4F8FE,
                          border: Border.all(color: AppTheme.color_FFDCE3EC),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/doc.svg'),
                            const SizedBox(height: 6),
                            Text(
                              _selectedFile?.name ?? context.tr('upload_here'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.color_FF475569,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(context.tr('comment'), style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _suggestionController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: context.tr('problem_short'),
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.color_FF8392A7,
                        ),
                        filled: true,
                        fillColor: AppTheme.color_FFF4F8FE,
                        contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: AppTheme.color_FFDCE3EC,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: AppTheme.color_FFDCE3EC,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            HeaderScreen(title: context.tr('suggestions')),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.color_FFE4E8EE)),
                ),
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.color_FF2F80FF,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      context.tr('submit_button'),
                      style: TextStyle(fontSize: 16, color: AppTheme.surface),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    final success = _suggestionController.text.trim().isNotEmpty;

    // TODO: Send the selected file and comment through the API.
    // final request = FormData.fromMap({
    //   'comment': _suggestionController.text.trim(),
    //   'file': await MultipartFile.fromFile(_selectedFile!.path),
    // });
    // await apiClient.post('/suggestions', data: request);

    await showDialog<void>(
      context: context,
      barrierColor: AppTheme.black54,
      builder: (_) => _SuggestionResultDialog(success: success),
    );
  }

  Future<void> _pickFile() async {
    try {
      final acceptedTypes = <XTypeGroup>[
        XTypeGroup(
          label: context.tr('upload_files'),
          extensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        ),
      ];
      final file = await openFile(acceptedTypeGroups: acceptedTypes);

      if (!mounted || file == null) return;
      setState(() => _selectedFile = file);
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('file_select_failed'))),
      );
    }
  }
}

class _SuggestionResultDialog extends StatelessWidget {
  final bool success;

  const _SuggestionResultDialog({required this.success});

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.color_FFF1F5F9,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.close, size: 15, color: AppTheme.color_FF334155),
              ),
            ),
          ),

          // Kontent qismi
          CustomIconDesign(
            icon: success
                ? 'assets/icons/marked_success.svg'
                : 'assets/icons/failed.svg',
            mainColor: success ? AppTheme.color_FF15985B : AppTheme.color_FFCE040E,
            secondaryColor: success ? AppTheme.color_FF40DB93 : AppTheme.color_FFFF666D,
            padding: 18,
          ),
          const SizedBox(height: 16),
          Text(
            success
                ? context.tr('suggestion_sent')
                : context.tr('suggestion_failed'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (success) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('suggestion_thanks'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.color_FFF1F5F9,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                success ? context.tr('back_home') : context.tr('back'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
