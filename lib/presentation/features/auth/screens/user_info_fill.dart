import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_icon_design.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/localization/locale_provider.dart';

class UserInfoFill extends StatefulWidget {
  final String phoneNumber;

  const UserInfoFill({super.key, required this.phoneNumber});

  @override
  State<UserInfoFill> createState() => _UserInfoFillState();
}

class _UserInfoFillState extends State<UserInfoFill>  {
  final List<TextEditingController> _controllers = List.generate(
    4,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _bannerTimer;
  bool _incorrectCode = false;
  bool _showErrorBanner = false;
  double _progress = 0.5;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final canVerify = _controllers.every((controller) => controller.text.isNotEmpty);
    final canSubmit = canVerify && viewModel.status != AuthStatus.loading;
    final progress = _progress;
    return Scaffold(

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                CustomIconDesign(
                  icon: 'assets/icons/otp.svg',
                  mainColor: const Color(0xff1C8AFF),
                  secondaryColor: const Color(0xff69AFFF),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profilingizni yarating',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Davom etish uchun ism va familiyangizni kiriting.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),


              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF2B7FFF),
                      const Color(0xFF2B7FFF),
                      Colors.white,
                    ],
                    stops: [
                      0.0,
                      progress.clamp(0.0, 1.0),
                      ((progress + 0.1) + 0.05).clamp(0.0, 1.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: canSubmit
                        ? () => _submitOtp(viewModel)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(57),
                        color: canSubmit
                            ? const Color(0xFF2B7FFF)
                            : const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: viewModel.status == AuthStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white) : const Text(
                          'Davom etish',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 16,
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(47),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFD9B875)],
                    stops: [0.5, 1.0],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(47),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: SvgPicture.asset('assets/icons/back.svg'),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: _OtpLanguageButton(onTap: () => _chooseLanguage(context)),
            ),
            if (_showErrorBanner)
              const Positioned(
                top: 40,
                left: 36,
                right: 36,
                child: _IncorrectCodeBanner(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      // Set position explicitly 65px from the top
      position: RelativeRect.fromLTRB(
        overlay.size.width,
        105.0,
        22.0,
        overlay.size.height,
      ),
      menuPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      popUpAnimationStyle: AnimationStyle.noAnimation,
      items: LocaleProvider.supportedLanguages.map((language) {
        final code = language['code']!;
        final isSelected = code == localeProvider.currentLanguageCode;

        return PopupMenuItem<String>(
          value: code,
          height: 48,
          padding: EdgeInsets.zero, // Remove default Flutter menu item padding
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFBEDBFF)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(language['flag']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  code == 'uz'
                      ? 'O’zbek tili'
                      : code == 'ru'
                      ? 'Rus tili'
                      : 'Ingliz tili',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null && context.mounted) {
      await localeProvider.setLocale(Locale(selected));
    }
  }

  Future<void> _submitOtp(AuthViewModel viewModel) async {
    final firstEmpty = _controllers.indexWhere((controller) => controller.text.isEmpty);
    if (firstEmpty != -1) {
      _focusNodes[firstEmpty].requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    await viewModel.verifyOtp(
      _controllers.map((controller) => controller.text).join(),
      phoneNumber: widget.phoneNumber,
    );

    if (!mounted) return;
    if (viewModel.status == AuthStatus.authenticated) {
      setState(() => _progress = 1.0);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _incorrectCode = true;
      _showErrorBanner = true;
    });
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showErrorBanner = false);
    });
  }

  Widget _buildPinField(int index) {
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool hasValue = _controllers[index].text.isNotEmpty;
    final bool hasError = _incorrectCode;

    return SizedBox(
      width: 50,
      height: 58,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].selection = TextSelection.collapsed(
              offset: _controllers[index - 1].text.length,
            );
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          textAlign: TextAlign.center,
          maxLength: 1,
          cursorColor: const Color(0xFF2B7FFF),
          textAlignVertical: TextAlignVertical.center,

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            hintText: (isFocused || hasValue) ? '' : '•',
            hintStyle: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFFF0000)
                    : hasValue
                    ? const Color(0xFF2B7FFF)
                    : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1,
              ),
            ),

            // Active blue border matches exact full height
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFFF0000)
                    : const Color(0xFF2B7FFF),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) {
            if (hasError) {
              _incorrectCode = false;
              _showErrorBanner = false;
            }
            if (value.isNotEmpty && index < _controllers.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].selection = TextSelection.collapsed(
                offset: _controllers[index - 1].text.length,
              );
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}

class _IncorrectCodeBanner extends StatelessWidget {
  const _IncorrectCodeBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF00012),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Kod noto‘g‘ri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Kiritilgan tasdiqlash kodi noto‘g‘ri. Iltimos, qaytadan urinib ko‘ring.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpLanguageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OtpLanguageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<LocaleProvider>().currentLanguageCode;
    final language = LocaleProvider.supportedLanguages.firstWhere(
          (item) => item['code'] == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(47),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFD9B875)],
          stops: [0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(47),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              language['flag']!,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
