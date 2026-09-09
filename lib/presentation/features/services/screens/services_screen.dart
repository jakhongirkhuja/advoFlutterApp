import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vatandoshlar/presentation/widgets/section_header.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';
import '../../../widgets/header_navigation.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: viewModel.loadServices,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [

                    ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // Guarantees pull-to-refresh behavior
                      padding: const EdgeInsets.fromLTRB(12, 70, 12, 18),
                      children: [
                        const _FeaturePanel(),
                        const SizedBox(height: 12),
                        const SectionHeader(title: 'Xizmat turlari'),
                        const SizedBox(height: 12),
                        _ServiceRow(
                          icon: Icons.people_outline,
                          title: 'Huquqiy maslahat',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.courtRepresentation,
                            arguments: CourtRepresentationArgs(
                              title: 'Huquqiy maslahat',
                              about: 'Huquqiy maslahat Haqida ma\'lumot',
                              description: 'Batafsil tavsif bu yerda joylashadi.',
                            ),
                          ),
                        ),
                        _ServiceRow(
                          icon: Icons.family_restroom,
                          title: 'Oila huquqi',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.courtRepresentation,
                            arguments: CourtRepresentationArgs(
                              title: 'Oila huquqi',
                              about: 'Oila huquqi Haqida ma\'lumot',
                              description: 'Batafsil tavsif bu yerda joylashadi.',
                            ),
                          ),
                        ),
                        _ServiceRow(
                          icon: Icons.groups_outlined,
                          title: 'Fuqarolik huquqi',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.courtRepresentation,
                            arguments: CourtRepresentationArgs(
                              title: 'Fuqarolik huquqi',
                              about: 'Fuqarolik huquqi Haqida ma\'lumot',
                              description: 'Batafsil tavsif bu yerda joylashadi.',
                            ),
                          ),
                        ),
                        _ServiceRow(
                          icon: Icons.gavel,
                          title: 'Sud va nizolar',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.courtRepresentation,
                            arguments: CourtRepresentationArgs(
                              title: 'Sud va nizolar',
                              about: 'Sud va nizolar Haqida ma\'lumot',
                              description: 'Batafsil tavsif bu yerda joylashadi.',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.pageBackground,
                              Color(0xFFF5F5F5).withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Xizmatlar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            HeaderNavigation(
                              firstIconPath: 'assets/icons/bookmark.svg',
                              firstIconOnTap: () {},
                              secondIconPath: 'assets/icons/notification.svg',
                              secondIconOnTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF5F5F5).withValues(alpha: 0.0),
                              const Color(0xFFF5F5F5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        activeItem: 'services',
        onHomeTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (route) => false,
        ),
        onAppointmentsTap: () =>
            Navigator.pushNamed(context, AppRouter.appointments),
        onProfileTap: () => Navigator.pushNamed(context, AppRouter.profile),
      ),
    );
  }
}

class _FeaturePanel extends StatelessWidget {
  const _FeaturePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.pageBackground,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: _FeatureTile(
                    icon: 'assets/icons/compains.svg',
                    title: 'Tashkilotlar',
                    subtitle: 'Ishonchli yuridik tashkilotlarni toping',
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _FeatureTile(
                    icon: 'assets/icons/lawyer.svg',
                    title: 'Advokatlar',
                    subtitle: 'Tajribali advokatlarni toping',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const _FeatureTile(
              icon: 'assets/icons/templetes.svg',
              title: 'Hujjatlar shablonlari',
              subtitle: 'Tayyor huquqiy hujjat shablonlaridan foydalaning',
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool expanded;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.pageBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(icon),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.tagBackground,
                  child: Icon(icon, size: 18, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
