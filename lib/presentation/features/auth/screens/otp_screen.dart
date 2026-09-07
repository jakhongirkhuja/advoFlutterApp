import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/localization/app_localizations.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 92,
                width: 92,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 92,
                  width: 92,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE7F1FF),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Color(0xFF0056B3),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations?.translate('otp_title') ?? 'Tasdiqlash kodi',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                localizations?.translate('otp_subtitle') ??
                    'SMS orqali yuborilgan 6 xonali kodni kiriting.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...List.generate(3, (index) => _buildPinField(index)),

                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Container(
                      width: 20,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  ...List.generate(3, (index) => _buildPinField(index + 3)),
                ],
              ),
              const SizedBox(height: 22),
              if (!_canResend)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    InkWell(
                      onTap: () => {},
                      child: Text(
                        localizations?.translate('resend_code') ??
                            'Qayta yuborish',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_timerSeconds),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              else
                TextButton(
                  onPressed: () async {
                    final otp = await viewModel.sendOtp(widget.phoneNumber);
                    _startTimer();
                    if (otp != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('OTP kod: $otp'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 10),
                          action: SnackBarAction(
                            label: localizations?.translate('copy') ?? 'Copy',
                            textColor: Colors.white,
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: otp));

                              // Optional: Show feedback to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations?.translate('copied') ??
                                        'Copied',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    localizations?.translate('resend_code') ?? 'Qayta yuborish',
                    style: const TextStyle(
                      color: Color(0xFF0056B3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    _controllers.every((c) => c.text.isNotEmpty) &&
                        viewModel.status != AuthStatus.loading
                    ? () async {
                        String otp = _controllers.map((c) => c.text).join();
                        await viewModel.verifyOtp(otp);
                        if (context.mounted &&
                            viewModel.status == AuthStatus.authenticated) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      }
                    : null,
                child: viewModel.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        localizations?.translate('verify_code') ??
                            'Kodni tasdiqlash',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(int index) {
    // Check if this specific field is currently focused to change border state
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      width: 50,
      height: 64,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey, // Matching the dull grey text color in your image
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          // Active/Focused field has white background, matching your image's active state
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero, // Centers text perfectly vertically
          // Active border configuration (Blue outline)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              4,
            ), // Slightly sharp corners like the image
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),

          // Default unselected border configuration (No outline, soft round look)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Smoother rounding for inactive fields
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(
            () {},
          ); // Refreshes state to toggle active border colors instantly
        },
      ),
    );
  }
}
