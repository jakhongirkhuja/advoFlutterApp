import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/header_screen.dart';
import 'profile_contribution_form_screen.dart';

class ProfileContributionScreen extends StatefulWidget {
  const ProfileContributionScreen({super.key});

  @override
  State<ProfileContributionScreen> createState() =>
      _ProfileContributionScreenState();
}

class _ProfileContributionScreenState extends State<ProfileContributionScreen> {
  String _tab = 'all_contributors';

  String? _selectedRegion;
  String? _selectedCity;

  static const _uzbekistanRegions = [
    'Toshkent shahri',
    'Toshkent viloyati',
    'Andijon viloyati',
    'Buxoro viloyati',
    'Farg‘ona viloyati',
    'Jizzax viloyati',
    'Xorazm viloyati',
    'Namangan viloyati',
    'Navoiy viloyati',
    'Qashqadaryo viloyati',
    'Samarqand viloyati',
    'Sirdaryo viloyati',
    'Surxondaryo viloyati',
    'Qoraqalpog‘iston Respublikasi',
  ];

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 76, 16, 82),
              children: [
                Container(
                  padding: const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: ['all_contributors', 'region', 'district_city']
                        .map(
                          (tab) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = tab),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _tab == tab
                                      ? AppTheme.color_FF2F80FF
                                      : AppTheme.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  context.tr(tab),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _tab == tab
                                        ? AppTheme.surface
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_tab == 'region')
                  _selector(
                    _selectedRegion ?? context.tr('select_region'),
                    _selectRegion,
                  ),
                if (_tab == 'district_city')
                  _selector(
                    _selectedCity ?? context.tr('select_city'),
                    _selectCurrentLocation,
                  ),
                _donorSummary(),
                ...[
                  'Aziz Karimov',
                  'Nilufar Tursunova',
                  'Anonim',
                  'Jahongir Maximov',
                  'Madina Shermatova',
                  'Anonim',
                  'Jahongir Maximov',
                  'Madina Shermatova',
                  'Anonim',
                  'Jahongir Maximov',
                  'Madina Shermatova',
                ].map((name) => _donor(name)),
              ],
            ),
          ),
          HeaderScreen(title: context.tr('contribution')),
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.color_00F1F5F9, AppTheme.color_FFF1F5F9],
                  stops: [0.0, 1],
                ),
              ),
            ),
          ),
          _bottomButton(
            context.tr('add_contribution'),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileContributionFormScreen(),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _selector(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    ),
  );

  Future<void> _selectRegion() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView.builder(
        itemCount: _uzbekistanRegions.length,
        itemBuilder: (_, index) => ListTile(
          title: Text(_uzbekistanRegions[index]),
          onTap: () => Navigator.pop(context, _uzbekistanRegions[index]),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _selectedRegion = selected);
  }

  Future<void> _selectCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showLocationMessage(context.tr('location_disabled'));
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationMessage(
        context.tr('location_permission'),
      );
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = places.isNotEmpty ? places.first : null;
      if (!mounted) return;
      setState(
        () => _selectedCity =
            place?.subAdministrativeArea ??
            place?.locality ??
            context.tr('location_found'),
      );
    } catch (_) {
      _showLocationMessage(context.tr('location_failed'));
    }
  }

  void _showLocationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _donorSummary() => Container(
    padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
    decoration: BoxDecoration(
      color: AppTheme.color_FF2F9BFF,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(top: index != 1 ? 25 : 0),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.color_4DFFFFFF,
                            // White with 30% opacity
                            AppTheme.color_00FFFFFF,
                            // Fully transparent white
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                      padding: EdgeInsets.all(6),
                      child: CircleAvatar(
                        radius: index == 1 ? 38 : 38,
                        backgroundImage: const AssetImage(
                          'assets/images/default_user.jpg',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      left: 0,
                      right: 0,
                      child: Image.asset( width: 20, height: 20,
                        'assets/images/${index == 0 ? 'rank_2' : (index == 1 ? 'rank_1' : 'rank_3')}.png',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ['Aziz Karimov', 'Aziz Karimov', 'Aziz Karimov'][index],
                  style: const TextStyle(color: AppTheme.surface, fontSize: 16),
                ),
                const Text(
                  '100 000 so‘m',
                  style: TextStyle(color: AppTheme.surface, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _donor(String name) => Container(
    margin: const EdgeInsets.only(top: 12),

    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage('assets/images/default_user.jpg'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16)),
              Text(
                name == 'Nilufar Tursunova'
                    ? 'Navoiy viloyati'
                    : name == 'Jahongir Maximov'
                    ? 'Farg‘ona viloyati'
                    : 'Toshkent shahri',
                style: const TextStyle(fontSize: 14, color: AppTheme.color_FF475569),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            name == 'Jahongir Maximov'
                ? '120 000 so‘m'
                : name == 'Nilufar Tursunova' || name == 'Anonim'
                ? '85 000 so‘m'
                : '100 000 so‘m',
            style: const TextStyle(fontSize: 14, color: AppTheme.color_FF475569),
          ),
        ),
      ],
    ),
  );

  Widget _bottomButton(String text, VoidCallback onPressed) => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.color_FF2F80FF,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    ),
  );

  Future<void> _showSuccess() => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Icon(Icons.favorite, color: AppTheme.color_FF2F80FF, size: 34),
      content: Text(
        context.tr('contribution_success'),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('back_to_home')),
        ),
      ],
    ),
  );
}
