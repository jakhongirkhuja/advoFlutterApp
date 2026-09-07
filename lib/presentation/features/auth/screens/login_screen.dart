import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter/services.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _termsAccepted = false;
  bool _isValidPhone = false;

  late MaskTextInputFormatter _maskFormatter;
  String _currentMask = '## ### ## ##';
  int _minLength = 9;

  @override
  void initState() {
    super.initState();
    // Initialize with UZ mask from libphonenumber metadata
    final uzCountry = CountryManager().countries.firstWhere(
      (c) => c.countryCode == 'UZ',
      orElse: () => const CountryWithPhoneCode.us(),
    );
    String rawMask = uzCountry.phoneMaskMobileNational;
    _currentMask = rawMask.replaceAll('0', '#');
    _minLength = 9;
    
    _maskFormatter = MaskTextInputFormatter(
      mask: _currentMask,
      filter: {"#": RegExp(r'[0-9]')},
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateMask(String countryCode, int min) {
    // Get real mask from flutter_libphonenumber metadata
    final country = CountryManager().countries.firstWhere(
      (c) => c.countryCode == countryCode,
      orElse: () => const CountryWithPhoneCode.us(),
    );
    
    String newMask = country.phoneMaskMobileNational.replaceAll('0', '#');

    setState(() {
      _phoneController.clear();
      _completePhoneNumber = '';
      _isValidPhone = false;
      _currentMask = newMask;
      _minLength = min;
      _maskFormatter.updateMask(mask: _currentMask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE7F1FF),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations?.translate('welcome_title') ?? 'Xush kelibsiz!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations?.translate('login_subtitle') ?? 'Davom etish uchun telefon raqamingizni kiriting.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              IntlPhoneField(
                controller: _phoneController,
                initialCountryCode: 'UZ',
                inputFormatters: [_maskFormatter],
                disableLengthCheck: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: localizations?.translate('phone_hint') ?? '111 11 11',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: const TextStyle(height: 0), // Hide redundant internal error
                ),
                languageCode: localizations?.locale.languageCode ?? 'uz',
                onChanged: (phone) {
                  setState(() {
                    _completePhoneNumber = phone.completeNumber;
                    final digitsOnly = phone.number.replaceAll(RegExp(r'\D'), '');
                    // Validation: check if the number of digits is valid for this country
                    _isValidPhone = digitsOnly.length >= _minLength;
                  });
                },
                onCountryChanged: (country) {
                  _updateMask(country.code, country.minLength);
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    visualDensity: VisualDensity(vertical: -4),
                    value: _termsAccepted,
                    onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                    activeColor: const Color(0xFF0056B3),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: ()=>{
                        setState(() => _termsAccepted = !_termsAccepted ),
                      },
                      child: Text(
                        localizations?.translate('terms_and_privacy') ?? 'Foydalanish shartlari va Maxfiylik siyosatini qabul qilaman.',
                        style: TextStyle(fontSize: 16, color: Color(0xff4B5563)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _termsAccepted && _isValidPhone
                    ? () async {
                        final otp = await viewModel.sendOtp(_completePhoneNumber);
                        
                        if (otp != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('OTP kod: $otp'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 10),
                              action: SnackBarAction(
                                label: localizations?.translate('copy') ?? 'Copy',
                                textColor: Colors.white,
                                onPressed: () async{
                                  await Clipboard.setData(ClipboardData(text: otp));

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

                        if (context.mounted) {
                          Navigator.pushNamed(context, AppRouter.otp,arguments: _completePhoneNumber,);
                        }
                      }
                    : null,
                child: viewModel.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(localizations?.translate('continue') ?? 'Davom etish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
