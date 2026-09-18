import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../data/models/services/protokol_provider.dart';
import '../../../widgets/header_screen.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class ProtokolScreen extends StatefulWidget {
  final String title;

  const ProtokolScreen({super.key, required this.title});

  @override
  State<ProtokolScreen> createState() => _ProtokolScreenState();
}

class _ProtokolScreenState extends State<ProtokolScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<HomeViewModel>().protokolProviders.isEmpty) {
        context.read<HomeViewModel>().loadProtokolProviders();
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
              onRefresh: viewModel.loadProtokolProviders,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 18),
                children: [
                  if (viewModel.protokolProviders.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    ...viewModel.protokolProviders.map(
                      (provider) => ProtokolProviderCard(provider: provider),
                    ),
                ],
              ),
            ),
            HeaderScreen(
              title: widget.title,
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

class ProtokolProviderCard extends StatefulWidget {
  final ProtokolProvider provider;

  const ProtokolProviderCard({required this.provider});

  @override
  State<ProtokolProviderCard> createState() => _ProtokolProviderCardState();
}

class _ProtokolProviderCardState extends State<ProtokolProviderCard> {
  @override
  Widget build(BuildContext context) {
    final isBookmarked = context.watch<HomeViewModel>().isEuroProtocolSaved(
      widget.provider.id,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.color_FFECECEC),
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
                  widget.provider.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, exception, stackTrace) {
                    print(exception);
                    return Center(
                      child: Text(
                        _initials(widget.provider.name),
                        style: const TextStyle(
                          color: AppTheme.color_FF31527A,
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
                            widget.provider.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (widget.provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 17,
                            color: AppTheme.color_FF3E9B6B,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.provider.type,
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
                          '${widget.provider.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '(${widget.provider.reviewsCount} ta sharh)',
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
              InkWell(
                onTap: () => context
                    .read<HomeViewModel>()
                    .toggleEuroProtocolBookmark(widget.provider.id),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: SvgPicture.asset(
                    isBookmarked
                        ? 'assets/icons/bookmarkfilled.svg'
                        : 'assets/icons/bookmark.svg',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/location.svg',
                colorFilter: ColorFilter.mode(
                  AppTheme.color_FFCA9D38,
                  BlendMode.srcATop,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.provider.address,
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
                  Text(
                    formatPrice(widget.provider.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.color_FF0F172A,
                    ),
                  ),
                  Text(
                    context.tr('per_from'),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.color_FF64748B,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 9.5, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGold,
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Text(
                    context.tr('view'),
                    style: TextStyle(
                      color: AppTheme.color_FFFFFFFF,
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
