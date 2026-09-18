import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/advokat_repository.dart';
import '../../../widgets/header_navigation.dart';
import '../../../widgets/header_screen.dart';
import '../../../widgets/lawyer_card.dart';
import '../../services/screens/organizations_screen.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class SavedLawyersScreen extends StatefulWidget {
  const SavedLawyersScreen({super.key});

  @override
  State<SavedLawyersScreen> createState() => _SavedLawyersScreenState();
}

class _SavedLawyersScreenState extends State<SavedLawyersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeViewModel>().loadSavedItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final lawyers = viewModel.savedLawyers;
    final organizations = viewModel.savedOrganizations;
    final hasSavedItems = lawyers.isNotEmpty || organizations.isNotEmpty;
    return _UtilityScaffold(
      title: context.tr('saved'),
      child: !hasSavedItems
          ? const _EmptyState(
              icon: Icons.bookmark_border,
              text: 'Saqlangan tashkilot yoki advokatlar yo‘q',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (organizations.isNotEmpty) ...[
                  _SavedSectionTitle(context.tr('organizations')),
                  ...organizations.map(
                    (organization) =>
                        OrganizationCard(organization: organization),
                  ),
                ],
                if (lawyers.isNotEmpty) ...[
                  _SavedSectionTitle(context.tr('lawyers')),
                  ...lawyers.map((lawyer) => LawyerCard(lawyer: lawyer)),
                ],
              ],
            ),
      activeItem: 'home',
    );
  }
}

class _SavedSectionTitle extends StatelessWidget {
  final String title;
  const _SavedSectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
    child: Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    ),
  );
}

class LawyersScreen extends StatelessWidget {
  const LawyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lawyers = context.watch<HomeViewModel>().popularLawyers;
    return _UtilityScaffold(
      title: context.tr('lawyers'),
      activeItem: 'services',
      child: lawyers.isEmpty
          ? const _EmptyState(
              icon: Icons.people_outline,
              text: 'Advokatlar topilmadi',
            )
          : Column(
              children: lawyers
                  .map((lawyer) => LawyerCard(lawyer: lawyer))
                  .toList(),
            ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = context.read<AdvokatRepository>().getNotifications();
  }

  Future<void> _reload() async {
    final request = context.read<AdvokatRepository>().getNotifications();
    setState(() => _notifications = request);
    await request;
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> response) {
    final raw = response['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _UtilityScaffold(
      title: context.tr('notifications'),
      activeItem: 'home',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final items = snapshot.hasData
              ? _items(snapshot.data!)
              : const <Map<String, dynamic>>[];
          if (snapshot.hasError || items.isEmpty) {
            return _EmptyState(
              icon: Icons.notifications_none,
              text: snapshot.hasError
                  ? context.tr('suggestion_failed')
                  : context.tr('no_data'),
            );
          }
          return Column(
            children: items.map((item) {
              final id = int.tryParse('${item['id'] ?? ''}');
              return _NotificationCard(
                title: '${item['title'] ?? ''}',
                body: '${item['body'] ?? ''}',
                unread: item['is_read'] != true,
                onTap: id == null || item['is_read'] == true
                    ? null
                    : () async {
                        try {
                          await context
                              .read<AdvokatRepository>()
                              .markNotificationRead(id);
                          await _reload();
                        } catch (_) {}
                      },
              );
            }).toList(),
          );
        },
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
  final names = const [
    'Aziz Karimov',
    'Aziza Sherpolatova',
    'Miraziz Eshmatov',
    'Aziz Toshpulatov',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FocusScope.of(context).requestFocus(FocusNode()),
    );
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
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/back.svg',
                    firstIconOnTap: () => Navigator.pop(context),
                    moveBack: true,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: context.tr('search'),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/search.svg'),
                        ),
                        suffixText: context.tr('close'),
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 4,
                ),
                itemCount: names.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.search,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  title: Text(
                    names[index],
                    style: const TextStyle(fontSize: 11),
                  ),
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
  String category = 'filter_all';
  String type = 'legal_advice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('filter_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            _FilterSection(
              title: context.tr('result_type'),
              child: Wrap(
                spacing: 6,
                children: ['filter_all', 'organizations', 'lawyers']
                    .map(
                      (key) => _ChoiceChip(
                        text: context.tr(key),
                        selected: category == key,
                        onTap: () => setState(() => category = key),
                      ),
                    )
                    .toList(),
              ),
            ),
            _FilterSection(
              title: context.tr('service_type_title'),
              child: Column(
                children: ['legal_advice', 'family_law', 'civil_law']
                    .map(
                      (key) => RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: key,
                        groupValue: type,
                        onChanged: (value) => setState(() => type = value!),
                        title: Text(
                          context.tr(key),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            _FilterSection(
              title: context.tr('rating'),
              child: DropdownButtonFormField<String>(
                value: context.tr('filter_all'),
                items: [
                  DropdownMenuItem(
                    value: context.tr('filter_all'),
                    child: Text(context.tr('filter_all')),
                  ),
                ],
                onChanged: (_) {},
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            _FilterSection(
              title: context.tr('price'),
              child: Column(
                children: [
                  RangeSlider(
                    values: const RangeValues(100000, 200000),
                    min: 0,
                    max: 500000,
                    onChanged: (_) {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('minimum_price'),
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        context.tr('maximum_price'),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('clear')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('apply')),
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

class _UtilityScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final String activeItem;

  const _UtilityScaffold({
    required this.title,
    required this.child,
    required this.activeItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 70, 12, 20),
              children: [child],
            ),
            HeaderScreen(
              title: title,
              firstActionIconPath: 'assets/icons/search.svg',
              onFirstActionTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final bool unread;
  final VoidCallback? onTap;
  const _NotificationCard({
    required this.title,
    required this.body,
    this.unread = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? AppTheme.color_FFF1F5F9 : AppTheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppTheme.buttonGold : AppTheme.tagBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: selected ? AppTheme.surface : AppTheme.textSecondary,
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    ),
  );
}
