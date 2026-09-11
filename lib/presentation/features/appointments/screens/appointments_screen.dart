import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';
import '../../../widgets/header_screen.dart';
import '../viewmodels/appointments_viewmodel.dart';
import '../../../../data/models/appointments/appointment.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(16, 105, 16, 24),
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
              title: 'Qabullar',
              firstActionIconPath: 'assets/icons/search.svg',
              onFirstActionTap: () =>
                  Navigator.pushNamed(context, AppRouter.search),
              showBackIcon: false,
            ),

            Positioned(
              left: 0,
              right: 0,
              top: 65,
              child: _FilterBar(viewModel: viewModel),)
          ],
        ),
      ),
      bottomNavigationBar: PublicBottomNavigationBar(
        activeItem: 'appointments',
        onHomeTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (route) => false,
        ),
        onProfileTap: () => Navigator.pushNamed(context, AppRouter.profile),
      ),
    );
  }
}
class _FilterBar extends StatefulWidget {
  final AppointmentsViewModel viewModel;

  const _FilterBar({required this.viewModel});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToIndex(int index) {
    double position = index * 100.0;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(41),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(AppointmentsViewModel.filters.length, (index) {
            final filter = AppointmentsViewModel.filters[index];
            final selected = widget.viewModel.selectedFilter == filter;

            return InkWell(
              onTap: () {
                widget.viewModel.selectFilter(filter);
                _scrollToIndex(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.buttonGold : Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? Colors.white : const Color(0xff334155),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isPassed = _formatDateLabel(appointment.dateLabel)!='today'? true : false;
    final isUpcoming = appointment.countdownTime != null &&  !isPassed;

    return Container(
      decoration: BoxDecoration(
        gradient:  _formatDateLabel(appointment.dateLabel)=='today'? const RadialGradient(
          center: Alignment(0.0, 0.086),
          radius: 0.80,
          colors: [
            Color.fromRGBO(217, 184, 117, 0.6),
            Color.fromRGBO(243, 237, 226, 1.0),
          ],
          stops: [0.0, 1.0],
        ) : const RadialGradient(
          center: Alignment(0.0, 0.086),
          radius: 0.80,
          colors: [
            Color.fromRGBO(232, 228, 227, 1),
            Color.fromRGBO(232, 228, 2276, 1.0),
          ],
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
                SvgPicture.asset('assets/icons/calendar.svg'),
                const SizedBox(width: 6),
                Row(
                  children: [
                    Text(
                      _formatDateLabel(appointment.dateLabel),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    _formatDateLabel(appointment.dateLabel)=='today'?
                    Text(
                      ', ${appointment.timeLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ) : SizedBox(),
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
                          color: appointment.status=='Bekor qilingan' ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: appointment.status=='Bekor qilingan' ?  Colors.red : Colors.grey[700],
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
              color: Colors.white,
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
                        color: const Color(0xFFE5EDF5),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(appointment.lawyerName),
                          style: const TextStyle(
                            color: Color(0xFF31527A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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
                                color: Color(0xFF00B27A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${appointment.lawyerTitle}',
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
                                  '${appointment.experienceYears} yil tajriba',
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
                                '(${appointment.reviewsCount} ta sharh)',
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
                    _Tag(label: appointment.topic),
                    _Tag(
                      label: appointment.consultationType,
                      icon: Icons.videocam_outlined,
                    ),
                  ],
                ),

                Container(margin: EdgeInsets.symmetric(vertical: 14),height: 1, color: AppTheme.textChoco.withValues(alpha:0.2)),


                  Row(
                    children: [
                      Expanded(
                        child: _CardButton(
                          label: 'Tafsilot',
                          color: const Color(0xFFF4F4F4),
                          textColor: Colors.black87,
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
                      if(appointment.countdownTime!=null)const SizedBox(width: 10),
                      if(appointment.countdownTime!=null) Expanded(
                        child: AppointmentActionButton(
                          appointment: appointment,
                          backgroundColor: const Color(0xFFD8B26E),
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
    if (rawDate.isEmpty || rawDate.toLowerCase() == 'bugun' || rawDate.toLowerCase() == 'today') {
      return 'today';
    }

    try {
      DateTime apptDate;

      if (rawDate.contains('.')) {
        final parts = rawDate.split('.');
        final month = int.parse(parts[0]); // 09 -> September
        final day = int.parse(parts[1]);   // 10 -> 10th
        final year = int.parse(parts[2]);  // 2026

        apptDate = DateTime(year, month, day);
      } else {
        apptDate = DateTime.parse(rawDate);
      }

      final now = DateTime.now();
      final isToday = apptDate.year == now.year &&
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset('assets/icons/camera.svg'),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF444444),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: child ?? Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
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
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: Text('Bu bo‘limda qabullar mavjud emas')),
    );
  }
}
