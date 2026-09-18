import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../../data/models/auth/user_model.dart';
import 'profile_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    // The profile page is currently available from the public navigation.
    // Use an empty model until authentication-backed profile data is loaded.
    final user = auth.currentUser ?? UserModel.fromJson(const <String, dynamic>{});
    return ProfileContent(user: user);
  }

  String _languageName(String code) {
    return LocaleProvider.supportedLanguages.firstWhere(
      (language) => language['code'] == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    )['name']!;
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    LocaleProvider localeProvider,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLanguages.map((language) {
            final code = language['code']!;
            return ListTile(
              leading: Text(language['flag']!),
              title: Text(language['name']!),
              trailing: Icon(
                code == localeProvider.currentLanguageCode
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: code == localeProvider.currentLanguageCode
                    ? Theme.of(sheetContext).colorScheme.primary
                    : AppTheme.textMuted,
              ),
              onTap: () => Navigator.pop(sheetContext, code),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      await localeProvider.setLocale(Locale(selected));
    }
  }
}
