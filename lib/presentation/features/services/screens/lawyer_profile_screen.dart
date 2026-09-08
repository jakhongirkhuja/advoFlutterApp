import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';

class LawyerProfileScreen extends StatefulWidget {
  final Lawyer lawyer;

  const LawyerProfileScreen({super.key, required this.lawyer});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  static const tabs = ['Ma’lumot', 'Xizmatlar', 'Sertifikatlar', 'Sharhlar'];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final lawyer = widget.lawyer;
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        leading: const BackButton(),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _Header(lawyer: lawyer),
          const SizedBox(height: 10),
          _Stats(lawyer: lawyer),
          const SizedBox(height: 10),
          _Tabs(
            selectedTab: selectedTab,
            onSelected: (index) => setState(() => selectedTab = index),
          ),
          const SizedBox(height: 10),
          _TabBody(index: selectedTab, lawyer: lawyer),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F1F1)),
                icon: const Icon(Icons.bookmark_border),
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

class _Header extends StatelessWidget {
  final Lawyer lawyer;

  const _Header({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6DF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE4EDF6),
            child: Text(
              _initials(lawyer.name),
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF31527A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(lawyer.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(lawyer.title, style: const TextStyle(fontSize: 10, color: Color(0xFF777777))),
          ),
        ],
      ),
    );
  }

  String _initials(String name) => name.split(' ').take(2).map((part) => part[0]).join().toUpperCase();
}

class _Stats extends StatelessWidget {
  final Lawyer lawyer;

  const _Stats({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: 'Tajriba', value: '${lawyer.experienceYears} yil', icon: Icons.business_center_outlined),
        _Stat(label: 'Qabullar', value: '+980', icon: Icons.people_alt_outlined),
        _Stat(label: 'Reyting', value: '${lawyer.rating}', icon: Icons.star, last: true),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool last;

  const _Stat({required this.label, required this.value, required this.icon, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: last ? 0 : 6),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF777777))),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 13, color: const Color(0xFFD3A944)), const SizedBox(width: 3), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onSelected;

  const _Tabs({required this.selectedTab, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: List.generate(lawyerProfileTabs.length, (index) {
          final selected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                decoration: BoxDecoration(color: selected ? const Color(0xFFDDB55E) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                child: Text(lawyerProfileTabs[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: selected ? Colors.white : const Color(0xFF555555))),
              ),
            ),
          );
        }),
      ),
    );
  }
}

const lawyerProfileTabs = ['Ma’lumot', 'Xizmatlar', 'Sertifikatlar', 'Sharhlar'];

class _TabBody extends StatelessWidget {
  final int index;
  final Lawyer lawyer;

  const _TabBody({required this.index, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return const _ServicesTab();
      case 2:
        return const _CertificatesTab();
      case 3:
        return _ReviewsTab(lawyer: lawyer);
      default:
        return const _AboutTab();
    }
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WhiteCard(
          title: 'Tavsif',
          child: Text('Ot​​abek Alisherov fuqarolik va biznes huquqi bo‘yicha tajribali mutaxassis. Mijozlarga sud jarayonlari va huquqiy masalalar bo‘yicha yordam ko‘rsatadi.', style: TextStyle(fontSize: 11, height: 1.35, color: Color(0xFF666666))),
        ),
        const _WhiteCard(
          title: 'Mutaxassisliklari',
          child: Wrap(spacing: 6, runSpacing: 6, children: [_Pill('Fuqarolik huquqi'), _Pill('Biznes huquqi'), _Pill('Sud ishlari'), _Pill('Shartnoma huquqi')]),
        ),
        _WhiteCard(
          title: 'Joylashuv',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 86, decoration: BoxDecoration(color: const Color(0xFFE3E9DC), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.location_on, color: Colors.redAccent, size: 32))), const SizedBox(height: 6), const Text('Toshkent shahri, Yunusobod tumani, Amir Temur shoh ko‘chasi 108-uy', style: TextStyle(fontSize: 10, color: Color(0xFF666666)))]),
        ),
      ],
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    const services = ['Sudda vakillik', 'Da’vo arizasini tayyorlash', 'Sudga tayyorgarlik', 'Apellyatsiya shikoyati'];
    return Column(children: services.map((service) => _PriceCard(title: service)).toList());
  }
}

class _PriceCard extends StatelessWidget {
  final String title;

  const _PriceCard({required this.title});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))), const Text('200 000 so‘m/dan', style: TextStyle(fontSize: 10, color: Color(0xFF666666)))]));
}

class _CertificatesTab extends StatelessWidget {
  const _CertificatesTab();

  @override
  Widget build(BuildContext context) {
    const certificates = ['Advokatlik guvohnomasi', 'Patent sertifikati', 'Diplom nusxasi', 'Shaxsni tasdiqlovchi guvohnoma', 'Mehnat shartnomasi'];
    return Column(children: certificates.map((certificate) => _CertificateCard(title: certificate)).toList());
  }
}

class _CertificateCard extends StatelessWidget {
  final String title;

  const _CertificateCard({required this.title});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [const CircleAvatar(radius: 16, backgroundColor: Color(0xFFF1F1F1), child: Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF777777))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), const Text('1.2 Mb   12.03.2022', style: TextStyle(fontSize: 9, color: Color(0xFF888888)))]))]));
}

class _ReviewsTab extends StatelessWidget {
  final Lawyer lawyer;

  const _ReviewsTab({required this.lawyer});

  @override
  Widget build(BuildContext context) => Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF9DF), borderRadius: BorderRadius.circular(14)), child: Row(children: [Text('${lawyer.rating}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('★★★★★', style: TextStyle(color: Color(0xFFE2A900), fontSize: 17)), Text('354 baholandi', style: TextStyle(fontSize: 9, color: Color(0xFF777777)))])])), const SizedBox(height: 8), const _ReviewCard(name: 'Madina A.', text: 'Dr. Sardor Tursunov — 12 yildan ortiq tajribaga ega terapevt. Bemorlарni tushunadi.'), const _ReviewCard(name: 'Madina A.', text: 'Xizmatidan mamnunman, tavsiya qilaman.')]);
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String text;

  const _ReviewCard({required this.name, required this.text});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(radius: 13, child: Icon(Icons.person_outline, size: 15)), const SizedBox(width: 8), Expanded(child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))), const Text('★★★★★', style: TextStyle(color: Color(0xFFE2A900), fontSize: 11))]), const SizedBox(height: 7), Text(text, style: const TextStyle(fontSize: 10, height: 1.3, color: Color(0xFF666666)))]));
}

class _WhiteCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _WhiteCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 8), child]));
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill(this.text);

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(fontSize: 9)));
}
