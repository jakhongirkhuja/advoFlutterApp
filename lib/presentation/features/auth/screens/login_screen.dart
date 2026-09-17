import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey _languageKey = GlobalKey();
  String _completePhoneNumber = '';
  bool _termsAccepted = false;
  bool _isValidPhone = false;

  late final MaskTextInputFormatter _maskFormatter;

  @override
  void initState() {
    super.initState();
    _maskFormatter = MaskTextInputFormatter(
      mask: '##-###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final button =
    _languageKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    if (button == null) return;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: LocaleProvider.supportedLanguages.map((language) {
        final code = language['code']!;
        return PopupMenuItem<String>(
          value: code,
          height: 34,
          child: Row(
            children: [
              Text(language['flag']!, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                code == 'uz'
                    ? 'O‘zbek tili'
                    : code == 'ru'
                    ? 'Rus tili'
                    : 'Ingliz tili',
                style: const TextStyle(fontSize: 11),
              ),
              if (code == localeProvider.currentLanguageCode) ...[
                const Spacer(),
                const Icon(Icons.check, size: 15, color: Color(0xFF2B7FFF)),
              ],
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && context.mounted) {
      await localeProvider.setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                CustomIconDesign(icon: 'assets/icons/login_user.svg',
                    mainColor: Color(0xff1C8AFF),
                    secondaryColor: Color(0xff69AFFF)),
                const SizedBox(height: 17),
                Text(
                  'Ro‘yxatdan o‘tish',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0F172A)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tasdiqlash kodini yuborish uchun telefon raqamingizni kiriting.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('+998', style: TextStyle(fontSize: 16, color: Color(0xff0F172A))),
                      ),
                      const VerticalDivider(
                        width: 1,
                        indent: 12,
                        endIndent: 12,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,

                          inputFormatters: [_maskFormatter],
                          onChanged: (value) =>
                              setState(() {
                                _completePhoneNumber =
                                '+998${value.replaceAll(RegExp(r'\D'), '')}';
                                _isValidPhone =
                                    value
                                        .replaceAll(RegExp(r'\D'), '')
                                        .length ==
                                        9;
                              }),
                          decoration: const InputDecoration(
                            hintText: '99-999-99-99',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: TextStyle(
                              fontSize: 16
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _termsAccepted = !_termsAccepted);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                          margin: EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _termsAccepted ? const Color(0xFF2F80ED) : Colors.transparent,
                          border: Border.all(
                            color: _termsAccepted
                                ? const Color(0xFF2F80ED)
                                : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                        ),
                        child: _termsAccepted
                            ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _termsAccepted = !_termsAccepted);
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Maxfiylik siyosati',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const TextSpan(
                                text: ' tanishib chiqdim',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _termsAccepted && _isValidPhone
                          ? () async {
                        final otp = await viewModel.sendOtp(
                          _completePhoneNumber,
                        );

                        if (otp != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('OTP kod: $otp'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 10),
                              action: SnackBarAction(
                                label:
                                localizations?.translate(
                                  'copy',
                                ) ??
                                    'Copy',
                                textColor: Colors.white,
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: otp),
                                  );

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localizations?.translate(
                                          'copied',
                                        ) ??
                                            'Copied',
                                      ),
                                      duration: const Duration(
                                        seconds: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRouter.otp,
                            arguments: _completePhoneNumber,
                          );
                        }
                      }
                          : null,
                      child: viewModel.status == AuthStatus.loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        localizations?.translate('continue') ??
                            'Davom etish',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B7FFF),
                        disabledBackgroundColor: const Color(0xFFA9C9FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  onPressed: _termsAccepted && _isValidPhone
                      ? () async {
                    final otp = await viewModel.sendOtp(
                      _completePhoneNumber,
                    );
                    if (!context.mounted) return;
                    if (otp != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('OTP kod: $otp')),
                      );
                    }
                    Navigator.pushNamed(
                      context,
                      AppRouter.otp,
                      arguments: _completePhoneNumber,
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B7FFF),
                    disabledBackgroundColor: const Color(0xFFA9C9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Davom etish'),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _LanguageButton(
                key: _languageKey,
                onTap: () => _chooseLanguage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LanguageButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final code = context
        .watch<LocaleProvider>()
        .currentLanguageCode;
    final language = LocaleProvider.supportedLanguages.firstWhere(
          (item) => item['code'] == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
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
