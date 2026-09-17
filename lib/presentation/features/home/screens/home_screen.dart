import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../data/models/home/service_category.dart';
import '../../../../data/models/services/organization.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_navigation.dart';
import '../../../widgets/lawyer_card.dart';
import '../../../widgets/public_bottom_navigation_bar.dart';
import '../../../widgets/section_header.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,

      body: RefreshIndicator(
        onRefresh: viewModel.loadHome,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 75,
                right: 16,
                left: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/header_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  _TopBar(
                    locationName: viewModel.locationName,
                    onProfileTap: () =>
                        Navigator.pushNamed(context, AppRouter.profile),
                  ),
                  const SizedBox(height: 17),
                  _SearchField(
                    hintText:
                        AppLocalizations.of(context)?.translate('search') ??
                        'Izlash',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SectionHeader(
                    title:
                        AppLocalizations.of(
                          context,
                        )?.translate('legal_services') ??
                        'Xizmatlar',
                    action:
                        AppLocalizations.of(context)?.translate('see_all') ??
                        'Barchasi',
                    onTap: () => _showComingSoon(context),
                  ),
                  const SizedBox(height: 10),
                  if (viewModel.isLoading)
                    const _HomeLoadingCard()
                  else
                    _ServicesGrid(categories: viewModel.serviceCategories),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title:
                    AppLocalizations.of(
                      context,
                    )?.translate('popular_lawyers') ??
                    'Mashhur advokatlar',
                action:
                    AppLocalizations.of(context)?.translate('see_all') ??
                    'Barchasi',
                onTap: () => _showComingSoon(context),
              ),
            ),
            const SizedBox(height: 12),
            if (viewModel.isLoading)
              const _HomeLoadingCard()
            else
              SizedBox(
                height: 222,
                child: ListView.separated(
                  padding: EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: viewModel.popularLawyers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 320,
                    child: LawyerCard(lawyer: viewModel.popularLawyers[index]),
                  ),
                ),
              ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Mashhur tashkilotlar',
                action: 'Barchasi',
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.organizations),
              ),
            ),

            if (viewModel.isLoading)
              const _HomeLoadingCard()
            else
              _OrganizationGrid(organizations: viewModel.organizations),
          ],
        ),
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        onAddTap: () => Navigator.pushNamed(context, AppRouter.aiAssistant),
        onServicesTap: () => Navigator.pushNamed(context, AppRouter.services),
        onProfileTap: () => Navigator.pushNamed(context, AppRouter.profile),
        onAppointmentsTap: () =>
            Navigator.pushNamed(context, AppRouter.appointments),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.translate('coming_soon') ??
              'Bu bo‘lim tez orada ishga tushadi',
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String locationName;
  final VoidCallback onProfileTap;

  const _TopBar({required this.locationName, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 0.80,
                      strokeWidth: 2.5,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xff51A2FF),
                      ),
                    ),
                  ),
                  // 2. Avatar sized down to sit neatly inside the indicator stroke
                  Container(
                    width: 45, // 48 - (strokeWidth * 2) - spacing = 38
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/default_user.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: const Text(
                  '42%',
                  style: TextStyle(fontSize: 10, color: Color(0xFF334155)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      locationName == 'Toshkent shahri'
                          ? 'Tashkent, sh'
                          : locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Text(
                'Jahongir. A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        HeaderNavigation(
          firstIconPath: 'assets/icons/bookmark.svg',
          firstIconOnTap: () =>
              Navigator.pushNamed(context, AppRouter.savedLawyers),
          secondIconPath: 'assets/icons/notification.svg',
          secondIconOnTap: () =>
              Navigator.pushNamed(context, AppRouter.notifications),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;

  const _SearchField({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.search),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(61)),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset('assets/icons/search.svg'),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(61),
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationGrid extends StatelessWidget {
  final List<Organization> organizations;

  const _OrganizationGrid({required this.organizations});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: organizations.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: .80,
    ),
    itemBuilder: (context, index) =>
        _OrganizationTile(organization: organizations[index]),
  );
}

class _OrganizationTile extends StatelessWidget {
  final Organization organization;

  const _OrganizationTile({required this.organization});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.organizationProfile,
        arguments: organization,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 134,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        '${AppConfig.dummyImageBaseUrl}/organization-${organization.id}/320/240',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/default_user.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () =>
                          viewModel.toggleOrganizationBookmark(organization.id),
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          viewModel.isOrganizationSaved(organization.id)
                              ? 'assets/icons/bookmarkfilled.svg'
                              : 'assets/icons/bookmark.svg',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: organization.name,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    children: [
                      if (organization.isVerified)
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFF00A878),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Row(
                spacing: 4,
                children: [
                  SvgPicture.asset('assets/icons/star.svg'),
                  Text(
                    '${organization.rating}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    '(${organization.reviewsCount} ta sharh)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
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
            color: Colors.white,
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
                  border: Border.all(color: const Color(0xFFECECEC)),
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
                        category.title.replaceAll(' ', '\n'),
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

class _HomeLoadingCard extends StatelessWidget {
  const _HomeLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
