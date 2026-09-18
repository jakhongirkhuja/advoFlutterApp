import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_icon_design.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _timerSeconds = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
    final canVerify = _controllers.every((c) => c.text.isNotEmpty);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 92),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CustomIconDesign(
                    icon: 'assets/icons/otp.svg',
                    mainColor: const Color(0xff1C8AFF),
                    secondaryColor: const Color(0xff69AFFF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations?.translate('otp_title') ?? 'Kodni kiriting',
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
                          text: '$formattedPhone ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextSpan(
                          text: 'raqamiga yuborilgan 4 xonali kodni kiriting.',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: List.generate(
                      4,
                      (index) => _buildPinField(index),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_canResend)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Qayta yuborish ',style: TextStyle(
                          color: Color(0xff475569),
                          fontSize: 16
                        ),),
                        Text(
                          '${_formatTime(_timerSeconds)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Kodni olmadingizmi?', style: TextStyle(
                          color: Color(0xff475569),
                          fontSize: 16
                        ),),
                        TextButton(

                          onPressed: () async {
                            await viewModel.sendOtp(widget.phoneNumber);
                            _startTimer();
                          },
                          child: const Text('Qayta yuborish'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 62,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ElevatedButton(
                  onPressed: canVerify && viewModel.status != AuthStatus.loading
                      ? () async {
                          await viewModel.verifyOtp(
                            _controllers.map((c) => c.text).join(),
                          );
                          if (context.mounted &&
                              viewModel.status == AuthStatus.authenticated) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B7FFF),
                    disabledBackgroundColor: const Color(0xFFA9C9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: viewModel.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kodni tasdiqlash'),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _OtpLanguageButton(onTap: () => _chooseLanguage(context)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final provider = context.read<LocaleProvider>();
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tilni tanlang'),
        children: LocaleProvider.supportedLanguages
            .map(
              (item) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, item['code']),
                child: Text('${item['flag']}  ${item['name']}'),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && context.mounted)
      await provider.setLocale(Locale(selected));
  }

  Widget _buildPinField(int index) {
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool hasValue = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 50,
      height: 58,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
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
              color: hasValue ? const Color(0xFF2B7FFF) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),

          // Active blue border matches exact full height
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
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
