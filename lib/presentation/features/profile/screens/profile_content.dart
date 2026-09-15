import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../data/models/auth/user_model.dart';
import '../../../widgets/header_screen.dart';
import '../../../widgets/public_bottom_navigation_bar.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfileContent extends StatelessWidget {
  final UserModel user;

  const ProfileContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) => _ProfileShell(
    title: 'Profil',
    showBack: false,
    onEdit: () =>
        Navigator.pushNamed(context, AppRouter.profileDetails, arguments: user),
    child: _Menu(
      user: user,
      onDetails: () => Navigator.pushNamed(
        context,
        AppRouter.profileDetails,
        arguments: user,
      ),
    ),
  );
}

class ProfileDetailsScreen extends StatelessWidget {
  final UserModel user;

  const ProfileDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => _ProfileShell(
    title: 'Shaxsiy ma’lumotlar',
    showBottomNavigation: false,
    onEdit: () =>
        Navigator.pushNamed(context, AppRouter.profileEdit, arguments: user),
    child: _Details(
      user: user,
      editing: false,
      firstName: TextEditingController(text: user.firstName),
      lastName: TextEditingController(text: user.lastName),
      birthDate: TextEditingController(text: '20.03.2024'),
      phone: TextEditingController(text: formatPhoneNumber(user.phoneNumber)),
      region: 'Toshkent',
      district: 'Chilonzor',
      onRegion: (_) {},
      onDistrict: (_) {},
      onSave: () {},
    ),
  );
}

class ProfileEditScreen extends StatefulWidget {
  final UserModel user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final firstName = TextEditingController(text: widget.user.firstName);
  late final lastName = TextEditingController(text: widget.user.lastName);
  late final birthDate = TextEditingController(text: '20.03.2024');
  late final phone = TextEditingController(
    text: formatPhoneNumber(widget.user.phoneNumber),
  );
  String region = 'Toshkent';
  String district = 'Chilonzor';

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    birthDate.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ProfileShell(
    title: 'Shaxsiy ma’lumotlar',
    showBottomNavigation: false,
    child: _Details(
      user: widget.user,
      editing: true,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      phone: phone,
      region: region,
      district: district,
      onRegion: (value) => setState(() => region = value),
      onDistrict: (value) => setState(() => district = value),
      onSave: _save,
    ),
  );

  Future<void> _save() async {
    final saved = await context.read<AuthViewModel>().updateProfile(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      countryId: widget.user.countryId,
      regionId: widget.user.regionId,
    );
    if (saved && mounted) Navigator.pop(context, true);
  }
}

class _ProfileShell extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showBottomNavigation;
  final VoidCallback? onEdit;
  final Widget child;

  const _ProfileShell({
    required this.title,
    required this.child,
    this.showBack = true,
    this.showBottomNavigation = true,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(top: 0, child: child),
          HeaderScreen(
            title: title,
            showBackIcon: showBack,
            onBackTap: () => Navigator.pop(context),
            firstActionIconPath: onEdit == null
                ? null
                : 'assets/icons/edit.svg',
            onFirstActionTap: onEdit,
          ),
        ],
      ),
    ),
    bottomNavigationBar: showBottomNavigation
        ? PublicBottomNavigationBar(
            activeItem: 'profile',
            onHomeTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.home,
              (route) => false,
            ),
            onAppointmentsTap: () =>
                Navigator.pushNamed(context, AppRouter.appointments),
            onProfileTap: () {},
          )
        : null,
  );
}

class _Header extends StatelessWidget {
  final String title;
  final bool back;
  final VoidCallback onBack;
  final VoidCallback? onEdit;

  const _Header({
    required this.title,
    required this.back,
    required this.onBack,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        if (back)
          _Button(icon: Icons.chevron_left, onTap: onBack)
        else
          const SizedBox(width: 40),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        if (onEdit != null)
          _Button(icon: Icons.edit_outlined, onTap: onEdit!)
        else
          const SizedBox(width: 40),
      ],
    ),
  );
}

class _Button extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Button({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 19)),
    ),
  );
}

class _Menu extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDetails;

  const _Menu({required this.user, required this.onDetails});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
    children: [
      _Banner(user: user),
      const SizedBox(height: 12),
      _Tile(
        icon: 'assets/icons/verified_user_outlined.svg',
        title: 'Profilni tasdiqlash',
      ),
      _Tile(
        icon: 'assets/icons/description_outlined.svg',
        title: 'Hujjat shablonlarim',
        onTap: () => Navigator.pushNamed(context, AppRouter.templates),
      ),
      _Tile(
        icon: 'assets/icons/history.svg',
        title: 'Tarix',
        onTap: () => Navigator.pushNamed(context, AppRouter.history),
      ),
      _Tile(
        icon: 'assets/icons/card_giftcard_outlined.svg',
        title: 'Loyihaga hissa qo‘shish',
      ),
      // _Tile(
      //   icon: 'assets/icons/notification.svg',
      //   title: 'Bildirishnoma',
      //   trailing: const _NotificationSwitch(),
      // ),
      _Tile(
        icon: 'assets/icons/lightbulb_outline.svg',
        title: 'Ilova bo‘yicha takliflar',
        onTap: () => Navigator.pushNamed(context, AppRouter.suggestions),
      ),
      _Tile(
        icon: 'assets/icons/campaign_outlined.svg',
        title: 'Reklama va hamkorlik',
        onTap: () => Navigator.pushNamed(context, AppRouter.partnership),
      ),
      _Tile(
        icon: 'assets/icons/devices_other.svg',
        title: 'Faol qurilmalar',
        onTap: () => Navigator.pushNamed(context, AppRouter.activeDevices),
      ),
      _Tile(
        icon: 'assets/icons/language.svg',
        title: 'Til',
        undertitle: _languageName(
          context.watch<LocaleProvider>().currentLanguageCode,
        ),
        onTap: () => _showLanguagePicker(context),
      ),
      _Tile(
        icon: 'assets/icons/lock_outline.svg',
        title: 'Maxfiylik siyosati',
        onTap: () => Navigator.pushNamed(context, AppRouter.profilePrivacy),
      ),
      _Tile(
        icon: 'assets/icons/phone_verify.svg',
        title: 'Ishonch raqami',
        onTap: () => Navigator.pushNamed(context, AppRouter.trustNumber),
      ),
      _Tile(
        icon: 'assets/icons/help_outline.svg',
        title: 'Yordam markazi',
        onTap: () => Navigator.pushNamed(context, AppRouter.helpCenter),
      ),
      _Tile(
        icon: 'assets/icons/verified_user_outlined.svg',
        title: 'Shaxsiy ma’lumotlar',
        onTap: onDetails,
      ),
      _Tile(
        icon: 'assets/icons/logout.svg',
        title: 'Tizimdan chiqish',
        onTap: () => context.read<AuthViewModel>().logout(),
        exit: true,
      ),
    ],
  );

  String _languageName(String code) {
    final language = LocaleProvider.supportedLanguages.firstWhere(
      (item) => item['code'] == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );
    return language['name'] ?? 'O‘zbekcha';
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    var selectedCode = localeProvider.currentLanguageCode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF5F6F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tilni o‘zgartirish',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),

                    Material(
                      color: const Color(0xFFEAF0F7),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(Icons.close, size: 17),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...LocaleProvider.supportedLanguages.map((language) {
                  final code = language['code']!;
                  final selected = selectedCode == code;
                  final label = code == 'uz'
                      ? 'O‘zbek tili'
                      : code == 'ru'
                          ? 'Rus tili'
                          : 'Ingliz tili';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setModalState(() => selectedCode = code),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEAF3FF)
                              : const Color(0xFFF8FAFC),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF2F80FF)
                                : const Color(0xFFE0E7EF),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.white,
                              child: Text(
                                language['flag'] ?? '',
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: selected
                                  ? const Color(0xFF2F80FF)
                                  : const Color(0xFFE0E7EF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      await localeProvider.setLocale(Locale(selectedCode));
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Saqlash', style: TextStyle(fontSize: 16),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final UserModel user;

  const _Banner({required this.user});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE3BE71),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      children: [
        Container(
          width: 74,
          height: 74,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.pageBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.network(
            '${AppConfig.dummyImageBaseUrl}/lawyer-${user.id}/320/240',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 74,
              height: 74,
              color: AppTheme.avatarBackground,
              alignment: Alignment.center,
              child: Image.asset('assets/images/default_user.jpg'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.fio.isNotEmpty
                        ? user.fio
                        : '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.verify) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF198C72),
                      size: 20,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                formatPhoneNumber(user.phoneNumber),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool exit;
  final String? undertitle;

  const _Tile({
    required this.icon,
    required this.title,
    this.exit = false,
    this.onTap,
    this.trailing,
    this.undertitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: exit
                    ? Color(0xffFFE2E2)
                    : AppTheme.pageBackground,
                radius: 21,
                child: SvgPicture.asset(icon),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  if (undertitle != null) ...[
                    Text(
                      undertitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff475569),
                      ),
                    ),
                  ],
                ],
              ),
              Spacer(),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: exit ? Color(0xffE7000B) : AppTheme.textMuted,
                  ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: enabled,
      onChanged: (value) => setState(() => enabled = value),
    );
  }
}

class _Details extends StatelessWidget {
  final UserModel user;
  final bool editing;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController birthDate;
  final TextEditingController phone;
  final String region;
  final String district;
  final ValueChanged<String> onRegion;
  final ValueChanged<String> onDistrict;
  final VoidCallback onSave;

  const _Details({
    required this.user,
    required this.editing,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    required this.region,
    required this.district,
    required this.onRegion,
    required this.onDistrict,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 70, 12, 12),
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.avatarBackground,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.0),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          '${AppConfig.dummyImageBaseUrl}/lawyer-${user.id}/320/240',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.avatarBackground,
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/default_user.jpg',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (editing)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppTheme.buttonGold,
                        child: Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _Card(
              title: 'Shaxsiy ma’lumotlar',
              children: [
                _Field('Ismi', controller: firstName, enabled: editing),
                _Field('Familiya', controller: lastName, enabled: editing),
                _Field(
                  'Tug‘ilgan sana',
                  controller: birthDate,
                  enabled: editing,
                  readOnly: true,
                  suffixSvg: 'assets/icons/calendar.svg',
                  // Works with SVG paths
                  onTap: editing
                      ? () => _pickBirthDate(context, birthDate)
                      : null,
                ),
                // The phone number belongs to the authenticated login account.
                _Field('Telefon raqam', controller: phone, enabled: false),
              ],
            ),
            const SizedBox(height: 10),
            _Card(
              title: 'Manzil',
              children: [
                _Select('Viloyat', region, editing, onRegion, const [
                  'Toshkent',
                  'Samarqand',
                ]),
                _Select('Tuman', district, editing, onDistrict, const [
                  'Chilonzor',
                  'Yunusobod',
                ]),
              ],
            ),
          ],
        ),
      ),
      if (editing)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Tahrirlash'),
            ),
          ),
        ),
    ],
  );
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? value;
  final bool enabled;
  final bool readOnly;
  final IconData? suffix;
  final String? suffixSvg; // Added for SVG support
  final VoidCallback? onTap;

  const _Field(
    this.label, {
    this.controller,
    this.value,
    this.enabled = false,
    this.readOnly = false,
    this.suffix,
    this.suffixSvg,
    this.onTap,
  });

  Widget? _buildSuffixIcon() {
    if (suffixSvg != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: SvgPicture.asset(
          suffixSvg!,
          width: 15,
          height: 15,
          colorFilter: ColorFilter.mode(
            enabled ? AppTheme.textSecondary : Colors.grey.shade400,
            BlendMode.srcIn,
          ),
        ),
      );
    }
    if (suffix != null) {
      return Icon(suffix, size: 15);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: value,
            isDense: true,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: const Color(0xFFFAF9F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> _pickBirthDate(
  BuildContext context,
  TextEditingController controller,
) async {
  DateTime selectedDate = DateTime(2024, 3, 20);
  final result = await showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context, selectedDate),
              child: const Text('Tayyor'),
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (date) => selectedDate = date,
            ),
          ),
        ],
      ),
    ),
  );

  if (result != null) {
    controller.text =
        '${result.day.toString().padLeft(2, '0')}.${result.month.toString().padLeft(2, '0')}.${result.year}';
  }
}

class _Select extends StatelessWidget {
  final String label, value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final List<String> items;

  const _Select(
    this.label,
    this.value,
    this.enabled,
    this.onChanged,
    this.items,
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 3),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: enabled ? (v) => onChanged(v!) : null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFFAF9F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Avatar extends StatelessWidget {
  final UserModel user;
  final double size;

  const _Avatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: const Color(0xFFDCE8EF),
    backgroundImage: user.fullAvatarUrl.isNotEmpty
        ? NetworkImage(user.fullAvatarUrl)
        : null,
    child: user.fullAvatarUrl.isEmpty
        ? Text(
            (user.fio.isNotEmpty ? user.fio : 'P')
                .substring(0, 1)
                .toUpperCase(),
            style: TextStyle(
              fontSize: size * .34,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          )
        : null,
  );
}
