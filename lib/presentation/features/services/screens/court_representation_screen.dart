import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';
import '../../../widgets/lawyer_card.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class CourtRepresentationScreen extends StatelessWidget {
  const CourtRepresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlueDark,
        foregroundColor: AppTheme.surface,
        centerTitle: true,
        title: const Text('Sudda vakillik', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.zero),
            icon: const Icon(Icons.chevron_left, size: 20, color: AppTheme.primaryBlueDark),
          ),
        ),
        actions: [
          _HeaderButton(icon: Icons.search, onTap: () {}),
          const SizedBox(width: 4),
          _HeaderButton(icon: Icons.tune, onTap: () {}),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          const _AboutDropdown(),
          const SizedBox(height: 10),
          if (home.isLoading)
            const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          else
            ...home.popularLawyers.map((lawyer) => LawyerCard(lawyer: lawyer)),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(onPressed: onTap, icon: Icon(icon, size: 19, color: AppTheme.primaryBlueDark), style: IconButton.styleFrom(backgroundColor: AppTheme.surface, padding: EdgeInsets.zero));
}

class _AboutDropdown extends StatefulWidget {
  const _AboutDropdown();

  @override
  State<_AboutDropdown> createState() => _AboutDropdownState();
}

class _AboutDropdownState extends State<_AboutDropdown> {
  String _selected = 'Sudda vakillik haqida';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: _openDropdown,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Expanded(child: Text(_selected, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              const Icon(Icons.keyboard_arrow_down, size: 17, color: Color(0xFF777777)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDropdown() async {
    final value = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Xizmat turini tanlang'),
        actions: [
          for (final option in const [
            'Sudda vakillik haqida',
            'Fuqarolik sudlari',
            'Biznes nizolari',
            'Mehnat nizolari',
          ])
            CupertinoActionSheetAction(
              isDefaultAction: option == _selected,
              onPressed: () => Navigator.pop(context, option),
              child: Text(option),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
      ),
    );

    if (value != null && mounted) {
      setState(() => _selected = value);
    }
  }
}



class _Avatar extends StatelessWidget {
  final Lawyer lawyer;

  const _Avatar({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final initials = lawyer.name.split(' ').take(2).map((part) => part[0]).join().toUpperCase();
    return Container(
      width: 43,
      height: 43,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFFE8F0F8), borderRadius: BorderRadius.circular(12)),
      child: Image.network(
        lawyer.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(child: Text(initials, style: const TextStyle(color: Color(0xFF31527A), fontWeight: FontWeight.w800, fontSize: 13))),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(fontSize: 8, color: Color(0xFF555555))));
}
