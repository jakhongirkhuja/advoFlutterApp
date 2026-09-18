import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/home/lawyer.dart';
import '../../../../data/repositories/advokat_repository.dart';
import '../../../widgets/header_navigation.dart';

class AppointmentCreateScreen extends StatefulWidget {
  final Lawyer lawyer;

  const AppointmentCreateScreen({super.key, required this.lawyer});

  @override
  State<AppointmentCreateScreen> createState() =>
      _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState extends State<AppointmentCreateScreen> {
  int _step = 0;
  DateTime _selectedDate = DateTime.now();
  String _time = '09:00';
  String _service = 'court_representation';
  String _consultationType = 'video_call';
  String _payment = 'Payme';
  final _problemController = TextEditingController();
  final List<_AppointmentDocument> _documents = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.lawyer.tags.isNotEmpty) _service = widget.lawyer.tags.first;
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 62, 16, 92),
              children: [
                _LawyerSummary(lawyer: widget.lawyer),
                const SizedBox(height: 8),
                if (_step == 0) _ScheduleStep(state: this),
                if (_step == 1) _DetailsStep(state: this),
                if (_step == 2) _PaymentStep(state: this),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: Row(
                children: [
                  HeaderNavigation(
                    firstIconPath: 'assets/icons/back.svg',
                    firstIconOnTap: () => _step == 0
                        ? Navigator.pop(context)
                        : setState(() => _step--),
                    moveBack: true,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.tr('book_appointment'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 46),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: AppTheme.surface,
          child: SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _isSubmitting
                  ? null
                  : _step == 2
                  ? _confirmAppointment
                  : () => setState(() => _step++),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.buttonGold,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.surface,
                      ),
                    )
                  : Text(
                      _step == 2
                          ? context.tr('confirm')
                          : context.tr('continue'),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocuments() async {
    final types = <XTypeGroup>[
      XTypeGroup(
        label: context.tr('documents'),
        extensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      ),
    ];
    final files = await openFiles(acceptedTypeGroups: types);
    if (!mounted || files.isEmpty) return;
    final selected = <_AppointmentDocument>[];
    for (final file in files) {
      selected.add(
        _AppointmentDocument(
          name: file.name,
          path: file.path,
          size: await file.length(),
        ),
      );
    }
    setState(() {
      for (final file in selected) {
        if (!_documents.any(
          (item) => item.name == file.name && item.size == file.size,
        )) {
          _documents.add(file);
        }
      }
    });
  }

  List<DateTime> get _availableDates =>
      List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

  Future<void> _openCalendar(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 6)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppTheme.buttonGold),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(
        () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  String get selectedDateLabel => DateFormat(
    'd MMMM',
    Localizations.localeOf(context).languageCode,
  ).format(_selectedDate);

  Future<void> _confirmAppointment() async {
    final serviceIndex = widget.lawyer.tags.indexOf(_service);
    final serviceTypeId =
        serviceIndex >= 0 && serviceIndex < widget.lawyer.serviceTypeIds.length
        ? widget.lawyer.serviceTypeIds[serviceIndex]
        : null;
    if (serviceTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('no_data'))));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await context.read<AdvokatRepository>().createAppointment(
        lawyerId: widget.lawyer.id,
        serviceTypeId: serviceTypeId,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        startTime: _time,
        receptionType: _consultationType == 'video_call'
            ? 'video'
            : 'in_person',
        paymentMethod: _payment.toLowerCase().replaceAll(' ', ''),
        problemDescription: _problemController.text.trim(),
        documents: _documents.map((document) => File(document.path)).toList(),
      );
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierColor: AppTheme.black.withValues(alpha: 0.26),
        builder: (dialogContext) => Dialog(
          backgroundColor: AppTheme.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.color_FFF3F1F1,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.close, size: 18),
                  ),
                ),
                CustomIconDesign(
                  icon: 'assets/icons/note_ok.svg',
                  mainColor: AppTheme.color_FF15985B,
                  secondaryColor: AppTheme.color_FF40DB93,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('payment_confirmed'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('payment_success'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: AppTheme.textChoco,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.popUntil(
                      dialogContext,
                      (route) => route.isFirst,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.tagBackground,
                      foregroundColor: AppTheme.black87,
                    ),
                    child: Text(
                      context.tr('go_to_appointments'),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('application_failed'))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _LawyerSummary extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerSummary({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final imageUrl = lawyer.imageUrl.isNotEmpty
        ? lawyer.imageUrl
        : '${AppConfig.dummyImageBaseUrl}/lawyer-${lawyer.id}/160/160';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.network(
              imageUrl,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 74,
                height: 74,
                color: AppTheme.avatarBackground,
                alignment: Alignment.center,
                child: Image.asset('assets/images/default_user.jpg'),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    Flexible(
                      child: Text(
                        lawyer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (lawyer.isVerified)
                      const Icon(
                        Icons.verified,
                        size: 17,
                        color: AppTheme.success,
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      context.tr(lawyer.title),
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
                    Text(
                      '${lawyer.experienceYears} ${context.tr('years_experience')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textChoco,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star.svg',
                      height: 16,
                      width: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lawyer.rating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${lawyer.comment_count} ${context.tr('reviews_suffix')})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textChoco,
                        fontSize: 14,
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
}

class _ScheduleStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _ScheduleStep({required this.state});

  @override
  Widget build(BuildContext context) {
    const times = [
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
    ];
    return Column(
      children: [
        _SectionCard(
          title: context.tr('select_date_time'),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state._availableDates.map((date) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _DateBox(
                        date: date,
                        title: _dateTitle(context, date),
                        selected: _sameDay(state._selectedDate, date),
                        onTap: () =>
                            state.setState(() => state._selectedDate = date),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => state._openCalendar(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/calendar.svg',
                        colorFilter: ColorFilter.mode(
                          AppTheme.buttonGold,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        context.tr('open_calendar'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.buttonGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _SectionCard(
          title: context.tr('time'),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times
                .map(
                  (time) => _TimeBox(
                    label: time,
                    selected: state._time == time,
                    disabled: time == '11:00' || time == '14:00',
                    onTap: () => state.setState(() => state._time = time),
                  ),
                )
                .toList(),
          ),
        ),
        _SectionCard(
          title: context.tr('service_type'),
          child: Column(
            children:
                (state.widget.lawyer.tags.isEmpty
                        ? const ['court_representation']
                        : state.widget.lawyer.tags)
                    .map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _SelectionRow(
                          title: state.widget.lawyer.tags.isEmpty
                              ? context.tr(service)
                              : service,
                          selected: state._service == service,
                          onTap: () =>
                              state.setState(() => state._service = service),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _DetailsStep({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: context.tr('select_consultation'),
          child: _SelectionRow(
            title: context.tr(state._consultationType),
            selected: true,
            onTap: () {},
          ),
        ),
        _SectionCard(
          title: context.tr('problem_short'),
          child: TextField(
            controller: state._problemController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: context.tr('debt_collection'),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintStyle: TextStyle(fontSize: 14, color: AppTheme.textChoco),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              fillColor: AppTheme.pageBackground,
              filled: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        _SectionCard(
          title: context.tr('attach_optional'),
          child: Column(
            children: [
              ...state._documents.map(
                (document) => _DocumentRow(
                  document: document,
                  onDelete: () =>
                      state.setState(() => state._documents.remove(document)),
                ),
              ),
              if (state._documents.isEmpty)
                InkWell(
                  onTap: state._pickDocuments,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.pageBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset(
                              'assets/icons/document_upload.svg',
                              colorFilter: ColorFilter.mode(
                                AppTheme.textSecondary,
                                BlendMode.srcATop,
                              ),
                            ),
                          ),
                          Text(
                            '+${context.tr('attach_document')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textChoco,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: state._pickDocuments,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        SvgPicture.asset('assets/icons/plus.svg'),
                        Text(
                          context.tr('add_document'),
                          style: TextStyle(
                            color: AppTheme.textChoco,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _PaymentStep({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: context.tr('payment'),
          child: Row(
            children: [
              _PaymentBox(
                title: 'Payme',
                asset: 'assets/images/payme.png',
                selected: state._payment == 'Payme',
                onTap: () => state.setState(() => state._payment = 'Payme'),
              ),
              _PaymentBox(
                title: 'Uzum bank',
                asset: 'assets/images/uzumbank.png',
                selected: state._payment == 'Uzum bank',
                onTap: () => state.setState(() => state._payment = 'Uzum bank'),
              ),
              _PaymentBox(
                title: 'Click',
                asset: 'assets/images/click.png',
                selected: state._payment == 'Click',
                onTap: () => state.setState(() => state._payment = 'Click'),
              ),
            ],
          ),
        ),
        _SectionCard(
          title: context.tr('details'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.color_FFFBFAF9,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider, width: 1),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: '${context.tr('service_type')}:',
                  value: context.tr(state._service),
                ),
                _DetailRow(
                  label: '${context.tr('date')}:',
                  value: '${state.selectedDateLabel}, ${state._time}',
                ),
                _DetailRow(
                  label: context.tr('format_label'),
                  value: context.tr(state._consultationType),
                ),
                _DetailRow(
                  label: context.tr('price_label'),
                  value: '150 000 so‘m',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final DateTime date;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DateBox({
    required this.date,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.fromLTRB(5, 9, 5, 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.buttonGold : AppTheme.color_FFF8FAFC,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppTheme.buttonGold : AppTheme.color_FFE2E8F0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppTheme.surface : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              height: 57,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.color_FFE2E8F0),
              ),
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat(
                'MMM',
                Localizations.localeOf(context).languageCode,
              ).format(date),
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppTheme.surface : AppTheme.color_FF475467,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _TimeBox({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: disabled ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9.6),
      decoration: BoxDecoration(
        color: selected ? AppTheme.buttonGold : AppTheme.pageBackground,
        image: disabled
            ? const DecorationImage(
                image: AssetImage('assets/images/data_bg.png'),
                fit: BoxFit.cover,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(
          width: 1,
          color: selected ? AppTheme.transparent : AppTheme.color_FFE2E8F0,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: disabled
              ? AppTheme.textMuted
              : selected
              ? AppTheme.surface
              : AppTheme.black,
        ),
      ),
    ),
  );
}

class _SelectionRow extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionRow({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppTheme.color_FFEFF6FF : AppTheme.pageBackground,
        border: Border.all(
          color: selected ? AppTheme.buttonGold : AppTheme.color_FFE2E8F0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: selected ? AppTheme.primaryGold : AppTheme.black,
              ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? AppTheme.buttonGold : AppTheme.color_FFE2E8F0,
            size: 24,
          ),
        ],
      ),
    ),
  );
}

class _PaymentBox extends StatelessWidget {
  final String title;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentBox({
    required this.title,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.color_FFF8FAFC,
            border: Border.all(
              color: selected ? AppTheme.buttonGold : AppTheme.color_FFE7E2DE,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Image.asset(asset, fit: BoxFit.contain)),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                height: 1,
                color: AppTheme.textChoco.withValues(alpha: 0.2),
              ),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final _AppointmentDocument document;
  final VoidCallback onDelete;

  const _DocumentRow({required this.document, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: AppTheme.color_FFFCFBFA,
      border: Border.all(color: AppTheme.divider),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Column(
          children: [
            SvgPicture.asset('assets/icons/download.svg'),
            Text('PDF', style: TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatSize(document.size),
                style: const TextStyle(fontSize: 14, color: AppTheme.textChoco),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onDelete,
          child: SvgPicture.asset('assets/icons/remove.svg'),
        ),
      ],
    ),
  );
}

class _AppointmentDocument {
  final String name;
  final String path;
  final int size;

  const _AppointmentDocument({
    required this.name,
    required this.path,
    required this.size,
  });
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppTheme.textChoco),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.color_FF1D1816,
          ),
        ),
      ],
    ),
  );
}

String _formatSize(int bytes) => bytes < 1024 * 1024
    ? '${(bytes / 1024).toStringAsFixed(1)} Kb'
    : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mb';

String _initials(String name) => name
    .split(' ')
    .take(2)
    .map((part) => part.isEmpty ? '' : part[0])
    .join()
    .toUpperCase();

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _dateTitle(BuildContext context, DateTime date) {
  final today = DateTime.now();
  final difference = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (difference == 0) return context.tr('today');
  if (difference == 1) return context.tr('tomorrow');
  return DateFormat(
    'EEE',
    Localizations.localeOf(context).languageCode,
  ).format(date);
}
