import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_navigation.dart';
import '../../../widgets/header_screen.dart';
import '../../../widgets/lawyer_card.dart';
import '../../../widgets/public_bottom_navigation_bar.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class SavedLawyersScreen extends StatelessWidget {
  const SavedLawyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lawyers = context.watch<HomeViewModel>().savedLawyers;
    return _UtilityScaffold(
      title: 'Saqlanganlar',
      child: lawyers.isEmpty
          ? const _EmptyState(icon: Icons.bookmark_border, text: 'Saqlangan advokatlar yo‘q')
          : Column(children: lawyers.take(3).map((lawyer) => LawyerCard(lawyer: lawyer)).toList()),
      activeItem: 'home',
    );
  }
}

class LawyersScreen extends StatelessWidget {
  const LawyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lawyers = context.watch<HomeViewModel>().popularLawyers;
    return _UtilityScaffold(
      title: 'Advokatlar',
      activeItem: 'services',
      child: lawyers.isEmpty
          ? const _EmptyState(icon: Icons.people_outline, text: 'Advokatlar topilmadi')
          : Column(children: lawyers.map((lawyer) => LawyerCard(lawyer: lawyer)).toList()),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _UtilityScaffold(
      title: 'Bildirishnomalar',
      activeItem: 'home',
      child: Column(
        children: const [
          _NotificationCard(title: 'Qabul eslatmasi', body: 'Ertaga soat 14:30 da Aziz Karimov bilan huquqiy maslahat qabuliga yozilgansiz.'),
          _NotificationCard(title: 'Uchrashuv yakunlandi', body: 'Chorrahada soat 10:00 da Nodirbek bilan uchrashuvingiz muvaffaqiyatli yakunlandi.'),
          _NotificationCard(title: 'Eslatma xabari', body: 'Jumaga kuni 10:00 da Shahrizod bilan marketing strategiyasi bo‘yicha fikr almashing.'),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  final names = const ['Aziz Karimov', 'Aziza Sherpolatova', 'Miraziz Eshmatov', 'Aziz Toshpulatov'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context).requestFocus(FocusNode()));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  HeaderNavigation(firstIconPath: 'assets/icons/back.svg', firstIconOnTap: () => Navigator.pop(context), moveBack: true),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Izlash',
                        prefixIcon: Padding(padding: const EdgeInsets.all(12), child: SvgPicture.asset('assets/icons/search.svg')),
                        suffixText: 'Yopish',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                itemCount: names.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.search, size: 14, color: AppTheme.textMuted),
                  title: Text(names[index], style: const TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String category = 'Barchasi';
  String type = 'Huquqiy maslahat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Filtr', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 18))]),
            _FilterSection(title: 'Natija turi', child: Wrap(spacing: 6, children: ['Barchasi', 'Tashkilotlar', 'Advokatlar'].map((item) => _ChoiceChip(text: item, selected: category == item, onTap: () => setState(() => category = item))).toList())),
            _FilterSection(title: 'Xizmat turi', child: Column(children: ['Huquqiy maslahat', 'Oila huquqi', 'Fuqarolik huquqi'].map((item) => RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, value: item, groupValue: type, onChanged: (value) => setState(() => type = value!), title: Text(item, style: const TextStyle(fontSize: 11)))).toList())),
            _FilterSection(title: 'Reyting', child: DropdownButtonFormField<String>(value: 'Barchasi', items: const [DropdownMenuItem(value: 'Barchasi', child: Text('Barchasi'))], onChanged: (_) {}, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(borderSide: BorderSide.none)))),
            _FilterSection(title: 'Narx', child: Column(children: [RangeSlider(values: const RangeValues(100000, 200000), min: 0, max: 500000, onChanged: (_) {}), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Minimal narx', style: TextStyle(fontSize: 10)), Text('Maksimal narx', style: TextStyle(fontSize: 10))])])),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Tozalash'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Qo‘llash')))]),
          ],
        ),
      ),
    );
  }
}

class _UtilityScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final String activeItem;

  const _UtilityScaffold({required this.title, required this.child, required this.activeItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(children: [ListView(padding: const EdgeInsets.fromLTRB(12, 70, 12, 20), children: [child]), HeaderScreen(title: title, firstActionIconPath: 'assets/icons/search.svg', onFirstActionTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))]),
      ),

    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  const _NotificationCard({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(body, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary))]));
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 8), child]));
}

class _ChoiceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.text, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: selected ? AppTheme.buttonGold : AppTheme.tagBackground, borderRadius: BorderRadius.circular(14)), child: Text(text, style: TextStyle(fontSize: 9, color: selected ? Colors.white : AppTheme.textSecondary))));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => SizedBox(height: 300, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 40, color: AppTheme.textLight), const SizedBox(height: 12), Text(text, style: const TextStyle(color: AppTheme.textMuted))])));
}
