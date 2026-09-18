import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/advokat_repository.dart';
import '../../../widgets/custom_icon_design.dart';
import '../../../widgets/header_screen.dart';

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> {
  late Future<List<Map<String, dynamic>>> _devices;

  @override
  void initState() {
    super.initState();
    _devices = context.read<AdvokatRepository>().getClientDevices();
  }

  Future<void> _reload() async {
    final request = context.read<AdvokatRepository>().getClientDevices();
    setState(() => _devices = request);
    await request;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.backgroundWhite,
    body: SafeArea(
      child: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _devices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final devices = snapshot.data ?? const [];
              if (snapshot.hasError || devices.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
                    children: [
                      Text(
                        snapshot.hasError
                            ? context.tr('suggestion_failed')
                            : context.tr('no_data'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final device = devices[index];
                    final platform =
                        '${device['platform'] ?? device['device_type'] ?? ''}'
                            .toLowerCase();
                    final name =
                        '${device['device_name'] ?? device['model'] ?? device['name'] ?? platform}';
                    final ip = '${device['ip_address'] ?? device['ip'] ?? ''}';
                    final active =
                        device['is_current'] == true ||
                        device['active'] == true;
                    final id = int.tryParse('${device['id'] ?? ''}');
                    return _DeviceTile(
                      time: active
                          ? null
                          : '${device['last_active_at'] ?? device['updated_at'] ?? ''}',
                      icon:
                          platform.contains('ios') ||
                              platform.contains('iphone')
                          ? 'assets/icons/ios.svg'
                          : 'assets/icons/android.svg',
                      title: name,
                      subtitle: context.tr(
                        active ? 'currently_active' : 'inactive',
                      ),
                      ip: ip.isEmpty ? '' : 'IP: $ip',
                      active: active,
                      onTap: () => _showDeviceDetails(
                        context,
                        id,
                        name,
                        ip,
                        active ? null : '${device['last_active_at'] ?? ''}',
                      ),
                    );
                  },
                ),
              );
            },
          ),
          HeaderScreen(title: context.tr('active_devices')),
        ],
      ),
    ),
  );

  Future<void> _showDeviceDetails(
    BuildContext context,
    int? id,
    String name,
    String ip,
    String? time,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(Icons.close, size: 24),
                    ),
                  ),
                ),
                CustomIconDesign(
                  icon: name.startsWith('iPhone')
                      ? 'assets/icons/ios.svg'
                      : 'assets/icons/android.svg',
                  mainColor: AppTheme.color_FF1C8AFF,
                  secondaryColor: AppTheme.color_FF69AFFF,
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
                    color: AppTheme
                        .backgroundWhite, // Restored original inner container color
                    borderRadius: BorderRadius.circular(46),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.surface,
                        child: SvgPicture.asset('assets/icons/ip.svg'),
                      ),
                      const SizedBox(width: 12),
                      Text(ip, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 63), // Restored original height spacing
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.color_FFFB2C36,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: id == null
                        ? null
                        : () async {
                            try {
                              await context
                                  .read<AdvokatRepository>()
                                  .revokeClientDevice(id);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              await _reload();
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('suggestion_failed'),
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(
                      context.tr('remove_device'),
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
    color: AppTheme.color_FFFFFFFF,
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
                          color: AppTheme.black,
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
