import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
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
  static const tabs = ['Ma’lumot','Yutuqlarim','Xizmatlar', 'Sertifikatlar', 'Sharhlar'];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final lawyer = widget.lawyer;
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.read<HomeViewModel>().toggleLawyerBookmark(lawyer.id),
                style: IconButton.styleFrom(
                  backgroundColor: isSaved ? AppTheme.buttonGold : AppTheme.tagBackground,
                  foregroundColor: isSaved ? Colors.white : AppTheme.textPrimary,
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
                  label: const Text('Qabulga yozilish'),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -1.3),
                radius: 1.5,
                colors: [Color(0xFFD9B875), Color(0x00FFFFFF)],
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
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                        child: Text(
                          _initials(lawyer.name),
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                if (lawyer.isVerified)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.verified, color: AppTheme.success, size: 20),
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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D1816)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF3F1F1), borderRadius: BorderRadius.circular(21)),
                  child: Text(lawyer.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textChoco)),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.pageBackground, borderRadius: BorderRadius.circular(22)),
                  child: Row(
                    children: [
                      _StatItem(label: 'Tajriba', value: '${lawyer.experienceYears} yil'),
                      _StatItem(label: 'Qabullar', value: '+980', icon: Icons.how_to_reg, color: AppTheme.success),
                      _StatItem(label: 'Reyting', value: lawyer.rating.toStringAsFixed(1), icon: Icons.star, color: AppTheme.star),
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

  const _StatItem({required this.label, required this.value, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textChoco)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, size: 15, color: color),
                if (icon != null) const SizedBox(width: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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

  const _ProfileTabs({required this.tabs, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(45)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selected == index;
            return GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(color: isSelected ? AppTheme.buttonGold : Colors.transparent, borderRadius: BorderRadius.circular(45)),
                child: Text(tabs[index], style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : AppTheme.textSecondary)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 21, color: Colors.black87),
                Text(
                  achievement.fileType,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yutuqlarim', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(achievement.size, style: const TextStyle(fontSize: 15, color: AppTheme.textChoco)),
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
        const _ContentCard(
          title: 'Tavsif',
          child: Text(
            'Tajribali advokat fuqarolik va biznes huquqi bo‘yicha mijozlarga sud jarayonlari hamda huquqiy masalalarda yordam ko‘rsatadi.',
            style: _bodyStyle,
          ),
        ),

        _ContentCard(
          title: 'Mutaxassisliklari',
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (final tag in lawyer.tags)
                _Tag(text: tag),
            ],
          ),
        )
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
      decoration: BoxDecoration(color: const Color(0xFFE3E9DC), borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Icon(Icons.location_on, color: Colors.redAccent, size: 32)),
    );
  }
}

class _ServicesContent extends StatelessWidget {
  final Lawyer lawyer;

  const _ServicesContent({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final services = lawyer.tags.isEmpty ? const ['Huquqiy maslahat'] : lawyer.tags;
    return Column(
      children: services.map((service) {
        return _ContentCard(
          title: service,
          child: Row(
            children: [
              Text('${lawyer.pricePerMinute}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Text('/so\'mdan', style: TextStyle(fontSize: 14, color: AppTheme.textChoco)),
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
    const certificates = [
      CertificateItem(
        title: 'Advokatlik guvohnomasi',
        size: '1.2 Mb',
        date: '12.03.2022',
        fileUrl: 'https://example.com/files/advokatlik_guvohnomasi.png',
        fileType: 'PNG',
      ),
      CertificateItem(
        title: 'Patent sertifikati',
        size: '2.4 Mb',
        date: '15.04.2022',
        fileUrl: 'https://example.com/files/patent_sertifikati.pdf',
        fileType: 'PDF',
      ),
      CertificateItem(
        title: 'Diplom nusxasi',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faylni yuklab bo\'lmadi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                    color: Color(0xFFF2F2F2),
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
                          color: Colors.black87,
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
                          color: Colors.black87,
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
          decoration: BoxDecoration(color: const Color(0xFFFFFFE8), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFEEA0), width: 1.5)),
          child: Row(
            children: [
              Text(lawyer.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('★★★★★', style: TextStyle(color: AppTheme.star, fontSize: 22)),
                  const SizedBox(height: 8),
                  Text('${lawyer.reviewsCount} baholadi', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _ReviewCard(name: 'Madina A.', text: 'Xizmatidan mamnunman, huquqiy masalani tushunarli qilib izohlab berdi.'),
        const _ReviewCard(name: 'Azizbek R.', text: 'Professional yondashuv va tezkor maslahat uchun rahmat.'),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: AppTheme.tagBackground, child: Icon(Icons.person_outline, color: AppTheme.textChoco)),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              const Text('★★★★★', style: TextStyle(color: AppTheme.star, fontSize: 14)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(vertical: 10),
          color: AppTheme.textChoco.withValues(alpha: 0.2),
        ),
        child,
      ]),
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
      decoration: BoxDecoration(color: AppTheme.tagBackground, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
    );
  }
}

String _initials(String name) => name.split(' ').take(2).map((part) => part.isEmpty ? '' : part[0]).join().toUpperCase();

const _bodyStyle = TextStyle(fontSize: 16, height: 1.3, color: AppTheme.textChoco);
