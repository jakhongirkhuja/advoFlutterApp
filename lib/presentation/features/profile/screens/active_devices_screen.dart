import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_screen.dart';

class ActiveDevicesScreen extends StatelessWidget {
  const ActiveDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.backgroundWhite,
    body: SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
            children: [
              _DeviceTile(
                icon: 'assets/icons/ios.svg',
                title: 'iPhone 15 Pro',
                subtitle: 'Hozir faol',
                ip: 'IP: 185.74.22.123',
                active: true,

                onTap: () => _showDeviceDetails(context, 'iPhone 15 Pro','185.74.22.123',null),
              ),
              const SizedBox(height: 16),
              const Text(
                'Boshqa qurilmalar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _DeviceTile(
                time: '5 daqiqa oldin',
                icon: 'assets/icons/android.svg',
                title: 'Samsung A12',
                subtitle: 'Faol emas',
                ip: 'IP: 185.74.22.123',
                onTap: () => _showDeviceDetails(context, 'Samsung A12','185.74.22.123','5 daqiqa oldin'),
              ),
            ],
          ),
          const HeaderScreen(title: 'Faol qurilmalar'),
        ],
      ),
    ),
  );

  Future<void> _showDeviceDetails(
      BuildContext context,
      String name,
      String ip,
      String? time,
      ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(

                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.pageBackground,
                          borderRadius: BorderRadius.circular(32)
                        ),
                        child: const Icon(Icons.close, size: 24,)),
                  ),
                ),
                CustomIconDesign(
                  icon: name.startsWith('iPhone')
                      ? 'assets/icons/ios.svg'
                      : 'assets/icons/android.svg',
                  mainColor: const Color(0xFF1C8AFF),
                  secondaryColor: const Color(0xFF69AFFF),
                ),
                const SizedBox(height: 7),
                Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    time != null
                        ? Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite, // Restored original inner container color
                    borderRadius: BorderRadius.circular(46),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset('assets/icons/ip.svg'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ip,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 63), // Restored original height spacing
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Chiqarib yuborish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _DeviceTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String ip;
  final bool active;
  final VoidCallback onTap;
  final String? time;

  const _DeviceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.ip,
    this.time,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.pageBackground,
              child: SvgPicture.asset(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      time != null
                          ? Text(time!, style: const TextStyle(fontSize: 14))
                          : SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: active
                              ? AppTheme.success
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        backgroundColor: AppTheme.pageBackground,
                        radius: 3,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ip,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
