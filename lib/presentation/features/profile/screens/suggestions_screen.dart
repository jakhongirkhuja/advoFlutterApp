import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _suggestionController = TextEditingController();

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F8FE),
    body: SafeArea(
      child: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 88, 16, 90),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Skrinshotlarni yuklash',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(13),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FE),
                        border: Border.all(color: const Color(0xFFDCE3EC)),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/doc.svg'),
                          SizedBox(height: 6),
                          Text(
                            'Shu yerga yuklang',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Izoh', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _suggestionController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'Qisqacha izoh',
                        hintStyle: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8392A7),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F8FE),
                        contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: Color(0xFFDCE3EC),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: Color(0xFFDCE3EC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const HeaderScreen(title: 'Ilova bo‘yicha takliflar'),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE4E8EE))),
                ),
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'Yuborish',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SuggestionResultDialog(success: success),
    );
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
        color: Colors.white,
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.close, size: 15, color: Color(0xFF334155)),
              ),
            ),
          ),

          // Kontent qismi
          CustomIconDesign(
            icon: success
                ? 'assets/icons/marked_success.svg'
                : 'assets/icons/failed.svg',
            mainColor: success ? const Color(0xFF15985B) : const Color(0xffCE040E),
            secondaryColor: success ? const Color(0xFF40DB93) : const Color(0xffFF666D),
            padding: 18,
          ),
          const SizedBox(height: 16),
          Text(
            success
                ? 'Taklifingiz muvaffaqiyatli yuborildi'
                : 'Xatolik yuz berdi qayta \nurinib ko’ring',
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
            const Text(
              'Sizning taklifingiz, ilovamiz rivojlanishiga\nhissa qo‘shadi, Rahmat!',
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
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                success ? 'Bosh sahifaga o‘tish' : 'Ortga',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
