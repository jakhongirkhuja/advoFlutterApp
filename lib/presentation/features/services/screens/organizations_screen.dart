import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/services/organization.dart';
import '../../../../presentation/widgets/header_screen.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({super.key});

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<HomeViewModel>().organizations.isEmpty) {
        context.read<HomeViewModel>().loadServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: viewModel.loadServices,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 18),
                children: [
                  if (viewModel.organizations.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    ...viewModel.organizations.map(
                      (organization) =>
                          _OrganizationCard(organization: organization),
                    ),
                ],
              ),
            ),
            HeaderScreen(
              title: 'Tashkilotlar',
              firstActionIconPath: 'assets/icons/search.svg',
              onFirstActionTap: () =>
                  Navigator.pushNamed(context, AppRouter.search),
              secondActionIconPath: 'assets/icons/filter.svg',
              onSecondActionTap: () =>
                  Navigator.pushNamed(context, AppRouter.filters),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final Organization organization;

  const _OrganizationCard({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  '${AppConfig.dummyImageBaseUrl}/organization-${organization.id}/320/240',
                  fit: BoxFit.cover,
                  errorBuilder: (context, exception, stackTrace) {
                    print(exception);
                    return Center(
                      child: Text(
                        _initials(organization.name),
                        style: const TextStyle(
                          color: Color(0xFF31527A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            organization.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (organization.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 17,
                            color: Color(0xFF3E9B6B),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${organization.type}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textChoco,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.pageBackground,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/star.svg'),
                        const SizedBox(width: 4),
                        Text(
                          '${organization.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '(${organization.reviewsCount} ta sharh)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textChoco,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.pageBackground,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SvgPicture.asset('assets/icons/bookmarkfilled.svg'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: organization.tags.take(2).map(_tag).toList(),
              ),
              if (organization.tags.length > 2) ...[
                const SizedBox(width: 8),
                _tag('+${organization.tags.length - 2}'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset('assets/icons/location.svg'),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  organization.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(color: AppTheme.pageBackground),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.pageBackground,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: SvgPicture.asset('assets/icons/lawyer.svg'),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(organization.lawyerCount>15? '15+' : organization.lawyerCount.toString(), style: TextStyle(fontSize: 16),),
                      Text('Advakatlar', style: TextStyle(fontSize: 14, color: AppTheme.textChoco),)
                    ],
                  )
                ],
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.organizationProfile,
                  arguments: organization,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 9.5, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGold,
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Text(
                    'Ko\'rish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, color: AppTheme.textChoco),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}

class _OrganizationImage extends StatelessWidget {
  final Organization organization;

  const _OrganizationImage({required this.organization});

  @override
  Widget build(BuildContext context) => Container(
    width: 74,
    height: 74,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppTheme.pageBackground,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Image.network(
      organization.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Image Load Error: $error');
        return Center(
          child: Text(
            _initials(organization.name),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    ),
  );

  String _initials(String name) =>
      name.split(' ').take(2).map((part) => part[0]).join().toUpperCase();
}

class _Tag extends StatelessWidget {
  final String value;

  const _Tag(this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.pageBackground,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Text(
      value,
      style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
    ),
  );
}
