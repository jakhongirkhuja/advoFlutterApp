import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';

class PartnershipScreen extends StatelessWidget {
  const PartnershipScreen({super.key});

  static const numbers = <String>[
    '+998 91 777 77 77',
    '+998 91 777 88 88',
  ];

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(
      scheme: 'tel',
      path: number.replaceAll(RegExp(r'\D'), ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu qurilmada telefon qilish ilovasi topilmadi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
            itemCount: numbers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(49),

              child: InkWell(
                onTap: () => _callNumber(context, numbers[index]),

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        numbers[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      SvgPicture.asset('assets/icons/call.svg'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const HeaderScreen(title: 'Reklama va hamkorlik'),
        ],
      ),
    ),
  );
}
