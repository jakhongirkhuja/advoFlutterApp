import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_icon_design.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routes/app_router.dart';

class UserInfoFill extends StatefulWidget {
  final String phoneNumber;

  const UserInfoFill({super.key, required this.phoneNumber});

  @override
  State<UserInfoFill> createState() => _UserInfoFillState();
}

class _UserInfoFillState extends State<UserInfoFill> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  double _progress = 1.0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final localizations = AppLocalizations.of(context);
    final canSubmit = _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        viewModel.status != AuthStatus.loading;
    final progress = _progress;
    return Scaffold(

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                CustomIconDesign(
                  icon: 'assets/icons/login_user.svg',
                  mainColor: AppTheme.color_FF1C8AFF,
                  secondaryColor: AppTheme.color_FF69AFFF,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('create_profile_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.color_FF0F172A,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: localizations?.translate('create_profile_subtitle') ??
                            context.tr('create_profile_subtitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.color_FF475569,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 41),
                _buildNameField(
                  controller: _firstNameController,
                  label: context.tr('first_name_hint'),
                  hint: context.tr('first_name_hint'),
                ),
                const SizedBox(height: 12),
                _buildNameField(
                  controller: _lastNameController,
                  label: context.tr('last_name_hint'),
                  hint: context.tr('last_name_hint'),
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
                        ? () => _submitProfile(viewModel)
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
                            ? const CircularProgressIndicator(color: AppTheme.surface)
                            : Text(
                                context.tr('continue_button'),
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

  Widget _buildNameField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.color_FF2B7FFF,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitProfile(AuthViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    final saved = await viewModel.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted || !saved) return;
    setState(() => _progress = 1.0);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    }
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
