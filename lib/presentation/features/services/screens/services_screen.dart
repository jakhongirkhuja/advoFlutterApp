import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text('Xizmatlar'),
        actions: const [Icon(Icons.search), SizedBox(width: 8), Icon(Icons.tune), SizedBox(width: 16)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: const Row(
              children: [
                Expanded(child: _IntroTile(icon: Icons.business_center_outlined, title: 'Tashkilotlar', subtitle: 'Ishonchli yuridik tashkilotlar toping')),
                SizedBox(width: 10),
                Expanded(child: _IntroTile(icon: Icons.person_outline, title: 'Advokatlar', subtitle: 'Tajribali advokatlarni toping')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Xizmat turlari', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _ServiceRow(icon: Icons.people_outline, title: 'Huquqiy maslahat', onTap: () {}),
          _ServiceRow(icon: Icons.family_restroom, title: 'Oila huquqi', onTap: () {}),
          _ServiceRow(icon: Icons.groups_outlined, title: 'Fuqarolik huquqi', onTap: () {}),
          _ServiceRow(
            icon: Icons.gavel,
            title: 'Sud va nizolar',
            onTap: () => Navigator.pushNamed(context, AppRouter.courtRepresentation),
          ),
        ],
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        activeItem: 'services',
        onHomeTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (route) => false),
        onAppointmentsTap: () => Navigator.pushNamed(context, AppRouter.appointments),
        onProfileTap: () => Navigator.pushNamed(context, AppRouter.profile),
      ),
    );
  }
}

class _IntroTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _IntroTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: const Color(0xFF555555)),
        const Spacer(),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Color(0xFF777777))),
      ]),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              CircleAvatar(radius: 17, backgroundColor: const Color(0xFFF1F1F1), child: Icon(icon, size: 18, color: const Color(0xFF555555))),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: Color(0xFF777777)),
            ]),
          ),
        ),
      ),
    );
  }
}
