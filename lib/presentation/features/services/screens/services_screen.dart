import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:Vatandoshlar/presentation/widgets/section_header.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/service_category.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_screen.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final l10n = AppLocalizations.of(context);
    String tr(String key) => l10n?.translate(key) ?? key;
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: viewModel.loadServices,
          child: Stack(
            children: [
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Guarantees pull-to-refresh behavior
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 18),
                children: [
                  _ServicesGrid(categories: viewModel.serviceCategories),
                  const SizedBox(height: 12),
                  SectionHeader(title: tr('service_categories')),
                  const SizedBox(height: 12),
                  _ServiceRow(
                    icon: Icons.people_outline,
                    title: tr('legal_advice'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.courtRepresentation,
                      arguments: CourtRepresentationArgs(
                        title: tr('legal_advice'),
                        about: '${tr('legal_advice')} ${tr('about_label')}',
                        description: tr('detailed_description'),
                      ),
                    ),
                  ),
                  _ServiceRow(
                    icon: Icons.family_restroom,
                    title: tr('family_law'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.courtRepresentation,
                      arguments: CourtRepresentationArgs(
                        title: tr('family_law'),
                        about: '${tr('family_law')} ${tr('about_label')}',
                        description: tr('detailed_description'),
                      ),
                    ),
                  ),
                  _ServiceRow(
                    icon: Icons.groups_outlined,
                    title: tr('civil_law'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.courtRepresentation,
                      arguments: CourtRepresentationArgs(
                        title: tr('civil_law'),
                        about: '${tr('civil_law')} ${tr('about_label')}',
                        description: tr('detailed_description'),
                      ),
                    ),
                  ),
                  _ServiceRow(
                    icon: Icons.gavel,
                    title: tr('court_disputes'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.courtRepresentation,
                      arguments: CourtRepresentationArgs(
                        title: tr('court_disputes'),
                        about: '${tr('court_disputes')} ${tr('about_label')}',
                        description: tr('detailed_description'),
                      ),
                    ),
                  ),
                ],
              ),
              HeaderScreen(
                showBackIcon: false,
                title: tr('services'),
                firstActionIconPath: 'assets/icons/bookmark.svg',
                onFirstActionTap: () =>
                    Navigator.pushNamed(context, AppRouter.savedLawyers),
                secondActionIconPath: 'assets/icons/notification.svg',
                onSecondActionTap: () =>
                    Navigator.pushNamed(context, AppRouter.notifications),
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
                        AppTheme.pageBackground.withValues(alpha: 0.0),
                        AppTheme.pageBackground,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        activeItem: 'services',
        onAddTap: () => Navigator.pushNamed(context, AppRouter.aiAssistant),
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
  final VoidCallback onOrganizationsTap;
  final VoidCallback onLawyersTap;
  final VoidCallback onTemplatesTap;

  const _FeaturePanel({
    required this.onOrganizationsTap,
    required this.onLawyersTap,
    required this.onTemplatesTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String tr(String key) => l10n?.translate(key) ?? key;
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
              children: [
                Expanded(
                  child: _FeatureTile(
                    icon: 'assets/icons/compains.svg',
                    title: tr('organizations'),
                    subtitle: tr('find_reliable_organizations'),
                    onTap: onOrganizationsTap,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _FeatureTile(
                    icon: 'assets/icons/lawyer.svg',
                    title: tr('lawyers'),
                    subtitle: tr('find_experienced_lawyers'),
                    onTap: onLawyersTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _FeatureTile(
              icon: 'assets/icons/templetes.svg',
              title: tr('templates'),
              subtitle: tr('use_ready_templates'),
              expanded: true,
              onTap: onTemplatesTap,
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
  final VoidCallback? onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
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
        color: AppTheme.surface,
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

class _ServicesGrid extends StatelessWidget {
  final List<ServiceCategory> categories;

  const _ServicesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(22),
      ),

      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6, top: 6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,

        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1.50,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Material(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                if (category.route != null) {
                  Navigator.pushNamed(context, category.route!);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.color_FFECECEC),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: CustomIconDesign(
                        icon: category.iconPath,
                        mainColor: category.mainColor,
                        secondaryColor: category.secondaryColor,
                        home: true,
                        padding: 6,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 7,
                        bottom: 7,
                        right: 7,
                      ),
                      child: Text(
                        context.tr(category.title).replaceAll(' ', '\n'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
