import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/public_bottom_navigation_bar.dart';
import '../viewmodels/appointments_viewmodel.dart';
import '../../../../data/models/appointments/appointment.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadAppointments,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Qabullar',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  _CircleButton(icon: Icons.search, onTap: () {}),
                ],
              ),
              const SizedBox(height: 18),
              _FilterBar(viewModel: viewModel),
              const SizedBox(height: 14),
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

class _FilterBar extends StatelessWidget {
  final AppointmentsViewModel viewModel;

  const _FilterBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppointmentsViewModel.filters.map((filter) {
          final selected = viewModel.selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => viewModel.selectFilter(filter),
              labelStyle: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : const Color(0xFF555555),
              ),
              selectedColor: const Color(0xFFD3A944),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isCancelled = appointment.status == 'Bekor qilingan';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFE5EDF5),
                child: Text(
                  _initials(appointment.lawyerName),
                  style: const TextStyle(
                    color: Color(0xFF31527A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: Color(0xFF3E9B6B)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${appointment.lawyerTitle} · ${appointment.experienceYears} yil tajriba',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFE0AE35)),
                        const SizedBox(width: 3),
                        Text('${appointment.rating}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isCancelled ? Icons.cancel_outlined : Icons.more_horiz,
                color: isCancelled ? Colors.redAccent : const Color(0xFF999999),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF777777)),
              const SizedBox(width: 5),
              Text('${appointment.dateLabel}, ${appointment.timeLabel}', style: const TextStyle(fontSize: 11)),
              const Spacer(),
              Text(appointment.status, style: TextStyle(fontSize: 10, color: isCancelled ? Colors.red : const Color(0xFF3E9B6B))),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(appointment.topic),
              _Tag(appointment.consultationType),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCancelled ? null : () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF555555),
                side: const BorderSide(color: Color(0xFFE5E5E5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Tafsilot'),
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
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onTap, icon: Icon(icon, color: const Color(0xFF555555)));
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
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
