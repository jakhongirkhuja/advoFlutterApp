import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final localeProvider = context.watch<LocaleProvider>();
    final localizations = AppLocalizations.of(context);

    if (auth.status != AuthStatus.authenticated) {
      return const LoginScreen();
    }

    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(localizations?.translate('profile') ?? 'Profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fio.isNotEmpty == true
                  ? user!.fio
                  : (localizations?.translate('profile') ?? 'Profil'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user?.phoneNumber ?? ''),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(localizations?.translate('language') ?? 'Til'),
              subtitle: Text(_languageName(localeProvider.currentLanguageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(context, localeProvider),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<AuthViewModel>().logout(),
              child: Text(localizations?.translate('logout') ?? 'Tizimdan chiqish'),
            ),
          ],
        ),
      ),
    );
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
                    : Colors.grey,
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
