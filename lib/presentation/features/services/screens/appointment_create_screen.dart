import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';
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
  String _service = 'Sudda vakillik';
  String _consultationType = 'Video orqali';
  String _payment = 'Payme';
  final _problemController = TextEditingController();
  final List<_AppointmentDocument> _documents = [];

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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Qabulga yozilish',
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
          color: Colors.white,
          child: SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _step == 2
                  ? _confirmAppointment
                  : () => setState(() => _step++),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.buttonGold,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(_step == 2 ? 'Tasdiqlash' : 'Davom etish'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocuments() async {
    const types = <XTypeGroup>[
      XTypeGroup(
        label: 'Hujjatlar',
        extensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      ),
    ];
    final files = await openFiles(acceptedTypeGroups: types);
    if (!mounted || files.isEmpty) return;
    final selected = <_AppointmentDocument>[];
    for (final file in files) {
      selected.add(
        _AppointmentDocument(name: file.name, size: await file.length()),
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

  String get selectedDateLabel =>
      '${_selectedDate.day}-${_monthName(_selectedDate.month)}';

  void _confirmAppointment() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF3F1F1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.close, size: 18),
                ),
              ),
              Image.asset('assets/images/success.png'),
              const SizedBox(height: 12),
              const Text(
                'To‘lov tasdiqlandi!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'To‘lov muvaffaqiyatli amalga oshirildi. Siz mutaxassis qabuliga muvaffaqiyatli yozildingiz.',
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
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Qabullar bo‘limiga o‘tish', style: TextStyle(color: AppTheme.textChoco, fontSize: 16),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        color: Colors.white,
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
                      '${lawyer.title}',
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
                      '${lawyer.experienceYears} yil tajriba',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textChoco,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4,),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/star.svg', height: 16, width: 16,),
                    const SizedBox(width: 4),
                    Text(
                      '${lawyer.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${lawyer.comment_count} ta sharh)',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textChoco, fontSize: 14),
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
          title: 'Sana tanlang',
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
                        title: _dateTitle(date),
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
                        'Kalendardan ochish',
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
          title: 'Vaqt tanlang',
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
          title: 'Xizmat turini tanlang',
          child: Column(
            children: [
              _SelectionRow(
                title: 'Sudda vakillik',
                selected: state._service == 'Sudda vakillik',
                onTap: () =>
                    state.setState(() => state._service = 'Sudda vakillik'),
              ),
              const SizedBox(height: 6),
              _SelectionRow(
                title: 'Da’vo arizasini tayyorlash',
                selected: state._service == 'Da’vo arizasini tayyorlash',
                onTap: () => state.setState(
                  () => state._service = 'Da’vo arizasini tayyorlash',
                ),
              ),
            ],
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
          title: 'Qabul turini tanlang',
          child: _SelectionRow(
            title: state._consultationType,
            selected: true,
            onTap: () {},
          ),
        ),
        _SectionCard(
          title: 'Muammo haqida qisqacha',
          child: TextField(
            controller: state._problemController,
            maxLines: 1,
            decoration: const InputDecoration(
              hintText: 'Qarzdorlikni undirish',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintStyle: TextStyle(fontSize: 14, color: AppTheme.textChoco),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              fillColor: Color(0xFFFCFBFA),
              filled: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        _SectionCard(
          title: 'Hujjat biriktirish (ixtiyoriy)',
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFBFA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/document_upload.svg'),
                          Text(
                            '+Hujjat biriktirish',
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
                          'Hujjat qo\'shish',
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
          title: 'To‘lov turi',
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
          title: 'Tafsilotlar',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFAF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8E4E3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Xizmat turi:', value: state._service),
                _DetailRow(
                  label: 'Sana:',
                  value: '${state.selectedDateLabel}, ${state._time}',
                ),
                _DetailRow(label: 'Format:', value: state._consultationType),
                const _DetailRow(label: 'Narxi:', value: '150 000 so‘m'),
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
        color: Colors.white,
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
          color: selected ? AppTheme.buttonGold : const Color(0xFFF8F7F6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppTheme.buttonGold : const Color(0xFFE7E2DE),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : const Color(0xFF344054),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              height: 57,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFFCFBFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E2DE)),
              ),
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _monthName(date.month),
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : const Color(0xFF475467),
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
        color: selected ? AppTheme.buttonGold : const Color(0xFFF8F7F6),
        image: disabled
            ? const DecorationImage(
                image: AssetImage('assets/images/data_bg.png'),
                fit: BoxFit.cover,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(
          width: 1,
          color: selected ? Colors.transparent : Color(0xffE8E4E3),
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
              ? Colors.white
              : Colors.black,
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
        color: selected ? const Color(0xFFFFFBF1) : const Color(0xFFF8F7F6),
        border: Border.all(
          color: selected ? AppTheme.buttonGold : const Color(0xFFE7E2DE),
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
                color: selected ? AppTheme.primaryGold : Colors.black,
              ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? AppTheme.buttonGold : AppTheme.textLight,
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
            color: Colors.white,
            border: Border.all(
              color: selected ? AppTheme.buttonGold : const Color(0xFFE7E2DE),
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
      color: const Color(0xFFFCFBFA),
      border: Border.all(color: const Color(0xFFE8E4E3)),
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
            child: SvgPicture.asset('assets/icons/remove.svg')),
        
      ],
    ),
  );
}

class _AppointmentDocument {
  final String name;
  final int size;

  const _AppointmentDocument({required this.name, required this.size});
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff1D1816)),
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

String _dateTitle(DateTime date) {
  final today = DateTime.now();
  final difference = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (difference == 0) return 'Bugun';
  if (difference == 1) return 'Ertaga';
  const weekdays = ['Du', 'Se', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];
  return weekdays[date.weekday - 1];
}

String _monthName(int month) {
  const months = [
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyun',
    'Iyul',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];
  return months[month - 1];
}
