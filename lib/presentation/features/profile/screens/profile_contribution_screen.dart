import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';
import 'profile_contribution_form_screen.dart';

class ProfileContributionScreen extends StatefulWidget {
  const ProfileContributionScreen({super.key});

  @override
  State<ProfileContributionScreen> createState() =>
      _ProfileContributionScreenState();
}

class _ProfileContributionScreenState extends State<ProfileContributionScreen> {
  String _tab = 'Barchasi';

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: ['Barchasi', 'Viloyat', 'Tuman/Shahar']
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
                                      ? const Color(0xFF2F80FF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _tab == tab
                                        ? Colors.white
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
                if (_tab == 'Viloyat')
                  _selector(
                    _selectedRegion ?? 'Viloyat tanlang',
                    _selectRegion,
                  ),
                if (_tab == 'Tuman/Shahar')
                  _selector(
                    _selectedCity ?? 'Tuman/Shahar tanlang',
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
          const HeaderScreen(title: 'Loyihaga hissa qo‘shish'),
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
                  colors: [Color(0x00F1F5F9), Color(0xFFF1F5F9)],
                  stops: [0.0, 1],
                ),
              ),
            ),
          ),
          _bottomButton(
            'Hissa qo‘shish',
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
        color: Colors.white,
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
      _showLocationMessage('Joylashuv xizmati yoqilmagan.');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationMessage(
        'Tuman/Shaharni aniqlash uchun joylashuvga ruxsat bering.',
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
            'Joylashuv aniqlandi',
      );
    } catch (_) {
      _showLocationMessage('Joriy joylashuvni aniqlab bo‘lmadi.');
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
      color: const Color(0xFF2F9BFF),
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
                            Color(0x4DFFFFFF),
                            // White with 30% opacity
                            Color(0x00FFFFFF),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  '100 000 so‘m',
                  style: TextStyle(color: Colors.white, fontSize: 14),
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
      color: Colors.white,
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
                style: const TextStyle(fontSize: 14, color: Color(0xff475569)),
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
            style: const TextStyle(fontSize: 14, color: Color(0xff475569)),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2F80FF),
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
      title: const Icon(Icons.favorite, color: Color(0xFF2F80FF), size: 34),
      content: const Text(
        'Rahmat, hissangiz qabul qilindi!',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bosh sahifaga o‘tish'),
        ),
      ],
    ),
  );
}
