import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/appointments/appointment.dart';
import '../../../widgets/header_navigation.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 100),
              children: [
                _AppointmentIdentity(appointment: appointment),
                const SizedBox(height: 12),
                _DetailsCard(appointment: appointment),
                const SizedBox(height: 12),
                const _ProblemCard(),
                const SizedBox(height: 12),
                const _DocumentsCard(),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/back.svg',
                    firstIconOnTap: () => Navigator.pop(context),
                    moveBack: true,
                  ),
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/share.svg',
                    firstIconOnTap: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomButton(
                        label: 'Qayta belgilash',
                        backgroundColor: const Color(0xFFF3F1F1),
                        foregroundColor: Colors.black,
                        onTap: () {},
                      ),
                    ),
                    if (shouldShowAppointmentAction(appointment)) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppointmentActionButton(
                          appointment: appointment,
                          backgroundColor: AppTheme.buttonGold,
                          fontSize: 15,
                          height: 54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentIdentity extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentIdentity({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 255,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -1.5),
                radius: 1.5,
                colors: [Color(0xFFD9B875), Color(0x00FFFFFF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          Positioned(
            top: -40,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                    image: appointment.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(appointment.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: appointment.avatarUrl == null
                      ? Center(
                          child: Text(
                            _initials(appointment.lawyerName),
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Color(0xFF00A86B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Text(
                  appointment.lawyerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1D1816),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F1F1),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Text(
                    appointment.lawyerTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textChoco,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(
                        icon: 'assets/icons/calendar.svg',
                        label: 'Tajriba',
                        value: '${appointment.experienceYears} yil',
                      ),
                      const _StatItem(
                        icon: 'assets/icons/hummer.svg',
                        label: 'Qabullar',
                        value: '+980',
                      ),
                      _StatItem(
                        icon: 'assets/icons/star.svg',
                        label: 'Reyting',
                        value: appointment.rating.toStringAsFixed(1),
                        last: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool last;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: last ? 0 : 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textChoco),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon.endsWith('.svg'))
                  SvgPicture.asset(icon, width: 16, height: 16)
                else
                  Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _DetailsCard extends StatelessWidget {
  final Appointment appointment;

  const _DetailsCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tafsilotlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B27A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'To\'langan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00B27A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Xizmat turi:', value: appointment.topic),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Sana:',
                  value: '${_formatDate(appointment.dateLabel)}, ${appointment.timeLabel}',
                ),
                const SizedBox(height: 12),
                _DetailRow(label: 'Format:', value: appointment.consultationType),
                const SizedBox(height: 12),
                const _DetailRow(label: 'Narxi:', value: '150 000 so\'m'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.toLowerCase() == 'today' || raw.toLowerCase() == 'bugun') {
      return 'Bugun';
    }
    // Expected format: 09.07.2026 -> 7-sentabr
    final parts = raw.split('.');
    if (parts.length < 2) return raw;
    final day = int.tryParse(parts[1]);
    final month = int.tryParse(parts[0]);
    if (day == null || month == null || month < 1 || month > 12) return raw;
    const months = [
      'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
      'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'
    ];
    return '$day-${months[month - 1]}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xff64748B)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E293B)),
        ),
      ],
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Muammo haqida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Mulk masalasi bo‘yicha huquqiy maslahat olish.',
            style: TextStyle(fontSize: 16, height: 1.4, color: Color(0xff475569)),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatefulWidget {
  const _DocumentsCard();

  @override
  State<_DocumentsCard> createState() => _DocumentsCardState();
}

class _DocumentsCardState extends State<_DocumentsCard> {
  final List<_SelectedDocument> _documents = [];

  Future<void> _pickDocument() async {
    try {
      const acceptedTypes = <XTypeGroup>[
        XTypeGroup(
          label: 'Hujjatlar',
          extensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        ),
      ];
      final selectedFiles = await openFiles(
        acceptedTypeGroups: acceptedTypes,
      );

      if (!mounted || selectedFiles.isEmpty) return;

      final selectedDocuments = <_SelectedDocument>[];
      for (final file in selectedFiles) {
        selectedDocuments.add(
          _SelectedDocument(name: file.name, size: await file.length()),
        );
      }

      setState(() {
        for (final document in selectedDocuments) {
          final alreadyAdded = _documents.any(
            (existing) => existing.name == document.name && existing.size == document.size,
          );
          if (!alreadyAdded) _documents.add(document);
        }
      });
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hujjatni tanlab bo‘lmadi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hujjatlar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._documents.map((doc) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _documentTile(doc),
          )),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.add, size: 20, color: Color(0xff64748B)),
              label: const Text(
                'Hujjat qo‘shish',
                style: TextStyle(color: Color(0xff64748B), fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(_SelectedDocument document) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset('assets/icons/pdf.svg', errorBuilder: (_, __, ___) => const Icon(Icons.insert_drive_file_outlined, color: Color(0xff64748B))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(document.size),
                  style: const TextStyle(fontSize: 13, color: Color(0xff64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _documents.remove(document)),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Kb';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mb';
  }
}

class _SelectedDocument {
  final String name;
  final int size;

  const _SelectedDocument({required this.name, required this.size});
}

class _BottomButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: child ?? Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class AppointmentCountdown extends StatefulWidget {
  final String value;
  final TextStyle? textStyle;

  const AppointmentCountdown({super.key, required this.value, this.textStyle});

  @override
  State<AppointmentCountdown> createState() => _AppointmentCountdownState();
}

class AppointmentActionButton extends StatelessWidget {
  final Appointment appointment;
  final Color backgroundColor;
  final double fontSize;
  final double height;

  const AppointmentActionButton({
    super.key,
    required this.appointment,
    required this.backgroundColor,
    required this.fontSize,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final start = appointmentDateTime(appointment);
    final text = start != null && DateTime.now().isBefore(start)
        ? 'Boshlash'
        : 'Ko‘rish';
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextButton(
        onPressed: () => openAppointmentMeeting(context, appointment),
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: fontSize),
        ),
      ),
    );
  }
}

bool _isAppointmentToday(Appointment appointment) {
  final date = appointmentDateTime(appointment);
  if (date == null) return false;
  final now = DateTime.now();
  return now.year == date.year && now.month == date.month && now.day == date.day;
}

bool shouldShowAppointmentAction(Appointment appointment) {
  final start = appointmentDateTime(appointment);
  if (start == null) return false;

  final now = DateTime.now();
  return now.year == start.year &&
      now.month == start.month &&
      now.day == start.day;
}

bool canJoinAppointment(Appointment appointment) {
  final start = appointmentStartTime(appointment);
  if (start == null) return false;

  final now = DateTime.now();
  final end = start.add(const Duration(minutes: 60));
  return now.isAfter(start.subtract(const Duration(minutes: 30))) && now.isBefore(end);
}

DateTime? appointmentStartTime(Appointment appointment) {
  final start = appointmentDateTime(appointment);
  if (start == null) return null;

  final now = DateTime.now();
  if (start.year != now.year || start.month != now.month || start.day != now.day) {
    return null;
  }
  return start;
}

DateTime? appointmentDateTime(Appointment appointment) {
  final dateParts = appointment.dateLabel.split('.');
  final timeParts = appointment.timeLabel.split(':');
  if (dateParts.length != 3 || timeParts.length != 2) return null;

  final month = int.tryParse(dateParts[0]);
  final day = int.tryParse(dateParts[1]);
  final year = int.tryParse(dateParts[2]);
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if ([month, day, year, hour, minute].any((value) => value == null)) return null;

  return DateTime(year!, month!, day!, hour!, minute!);
}

Future<void> openAppointmentMeeting(BuildContext context, Appointment appointment) async {
  final meetingUrl = appointment.meetingUrl;
  if (meetingUrl == null || meetingUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Meet havolasi mavjud emas')),
    );
    return;
  }

  final opened = await launchUrl(Uri.parse(meetingUrl), mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Meetni ochib bo‘lmadi')),
    );
  }
}

class _AppointmentCountdownState extends State<AppointmentCountdown> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _parseSeconds(widget.value);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AppointmentCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _timer?.cancel();
      _remainingSeconds = _parseSeconds(widget.value);
      _startTimer();
    }
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        setState(() => _remainingSeconds = 0);
        _timer?.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    final formatted = "${hours.toString().padLeft(2, '0')} : "
        "${minutes.toString().padLeft(2, '0')} : "
        "${seconds.toString().padLeft(2, '0')}";

    return Text(formatted, style: widget.textStyle);
  }

  int _parseSeconds(String value) {
    final parts = value.split(':').map((part) => int.tryParse(part.trim()) ?? 0).toList();
    if (parts.length != 3) return 0;
    return (parts[0] * 3600) + (parts[1] * 60) + parts[2];
  }
}

String _initials(String name) => name
    .split(' ')
    .take(2)
    .map((part) => part.isEmpty ? '' : part[0])
    .join()
    .toUpperCase();
