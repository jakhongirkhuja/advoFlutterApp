import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/services/organization.dart';
import '../../../widgets/header_navigation.dart';
import '../../../widgets/lawyer_card.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class OrganizationProfileScreen extends StatefulWidget {
  final Organization organization;

  const OrganizationProfileScreen({super.key, required this.organization});

  @override
  State<OrganizationProfileScreen> createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  static const tabs = ['Ma’lumot', 'Xizmatlar', 'Advokatlar', 'Sharhlar'];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final organization = widget.organization;
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 62, 16, 92),
              children: [
                _OrganizationIdentity(organization: organization),
                const SizedBox(height: 12),
                _ProfileTabs(
                  tabs: tabs,
                  selected: selectedTab,
                  onSelected: (index) => setState(() => selectedTab = index),
                ),
                const SizedBox(height: 12),
                _OrganizationTabBody(
                  index: selectedTab,
                  organization: organization,
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/back.svg',
                    firstIconOnTap: () {},
                    moveBack: true,
                  ),
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/share.svg',
                    firstIconOnTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationIdentity extends StatelessWidget {
  final Organization organization;

  const _OrganizationIdentity({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
      ),

      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.003, -1.5),
                radius: 1.5,
                colors: [
                  Color(0xFFD9B875), // #D9B875
                  Color(0x00FFFFFF),
                ],
              ),

              borderRadius: BorderRadius.circular(28),
            ),
          ),

          Positioned(
            top: -50,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Color(0xFF00A86B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  organization.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1D1816),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  margin: EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xffF3F1F1),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Text(
                    organization.type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textChoco,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(
                        icon: 'assets/icons/balance.svg',
                        label: 'Advokatlar',
                        value: '${organization.lawyerCount}+',
                      ),
                      _StatItem(
                        icon: 'assets/icons/hummer.svg',
                        label: 'Qabullar',
                        value: '+980',
                      ),
                      _StatItem(
                        icon: 'assets/icons/star.svg',
                        label: 'Reyting',
                        value: organization.rating.toStringAsFixed(1),
                        last: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool last;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: last ? 0 : 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textChoco),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatefulWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  const _ProfileTabs({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<_ProfileTabs> {
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant _ProfileTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _keys
        ..clear()
        ..addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
    }
  }

  void _scrollToIndex(int index) {
    final keyContext = _keys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5, // Centers the clicked tab horizontally
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(
            widget.tabs.length,
            (index) => GestureDetector(
              key: _keys[index],
              onTap: () {
                widget.onSelected(index);
                _scrollToIndex(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.selected == index
                      ? AppTheme.buttonGold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Text(
                  widget.tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.selected == index
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationTabBody extends StatelessWidget {
  final int index;
  final Organization organization;

  const _OrganizationTabBody({required this.index, required this.organization});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return _ServicesContent(services: organization.services);
      case 2:
        return _LawyersContent(organization: organization);
      case 3:
        return _ReviewsContent(organization: organization);
      default:
        return _AboutContent(organization: organization);
    }
  }
}

class _AboutContent extends StatelessWidget {
  final Organization organization;

  const _AboutContent({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ContentCard(
          title: 'Tavsif',
          child: Text(
            'ADVO Legal Group — fuqarolik, mehnat va biznes huquqi bo‘yicha professional yuridik xizmat ko‘rsatuvchi tashkilot.',
            style: _bodyStyle,
          ),
        ),
        _ContentCard(
          title: 'Asosiy yo‘nalishlari',
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: organization.tags.map((tag) => _Tag(text: tag)).toList(),
          ),
        ),
        _ContentCard(
          title: 'Joylashuv',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrganizationMap(organization: organization),
              const SizedBox(height: 6),
              Text(
                '📍 ${organization.address}, Amir Temur shoh ko‘chasi 108-uy',
                style: _bodyStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganizationMap extends StatefulWidget {
  final Organization organization;

  const _OrganizationMap({required this.organization});

  @override
  State<_OrganizationMap> createState() => _OrganizationMapState();
}

class _OrganizationMapState extends State<_OrganizationMap> {
  GoogleMapController? _controller;

  static const _tashkent = LatLng(41.3111, 69.2797);

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(
      widget.organization.latitude ?? _tashkent.latitude,
      widget.organization.longitude ?? _tashkent.longitude,
    );

    return GestureDetector(
      onTap: () => _showMapOpenSheet(context, position),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 104,
          width: double.infinity,
          child: AbsorbPointer(
            child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 13.5),
          markers: {
            Marker(
              markerId: MarkerId('organization-${widget.organization.id}'),
              position: position,
              infoWindow: InfoWindow(title: widget.organization.name),
            ),
          },
          onMapCreated: (controller) => _controller = controller,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showMapOpenSheet(BuildContext context, LatLng position) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ochish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.tagBackground),
                  icon: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _MapOpenOption(
                  icon: Icons.map_outlined,
                  label: 'Google Maps',
                  onTap: () => _launchMap(
                    sheetContext,
                    Uri.parse('https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'),
                  ),
                ),
                const SizedBox(width: 12),
                _MapOpenOption(
                  icon: Icons.language,
                  label: 'Brauzer',
                  onTap: () => _launchMap(
                    sheetContext,
                    Uri.parse('https://maps.google.com/?q=${position.latitude},${position.longitude}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _launchMap(BuildContext context, Uri uri) async {
  Navigator.pop(context);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xaritani ochib bo‘lmadi')),
    );
  }
}

class _MapOpenOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapOpenOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 78,
          decoration: BoxDecoration(color: AppTheme.tagBackground, borderRadius: BorderRadius.circular(18)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: AppTheme.primaryBlue), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))]),
        ),
      ),
    );
  }
}

class _ServicesContent extends StatelessWidget {
  final List<String> services;

  const _ServicesContent({required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: services
          .map(
            (service) => Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    height: 1,
                    color: AppTheme.textChoco.withValues(alpha: 0.2),
                    margin: EdgeInsets.symmetric(vertical: 10),
                  ),
                  Row(
                    children: [
                      Text(
                        '200000',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '/so\'mdan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textChoco,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LawyersContent extends StatelessWidget {
  final Organization organization;

  const _LawyersContent({required this.organization});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Column(
      children: [
        ...viewModel.popularLawyers.map((lawyer) => LawyerCard(lawyer: lawyer)),
      ],
    );
  }
}

class _ReviewsContent extends StatelessWidget {
  final Organization organization;

  const _ReviewsContent({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFE8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFEEA0), width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                organization.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final rating = organization.rating;
                      return Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index < rating
                                  ? Icons.star_half
                                  : Icons.star_outline),
                        size: 22,
                        color: AppTheme.star,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${organization.reviewsCount} baholadi',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(
              name: 'Madina. A',
              date: '2024–yil',
              rating: 4,
              comment:
                  'Dr. Sardor Tursunov — 12 yildan ortiq tajribaga ega terapevt. Bemorlarni umumiy',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String date,
    required int rating,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFF0F0F0),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF5A6275),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Name and Stars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_outline,
                          size: 18,
                          color: AppTheme.star,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  SvgPicture.asset('assets/icons/calendar.svg'),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textChoco,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppTheme.textChoco.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          // Comment Text
          Text(
            comment,
            style: const TextStyle(fontSize: 16, color: AppTheme.textChoco),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ContentCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.tagBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  fontSize: 16,
  height: 1.3,
  color: AppTheme.textChoco,
);
