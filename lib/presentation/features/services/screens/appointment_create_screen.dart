import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';

class AppointmentCreateScreen extends StatefulWidget {
  final Lawyer lawyer;

  const AppointmentCreateScreen({super.key, required this.lawyer});

  @override
  State<AppointmentCreateScreen> createState() => _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState extends State<AppointmentCreateScreen> {
  int _step = 0;
  String _date = '14 Avg';
  String _time = '09:00';
  String _service = 'Sudda vakillik';
  String _payment = 'Payme';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Qabulga yozilish', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: IconButton(onPressed: () => Navigator.pop(context), style: IconButton.styleFrom(backgroundColor: AppTheme.surface, padding: EdgeInsets.zero), icon: const Icon(Icons.chevron_left, color: AppTheme.primaryGold, size: 20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
        children: [
          _LawyerSummary(lawyer: widget.lawyer),
          const SizedBox(height: 10),
          if (_step == 0) _DateAndTimeStep(state: this) else if (_step == 1) _ServiceStep(state: this) else _PaymentStep(state: this),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          color: AppTheme.surface,
          child: SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _nextStep,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.buttonGold, minimumSize: const Size(0, 44), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Text(_step == 2 ? 'Tasdiqlash' : 'Davom etish'),
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qabul tasdiqlandi'),
        content: Text('${widget.lawyer.name} bilan $_date, $_time vaqtda uchrashuv belgilandi.'),
        actions: [TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('Yopish'))],
      ),
    );
  }
}

class _LawyerSummary extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerSummary({required this.lawyer});

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.avatarBackground, borderRadius: BorderRadius.circular(13)), child: Center(child: Text(lawyer.name.split(' ').take(2).map((part) => part[0]).join().toUpperCase(), style: const TextStyle(color: Color(0xFF31527A), fontWeight: FontWeight.w800)))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(lawyer.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))), const SizedBox(width: 3), const Icon(Icons.verified, size: 13, color: AppTheme.success)]), Text('${lawyer.title} · ${lawyer.experienceYears} yil tajriba', style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)), Row(children: [const Icon(Icons.star, size: 13, color: AppTheme.star), Text(' ${lawyer.rating}  (${lawyer.reviewsCount} ta sharh)', style: const TextStyle(fontSize: 9))])]))]));
}

class _DateAndTimeStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _DateAndTimeStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final dates = ['14\nAvg', '15\nAvg', '16\nAvg', '17\nAvg', '18\nAvg'];
    final times = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'];
    return Column(
      children: [
        _SectionCard(
          title: 'Sana tanlang',
          child: Column(
            children: [
              Wrap(
                spacing: 5,
                children: List.generate(
                  dates.length,
                  (index) {
                    final date = dates[index].replaceAll('\n', ' ');
                    return _ChoiceBox(
                      label: dates[index],
                      selected: state._date == date,
                      onTap: () => state.setState(() => state._date = date),
                    );
                  },
                ),
              ),
              const SizedBox(height: 9),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month_outlined, size: 15),
                label: const Text(
                  'Kalendardan ochish',
                  style: TextStyle(fontSize: 11, color: Color(0xFFD2A544)),
                ),
              ),
            ],
          ),
        ),
        _SectionCard(
          title: 'Vaqt tanlang',
          child: Wrap(
            spacing: 6,
            runSpacing: 7,
            children: times
                .map(
                  (time) => _ChoiceBox(
                    label: time,
                    selected: state._time == time,
                    onTap: () => state.setState(() => state._time = time),
                  ),
                )
                .toList(),
          ),
        ),
        _ServiceSelection(state: state),
      ],
    );
  }
}

class _ServiceStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _ServiceStep({required this.state});

  @override
  Widget build(BuildContext context) => Column(children: [_ServiceSelection(state: state), const SizedBox(height: 10), _HintCard(text: 'Xizmat turini tanlang va keyingi bosqichga o‘ting.')]);
}

class _ServiceSelection extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _ServiceSelection({required this.state});

  @override
  Widget build(BuildContext context) => _SectionCard(title: 'Xizmat turini tanlang', child: Column(children: [
    _RadioRow(title: 'Sudda vakillik', selected: state._service == 'Sudda vakillik', onTap: () => state.setState(() => state._service = 'Sudda vakillik')),
    const SizedBox(height: 6),
    _RadioRow(title: 'Da’vo arizasini tayyorlash', selected: state._service == 'Da’vo arizasini tayyorlash', onTap: () => state.setState(() => state._service = 'Da’vo arizasini tayyorlash')),
  ]));
}

class _PaymentStep extends StatelessWidget {
  final _AppointmentCreateScreenState state;

  const _PaymentStep({required this.state});

  @override
  Widget build(BuildContext context) => Column(children: [
    _SectionCard(title: 'To‘lov turi', child: Row(children: [
      Expanded(child: _PaymentBox(title: 'Payme', icon: Icons.payment, selected: state._payment == 'Payme', onTap: () => state.setState(() => state._payment = 'Payme'))),
      const SizedBox(width: 6),
      Expanded(child: _PaymentBox(title: 'Uzum bank', icon: Icons.account_balance, selected: state._payment == 'Uzum bank', onTap: () => state.setState(() => state._payment = 'Uzum bank'))),
      const SizedBox(width: 6),
      Expanded(child: _PaymentBox(title: 'Click', icon: Icons.circle_outlined, selected: state._payment == 'Click', onTap: () => state.setState(() => state._payment = 'Click'))),
    ])),
    _SectionCard(title: 'Tafsilotlar', child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF2F0EE), borderRadius: BorderRadius.circular(12)), child: const Column(children: [_DetailRow(label: 'Xizmat turi:', value: 'Huquqiy maslahat'), _DetailRow(label: 'Sana:', value: '7-sentabr, 16:00'), _DetailRow(label: 'Format:', value: 'Video konsultatsiya'), _DetailRow(label: 'Narxi:', value: '150 000 so‘m')]))),
  ]);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)), const SizedBox(height: 8), child]));
}

class _ChoiceBox extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceBox({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 49, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: selected ? const Color(0xFFE0B75E) : const Color(0xFFF2F0EE), borderRadius: BorderRadius.circular(10)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: selected ? Colors.white : const Color(0xFF555555), height: 1.2))));
}

class _RadioRow extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), decoration: BoxDecoration(color: selected ? const Color(0xFFFFFBF1) : const Color(0xFFF2F0EE), border: Border.all(color: selected ? const Color(0xFFE0B75E) : Colors.transparent), borderRadius: BorderRadius.circular(11)), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 10))), Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? const Color(0xFFE0B75E) : Colors.white, size: 17)])));
}

class _PaymentBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentBox({required this.title, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(height: 70, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF2F0EE), border: Border.all(color: selected ? const Color(0xFFE0B75E) : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 24, color: selected ? const Color(0xFF6D36D9) : const Color(0xFF555555)), const Spacer(), Text(title, style: const TextStyle(fontSize: 9))])));
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF777777)),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String text;

  const _HintCard({required this.text});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF777777))));
}
