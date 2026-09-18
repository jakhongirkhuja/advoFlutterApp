import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/home/lawyer.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../widgets/header_navigation.dart';

class LawyerProfileScreen extends StatefulWidget {
  final Lawyer lawyer;

  const LawyerProfileScreen({super.key, required this.lawyer});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final lawyer = widget.lawyer;
    final tabs = [
      context.tr('about_label'),
      context.tr('achievements'),
      context.tr('services'),
      context.tr('certificate'),
      context.tr('reviews'),
    ];
    final isSaved = context.watch<HomeViewModel>().isLawyerSaved(lawyer.id);
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 62, 16, 96),
              children: [
                _LawyerIdentity(lawyer: lawyer),
                const SizedBox(height: 12),
                _ProfileTabs(
                  tabs: tabs,
                  selected: selectedTab,
                  onSelected: (index) => setState(() => selectedTab = index),
                ),
                const SizedBox(height: 12),
                _LawyerTabBody(index: selectedTab, lawyer: lawyer),
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
                    firstIconOnTap: () => Navigator.pop(context),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: AppTheme.surface,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context
                    .read<HomeViewModel>()
                    .toggleLawyerBookmark(lawyer.id),
                style: IconButton.styleFrom(
                  backgroundColor: isSaved
                      ? AppTheme.buttonGold
                      : AppTheme.tagBackground,
                  foregroundColor: isSaved
                      ? AppTheme.surface
                      : AppTheme.textPrimary,
                ),
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.appointmentCreate,
                    arguments: lawyer,
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 17),
                  label: Text(context.tr('book_appointment')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LawyerIdentity extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerIdentity({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final imageUrl = lawyer.imageUrl.isNotEmpty
        ? lawyer.imageUrl
        : '${AppConfig.dummyImageBaseUrl}/lawyer-${lawyer.id}/160/160';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -1.6),
                radius: 1.1,
                colors: [AppTheme.color_FFD9B875, AppTheme.color_00FFFFFF],
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
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 101,
                      height: 101,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 101,
                        height: 101,
                        color: AppTheme.avatarBackground,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/default_user.jpg',
                          fit: BoxFit.fill,
                          height: 101,
                        ),
                      ),
                    ),
                  ),
                ),
                if (lawyer.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: AppTheme.success,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 6,
            right: 6,
            child: Column(
              children: [
                Text(
                  lawyer.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.color_FF1D1816,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Text(
                    context.tr(lawyer.title),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textChoco,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      _StatItem(
                        iconPath: 'assets/icons/experience.svg',
                        label: context.tr('experience'),
                        value: '${lawyer.experienceYears}',
                      ),
                      _StatItem(
                        iconPath: 'assets/icons/appointments.svg',
                        label: context.tr('appointments'),
                        value: '+980',
                        icon: Icons.how_to_reg,
                        color: AppTheme.success,
                      ),
                      _StatItem(
                        iconPath: 'assets/icons/star.svg',
                        label: context.tr('trust_rating'),
                        value: lawyer.rating.toStringAsFixed(1),
                        icon: Icons.star,
                        color: AppTheme.star,
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
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String iconPath;

  const _StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textChoco),
            ),
            const SizedBox(height: 5),
            Row(
              spacing: 3,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconPath),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

class _ProfileTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  const _ProfileTabs({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(45),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selected == index;
            return GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.buttonGold
                      : AppTheme.transparent,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? AppTheme.surface
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LawyerTabBody extends StatelessWidget {
  final int index;
  final Lawyer lawyer;

  const _LawyerTabBody({required this.index, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return const _AchievementsContent();
      case 2:
        return _ServicesContent(lawyer: lawyer);
      case 3:
        return const _CertificatesContent();
      case 4:
        return _ReviewsContent(lawyer: lawyer);
      default:
        return _AboutContent(lawyer: lawyer);
    }
  }
}

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent();

  @override
  Widget build(BuildContext context) {
    const achievements = [
      AchievementItem(size: '1.2 Mb', fileType: 'PNG'),
      AchievementItem(size: '900 Kb', fileType: 'PDF'),
      AchievementItem(size: '2.4 Mb', fileType: 'PDF'),
      AchievementItem(size: '700 Kb', fileType: 'PNG'),
      AchievementItem(size: '1.8 Mb', fileType: 'PDF'),
    ];

    return Column(
      children: achievements
          .map((achievement) => _AchievementTile(achievement: achievement))
          .toList(),
    );
  }
}

class AchievementItem {
  final String size;
  final String fileType;

  const AchievementItem({required this.size, required this.fileType});
}

class _AchievementTile extends StatelessWidget {
  final AchievementItem achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.pageBackground,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  size: 21,
                  color: AppTheme.black87,
                ),
                Text(
                  achievement.fileType,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('achievements'),
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.size,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textChoco,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textChoco, size: 25),
        ],
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final Lawyer lawyer;

  const _AboutContent({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContentCard(
          title: context.tr('about_label'),
          child: Text(context.tr('lawyer_about_default'), style: _bodyStyle),
        ),

        _ContentCard(
          title: context.tr('specialties'),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (final tag in lawyer.tags) _Tag(text: context.tr(tag)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPreview extends StatelessWidget {
  const _LocationPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.color_FFE3E9DC,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.location_on, color: AppTheme.danger, size: 32),
      ),
    );
  }
}

class _ServicesContent extends StatelessWidget {
  final Lawyer lawyer;

  const _ServicesContent({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final services = lawyer.tags.isEmpty ? const ['legal_advice'] : lawyer.tags;
    return Column(
      children: services.map((service) {
        return _ContentCard(
          title: context.tr(service),
          child: Row(
            children: [
              Text(
                '${lawyer.pricePerMinute}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                context.tr('per_from'),
                style: const TextStyle(fontSize: 14, color: AppTheme.textChoco),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CertificateItem {
  final String title;
  final String size;
  final String date;
  final String fileUrl;
  final String fileType;

  const CertificateItem({
    required this.title,
    required this.size,
    required this.date,
    required this.fileUrl,
    this.fileType = 'PNG',
  });
}

class _CertificatesContent extends StatelessWidget {
  const _CertificatesContent();

  @override
  Widget build(BuildContext context) {
    final certificates = [
      CertificateItem(
        title: context.tr('certificate'),
        size: '1.2 Mb',
        date: '12.03.2022',
        fileUrl: 'https://example.com/files/advokatlik_guvohnomasi.png',
        fileType: 'PNG',
      ),
      CertificateItem(
        title: context.tr('patent'),
        size: '2.4 Mb',
        date: '15.04.2022',
        fileUrl: 'https://example.com/files/patent_sertifikati.pdf',
        fileType: 'PDF',
      ),
      CertificateItem(
        title: context.tr('diploma'),
        size: '850 Kb',
        date: '01.01.2021',
        fileUrl: 'https://example.com/files/diplom_nusxasi.pdf',
        fileType: 'PDF',
      ),
    ];

    return Column(
      children: certificates
          .map((item) => _CertificateTile(item: item))
          .toList(),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  final CertificateItem item;

  const _CertificateTile({required this.item});

  Future<void> _downloadFile(BuildContext context) async {
    final uri = Uri.parse(item.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.tr('download_failed'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _downloadFile(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Custom circular file-type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.pageBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/download.svg'),
                      Text(
                        item.fileType,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Certificate metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.color_FF0F172A,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            item.size,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textChoco,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset('assets/icons/calendar.svg'),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textChoco,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Trailing navigation arrow
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textChoco,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsContent extends StatelessWidget {
  final Lawyer lawyer;

  const _ReviewsContent({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.color_FFFFFFE8,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.color_FFFFEEA0, width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                lawyer.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '★★★★★',
                    style: TextStyle(color: AppTheme.star, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context
                        .tr('reviews_count')
                        .replaceAll('{count}', '${lawyer.reviewsCount}'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ReviewCard(name: 'Madina A.', text: context.tr('review_satisfied')),
        _ReviewCard(
          name: 'Azizbek R.',
          text: context.tr('review_professional'),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String text;

  const _ReviewCard({required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.tagBackground,
                child: Icon(Icons.person_outline, color: AppTheme.textChoco),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                '★★★★★',
                style: TextStyle(color: AppTheme.star, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: _bodyStyle),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary,),
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 10),
            color: AppTheme.textChoco.withValues(alpha: 0.2),
          ),
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

String _initials(String name) => name
    .split(' ')
    .take(2)
    .map((part) => part.isEmpty ? '' : part[0])
    .join()
    .toUpperCase();

const _bodyStyle = TextStyle(
  fontSize: 16,
  height: 1.3,
  color: AppTheme.textChoco,
);
