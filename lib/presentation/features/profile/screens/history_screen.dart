import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/appointments/appointment.dart';
import '../../appointments/screens/appointment_detail_screen.dart';
import '../../appointments/viewmodels/appointments_viewmodel.dart';
import '../../../widgets/header_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
              children: [
                _HistoryFilters(),
                const SizedBox(height: 12),
                if (viewModel.isLoading)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2))
                else if (viewModel.appointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text('Bu bo‘limda tarix mavjud emas'),
                    ),
                  )
                else
                  ...viewModel.appointments.map(
                    (appointment) =>
                        _HistoryAppointmentCard(appointment: appointment),
                  ),
              ],
            ),
            const HeaderScreen(title: 'Tarix'),
          ],
        ),
      ),
    );
  }
}



class _HistoryAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _HistoryAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8E4E3),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/calendar.svg'),
              const SizedBox(width: 6),
              Text(
                '${appointment.dateLabel}, ${appointment.timeLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.circle,
                size: 6,
                color: appointment.status == 'Bekor qilingan'
                    ? Colors.red
                    : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                appointment.status,
                style: TextStyle(
                  fontSize: 12,
                  color: appointment.status == 'Bekor qilingan'
                      ? Colors.red
                      : Colors.grey[700],
                ),
              ),
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
                    child: appointment.avatarUrl == null
                        ? Container(
                            width: 74,
                            height: 74,
                            color: AppTheme.avatarBackground,
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/default_user.jpg'),
                          )
                        : Image.network(
                            appointment.avatarUrl!,
                            width: 74,
                            height: 74,
                            fit: BoxFit.cover,
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
                        Text(
                          '${appointment.lawyerTitle}  •  ${appointment.experienceYears} yil tajriba',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textChoco,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SvgPicture.asset('assets/icons/star.svg'),
                            const SizedBox(width: 4),
                            Text(
                              '${appointment.rating}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${appointment.reviewsCount} ta sharh)',
                              style: const TextStyle(
                                fontSize: 12,
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HistoryTag(label: appointment.topic),
                  _HistoryTag(
                    label: appointment.consultationType,
                    icon: 'assets/icons/camera.svg',
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                height: 1,
                color: AppTheme.textChoco.withValues(alpha: 0.2),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AppointmentDetailScreen(appointment: appointment),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F4F4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Tafsilot',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HistoryTag extends StatelessWidget {
  final String label;
  final String? icon;

  const _HistoryTag({required this.label, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[SvgPicture.asset(icon!), const SizedBox(width: 4)],
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

class _HistoryFilters extends StatefulWidget {
  const _HistoryFilters();

  @override
  State<_HistoryFilters> createState() => _HistoryFiltersState();
}

class _HistoryFiltersState extends State<_HistoryFilters> {
  int _selectedIndex = 0;

  final List<String> _filters = [
    'Barchasi',
    'Yevro protakol',
    'Advokat qabulı',
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(41),
    ),
    child: Row(
      children: List.generate(
        _filters.length,
            (index) => Expanded(
          child: _Filter(
            text: _filters[index],
            selected: _selectedIndex == index,
            onTap: () => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    ),
  );
}

class _Filter extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Filter({
    required this.text,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2F80FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(41),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    ),
  );
}
