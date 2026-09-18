import '../../../../core/theme/app_theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../widgets/custom_icon_design.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _timerSeconds = 30;
  Timer? _timer;
  Timer? _bannerTimer;
  bool _canResend = false;
  bool _incorrectCode = false;
  bool _showErrorBanner = false;
  double _progress = 0.5;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startSmsAutofill();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerTimer?.cancel();
    cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _startSmsAutofill() async {
    try {
      listenForCode(smsCodeRegexPattern: r'\b\d{4}\b');
    } catch (error) {
      debugPrint('[SMS autofill] listener unavailable: $error');
    }

    try {
      final signature = await SmsAutoFill().getAppSignature;
      debugPrint('[SMS autofill] app signature: $signature');
    } catch (error) {
      debugPrint('[SMS autofill] app signature unavailable: $error');
    }
  }

  @override
  void codeUpdated() {
    final match = RegExp(r'\b\d{4}\b').firstMatch(code ?? '');
    final receivedCode = match?.group(0);
    if (receivedCode == null || !mounted) return;

    for (var index = 0; index < _controllers.length; index++) {
      _controllers[index].value = TextEditingValue(
        text: receivedCode[index],
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    setState(() {
      _incorrectCode = false;
      _showErrorBanner = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _submitOtp(context.read<AuthViewModel>());
      }
    });
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final localizations = AppLocalizations.of(context);

    final phone = widget.phoneNumber
        .replaceFirst('+998', '')
        .replaceAll(RegExp(r'\D'), '');
    final formattedPhone = phone.length == 9
        ? '+998 ${phone.substring(0, 2)} ${phone.substring(2, 5)} ${phone.substring(5, 7)} ${phone.substring(7)}'
        : widget.phoneNumber;
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
                  mainColor: AppTheme.color_FF1C8AFF,
                  secondaryColor: AppTheme.color_FF69AFFF,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('otp_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.color_FF0F172A,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$formattedPhone ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.color_FF0F172A,
                          ),
                        ),
                        TextSpan(
                          text: context.tr('otp_sent_to'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.color_FF475569,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: List.generate(4, (index) => _buildPinField(index)),
                ),
                const SizedBox(height: 16),
                if (!_canResend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr('otp_resend')} ',
                        style: TextStyle(
                          color: AppTheme.color_FF475569,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(_timerSeconds),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.color_FF0F172A,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('otp_resend_prompt'),
                        style: TextStyle(
                          color: AppTheme.color_FF475569,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await viewModel.sendOtp(widget.phoneNumber);
                          _startTimer();
                        },
                        child: Text(
                          context.tr('otp_resend'),
                        ),
                      ),
                    ],
                  ),
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
                      AppTheme.color_FF2B7FFF,
                      AppTheme.color_FF2B7FFF,
                      AppTheme.surface,
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
                    color: AppTheme.surface,
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
                            ? AppTheme.color_FF2B7FFF
                            : AppTheme.color_FF2B7FFF.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: viewModel.status == AuthStatus.loading
                            ? const CircularProgressIndicator(color: AppTheme.surface) : Text(
                          context.tr('verify_button'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.surface,
                          ),
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
                    colors: [AppTheme.surface, AppTheme.color_FFD9B875],
                    stops: [0.5, 1.0],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
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
      color: AppTheme.surface,
      surfaceTintColor: AppTheme.transparent,
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
              color: isSelected ? AppTheme.color_FFEFF6FF : AppTheme.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppTheme.color_FFBEDBFF
                    : AppTheme.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(language['flag']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  context.tr('language_$code'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.color_FF0F172A,
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
      Navigator.pushReplacementNamed(
        context,
        '/user-info',
        arguments: widget.phoneNumber,
      );
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
          cursorColor: AppTheme.color_FF2B7FFF,
          textAlignVertical: TextAlignVertical.center,

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.color_FF0F172A,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppTheme.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            hintText: (isFocused || hasValue) ? '' : '•',
            hintStyle: const TextStyle(
              color: AppTheme.color_FFCBD5E1,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? AppTheme.color_FFFF0000
                    : hasValue
                    ? AppTheme.color_FF2B7FFF
                    : AppTheme.color_FFE2E8F0,
                width: hasError ? 1.5 : 1,
              ),
            ),

            // Active blue border matches exact full height
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? AppTheme.color_FFFF0000
                    : AppTheme.color_FF2B7FFF,
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
      color: AppTheme.transparent,
      elevation: 8,
      shadowColor: AppTheme.black38,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
        decoration: BoxDecoration(
          color: AppTheme.color_FFF00012,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.surface, size: 22),
                SizedBox(width: 8),
                Text(
                  context.tr('otp_invalid_title'),
                  style: TextStyle(
                    color: AppTheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              context.tr('otp_invalid_message'),
              style: TextStyle(
                color: AppTheme.surface,
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
          colors: [AppTheme.surface, AppTheme.color_FFD9B875],
          stops: [0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
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
