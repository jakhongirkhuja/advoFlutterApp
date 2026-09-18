import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';
import '../../../widgets/header_screen.dart';
import '../viewmodels/appointments_viewmodel.dart';
import '../../../../data/models/appointments/appointment.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  final String title;
  final bool showBottomNavigation;
  final bool showSearchAction;

  const AppointmentsScreen({
    super.key,
    this.title = 'appointments',
    this.showBottomNavigation = true,
    this.showSearchAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: viewModel.loadAppointments,
              edgeOffset: 120,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
                children: [
                  const SizedBox(height: 18),
                  if (viewModel.isLoading)
                    const _LoadingCard()
                  else if (viewModel.appointments.isEmpty)
                    const _EmptyState()
                  else
                    ...viewModel.appointments.map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AppointmentCard(appointment: appointment),
                      ),
                    ),
                ],
              ),
            ),
            HeaderScreen(
              title: title == 'appointments'
                  ? context.tr('appointments')
                  : title,
              firstActionIconPath: showSearchAction
                  ? 'assets/icons/search.svg'
                  : null,
              onFirstActionTap: showSearchAction
                  ? () => Navigator.pushNamed(context, AppRouter.search)
                  : null,
              showBackIcon: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNavigation
          ? PublicBottomNavigationBar(
              activeItem: 'appointments',
              onAddTap: () =>
                  Navigator.pushNamed(context, AppRouter.aiAssistant),
              onServicesTap: () =>
                  Navigator.pushNamed(context, AppRouter.services),
              onHomeTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.home,
                (route) => false,
              ),
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRouter.profile),
            )
          : null,
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isPassed = _formatDateLabel(appointment.dateLabel) != 'today'
        ? true
        : false;
    final isUpcoming = appointment.countdownTime != null && !isPassed;

    return Container(
      decoration: BoxDecoration(
        gradient: _formatDateLabel(appointment.dateLabel) == 'today'
            ? const RadialGradient(
                center: Alignment(0.0, 0.086),
                radius: 0.80,
                colors: [
                  AppTheme.appointmentGoldFade,
                  AppTheme.appointmentGoldFade,
                ],
                stops: [0.0, 1.0],
              )
            : const RadialGradient(
                center: Alignment(0.0, 0.086),
                radius: 0.80,
                colors: [AppTheme.appointmentPast, AppTheme.appointmentPast],
                stops: [0.0, 1.0],
              ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/calendar.svg', colorFilter: ColorFilter.mode(AppTheme.textSecondary, BlendMode.srcATop),),
                const SizedBox(width: 6),
                Row(
                  children: [
                    Text(
                      _formatDateLabel(appointment.dateLabel),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.black,
                      ),
                    ),
                    _formatDateLabel(appointment.dateLabel) == 'today'
                        ? Text(
                            ', ${appointment.timeLabel}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.black,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                if (isPassed) ...[
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appointment.status == 'filter_cancelled'
                              ? AppTheme.danger
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.tr(appointment.status),
                        style: TextStyle(
                          fontSize: 14,
                          color: appointment.status == 'Bekor qilingan'
                              ? AppTheme.danger
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: appointment.avatarUrl != null
                          ? Image.network(
                              appointment.avatarUrl!,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 74,
                              height: 74,
                              color: AppTheme.avatarBackground,
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/default_user.jpg'),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  appointment.lawyerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 17,
                                color: AppTheme.color_FF00B27A,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                context.tr(appointment.lawyerTitle),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textChoco,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.pageBackground,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${appointment.experienceYears} ${context.tr('years_experience')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textChoco,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              SvgPicture.asset('assets/icons/star.svg'),
                              const SizedBox(width: 4),
                              Text(
                                '${appointment.rating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${appointment.reviewsCount} ${context.tr('reviews_suffix')})',
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
                  ],
                ),
                const SizedBox(height: 14),

                // Tags Layout
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(label: context.tr(appointment.topic)),
                    _Tag(
                      label: context.tr(appointment.consultationType),
                      icon: Icons.videocam_outlined,
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 14),
                  height: 1,
                  color: AppTheme.textChoco.withValues(alpha: 0.2),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        label: context.tr('details'),
                        color: AppTheme.color_FFF4F4F4,
                        textColor: AppTheme.black87,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailScreen(
                              appointment: appointment,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (appointment.countdownTime != null)
                      const SizedBox(width: 10),
                    if (appointment.countdownTime != null)
                      Expanded(
                        child: AppointmentActionButton(
                          appointment: appointment,
                          backgroundColor: AppTheme.color_FFD8B26E,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();
  }

  String _formatDateLabel(String rawDate) {
    if (rawDate.isEmpty ||
        rawDate.toLowerCase() == 'bugun' ||
        rawDate.toLowerCase() == 'today') {
      return 'today';
    }

    try {
      DateTime apptDate;

      if (rawDate.contains('.')) {
        final parts = rawDate.split('.');
        final month = int.parse(parts[0]); // 09 -> September
        final day = int.parse(parts[1]); // 10 -> 10th
        final year = int.parse(parts[2]); // 2026

        apptDate = DateTime(year, month, day);
      } else {
        apptDate = DateTime.parse(rawDate);
      }

      final now = DateTime.now();
      final isToday =
          apptDate.year == now.year &&
          apptDate.month == now.month &&
          apptDate.day == now.day;

      return isToday ? 'today' : rawDate;
    } catch (_) {
      return rawDate;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _Tag({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              'assets/icons/camera.svg',
              colorFilter: ColorFilter.mode(
                AppTheme.color_FFCA9D38,
                BlendMode.srcATop,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.color_FF444444,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Widget? child;
  final VoidCallback? onPressed;

  const _CardButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child:
          child ??
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 120),
      child: Expanded(
        child: Column(
          children: [
            Image.asset('assets/images/appointments_empty.png'),
            Text(
              context.tr('appointments_empty'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: AppTheme.color_FF0F172A),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('appointments_empty_body'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.color_FF475569),
            ),
          ],
        ),
      ),
    );
  }
}
