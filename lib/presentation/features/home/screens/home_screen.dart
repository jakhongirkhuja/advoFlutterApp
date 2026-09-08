import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';
import '../../../../data/models/home/service_category.dart';
import '../../../widgets/public_bottom_navigation_bar.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadHome,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
            children: [
              _TopBar(
                locationName: viewModel.locationName,
                onProfileTap: () =>
                    Navigator.pushNamed(context, AppRouter.profile),
              ),
              const SizedBox(height: 20),
              _SearchField(
                hintText: AppLocalizations.of(context)?.translate('search') ?? 'Izlash',
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white
                ),
                child: Column(
                  children: [
                    _SectionHeader(
                      title: AppLocalizations.of(context)?.translate('legal_services') ?? 'Huquqiy xizmatlar',
                      action: AppLocalizations.of(context)?.translate('see_all') ?? 'Barchasi',
                      onTap: () => _showComingSoon(context),
                    ),
                    const SizedBox(height: 10),
                    if (viewModel.isLoading)
                      const _HomeLoadingCard()
                    else
                      _ServicesGrid(
                        categories: viewModel.serviceCategories,
                        onTap: (_) => Navigator.pushNamed(context, AppRouter.services),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _SectionHeader(
                title: AppLocalizations.of(context)?.translate('popular_lawyers') ?? 'Mashhur advokatlar',
                action: AppLocalizations.of(context)?.translate('see_all') ?? 'Barchasi',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              if (viewModel.isLoading)
                const _HomeLoadingCard()
              else
                ...viewModel.popularLawyers.map((lawyer) => _LawyerCard(lawyer: lawyer))
            ],
          ),
        ),
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        onServicesTap: () => Navigator.pushNamed(context, AppRouter.services),
        onProfileTap: () => Navigator.pushNamed(context, AppRouter.profile),
        onAppointmentsTap: () => Navigator.pushNamed(context, AppRouter.appointments),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.translate('coming_soon') ?? 'Bu bo‘lim tez orada ishga tushadi')),
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
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, size: 22, color: Color(0xFF757575)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(

                children: [
                  SvgPicture.asset('assets/icons/marker.svg'),
                  const SizedBox(width: 2,),
                  Text(
                    locationName,
                    style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                  ),
                ],
              ),
              const SizedBox(height: 2,),
              Text(
                AppLocalizations.of(context)?.translate('greeting') ?? 'Assalomu alaykum!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(47),
            color: Colors.white,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFD9B875),
              ],
              stops: [0.5, 1.0],
            ),
          ),
          child: Container(
            height: 40,

            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(47),
            ),
            child: Row(
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: (){

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset('assets/icons/bookmark.svg'),
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: (){

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset('assets/icons/notification.svg'),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;

  const _SearchField({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(61),

      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        decoration: InputDecoration(
      
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 13,top:10,right: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: const TextStyle(fontSize: 12, color: Color(0xFFCA9D38)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<ServiceCategory> categories;
  final ValueChanged<ServiceCategory>? onTap;

  const _ServicesGrid({required this.categories, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:  AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(22),
        
      ),
      padding: EdgeInsets.all(6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap == null ? null : () => onTap!(category),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.pageBackground,
                          borderRadius: BorderRadius.circular(12)
                        ),
                          padding: EdgeInsets.all(10),
                          child: SvgPicture.asset(_serviceIcon(index))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        category.title,
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

  String _serviceIcon(int index) {
     var icons = [
      'assets/icons/maslahat.svg',
      'assets/icons/oila.svg',
      'assets/icons/fuqoro.svg',
      'assets/icons/jinoyat.svg',
    ];
    return icons[index];
  }
}

class _LawyerCard extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerCard({required this.lawyer});

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
                  'https://loremflickr.com/320/240/',
                  fit: BoxFit.cover,
                  errorBuilder: (context, exception, stackTrace) {
                    return Center(
                      child: Text(
                        _initials(lawyer.name),
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
                            lawyer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        if (lawyer.isVerified) ...[
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
                          '${lawyer.title}',
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
                        const SizedBox(width: 6),
                        Text(
                          '${lawyer.experienceYears} yil tajriba',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textChoco,
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
                          '${lawyer.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '(${lawyer.comment_count} ta sharh)',
                          style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textChoco, fontSize: 16),
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
                  borderRadius: BorderRadius.circular(40)
                ),
                child: SvgPicture.asset('assets/icons/bookmarkfilled.svg'),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: lawyer.tags.take(2).map(_tag).toList(),
              ),
              if(lawyer.tags.length>2) ...[
                const SizedBox(width: 8),
                _tag('+${lawyer.tags.length-2}'),
              ]
            ],
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.pageBackground,
            ),
          ),
          Row(
            children: [
              Text(
                lawyer.pricePerMinute
                    .toString()
                    .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]} ',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                  '/so\'mdan',
                style: TextStyle(
                  color: AppTheme.textChoco,
                  fontSize: 16
                ),
              ),
              Spacer(),
              InkWell(
                onTap: (){},
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 9.5, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGold,
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Text('Ko\'rish', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),),
                ),
              )
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
      child: Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textChoco)),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
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
