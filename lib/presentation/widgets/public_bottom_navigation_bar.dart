import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class PublicBottomNavigationBar extends StatelessWidget {
  final String activeItem;
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onServicesTap;
  final VoidCallback? onAppointmentsTap;
  final VoidCallback? onAddTap;

  const PublicBottomNavigationBar({
    super.key,
    this.activeItem = 'home',
    this.onHomeTap,
    this.onProfileTap,
    this.onServicesTap,
    this.onAppointmentsTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(
              icon: Icons.home_filled,
              label: AppLocalizations.of(context)?.translate('home') ?? 'Asosiy',
              active: activeItem == 'home',
              onTap: onHomeTap,
            ),
            _BottomItem(
              icon: Icons.grid_view_rounded,
              label: AppLocalizations.of(context)?.translate('services') ?? 'Xizmatlar',
              active: activeItem == 'services',
              onTap: onServicesTap,
            ),
            InkWell(
              onTap: onAddTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.surface, size: 28),
              ),
            ),
            _BottomItem(
              icon: Icons.calendar_month_outlined,
              label: AppLocalizations.of(context)?.translate('appointments') ?? 'Qabullar',
              active: activeItem == 'appointments',
              onTap: onAppointmentsTap,
            ),
            _BottomItem(
              icon: Icons.person_outline,
              label: AppLocalizations.of(context)?.translate('profile') ?? 'Profil',
              active: activeItem == 'profile',
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primaryGold : AppTheme.textLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
