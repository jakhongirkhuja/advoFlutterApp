import '../../../../core/theme/app_theme.dart';
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
  double _progress = 0.2;

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final localizations = AppLocalizations.of(context);
    final progress = _progress;
    final canContinue = _termsAccepted && _isValidPhone;
    return Scaffold(
      backgroundColor: AppTheme.color_FFF2F6FA,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                CustomIconDesign(
                  icon: 'assets/icons/login_user.svg',
                  mainColor: AppTheme.color_FF1C8AFF,
                  secondaryColor: AppTheme.color_FF69AFFF,
                ),
                const SizedBox(height: 17),
                Text(
                  context.tr('signup_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.color_FF0F172A,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('phone_number_prompt'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.color_FF475569,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '+998',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.color_FF0F172A,
                          ),
                        ),
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
                          onChanged: (value) => setState(() {
                            _completePhoneNumber =
                                '+998${value.replaceAll(RegExp(r'\D'), '')}';
                            _isValidPhone =
                                value.replaceAll(RegExp(r'\D'), '').length == 9;
                          }),
                          decoration: const InputDecoration(
                            hintText: '99-999-99-99',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
                          color: _termsAccepted
                              ? AppTheme.color_FF2F80ED
                              : AppTheme.transparent,
                          border: Border.all(
                            color: _termsAccepted
                                ? AppTheme.color_FF2F80ED
                                : AppTheme.color_FFD1D5DB,
                            width: 2,
                          ),
                        ),
                        child: _termsAccepted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppTheme.surface,
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
                                text: context.tr('privacy_policy'),
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.color_FF374151,
                                ),
                              ),
                                TextSpan(
                                text: context.tr('privacy_agreement_suffix'),
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppTheme.color_FF4B5563,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14),
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
                                    content: Text('${context.tr('otp_code')}: $otp'),
                                    backgroundColor: AppTheme.success,
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(
                                      label:
                                          context.tr('copy'),
                                      textColor: AppTheme.surface,
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: otp),
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.tr('copied'),
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
                          ? const CircularProgressIndicator(color: AppTheme.surface)
                          : Text(
                              context.tr('continue_button'),
                              style: TextStyle(fontSize: 16),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.color_FF2B7FFF,
                        disabledBackgroundColor: AppTheme.color_FF2B7FFF.withValues(alpha: 0.1),
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
                      ((progress+0.1) + 0.05).clamp(0.0, 1.0),
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
                    onTap: canContinue
                        ? () async {
                            setState(() => _progress = 0.5);
                            await Future<void>.delayed(
                              const Duration(milliseconds: 300),
                            );
                            final otp = await viewModel.sendOtp(
                              _completePhoneNumber,
                            );
                            if (!context.mounted) return;
                            if (otp != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${context.tr('otp_code')}: $otp')),
                              );
                            }
                            Navigator.pushNamed(
                              context,
                              AppRouter.otp,
                              arguments: _completePhoneNumber,
                            );
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(57),
                        color: canContinue
                            ? AppTheme.color_FF2B7FFF
                            : AppTheme.color_FF2B7FFF.withValues(alpha: 0.2),
                      ),
                      child: const Center(
                        child: Text(
                          'Davom etish',
                          style: TextStyle(fontSize: 16, color: AppTheme.surface),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 16,
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
    final code = context.watch<LocaleProvider>().currentLanguageCode;
    final language = LocaleProvider.supportedLanguages.firstWhere(
      (item) => item['code'] == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );
    return Container(
      height: 44,
      width: 44,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(47),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.color_FFFFFFFF, AppTheme.color_FFD9B875],
          stops: [0.5, 1.0],
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
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
