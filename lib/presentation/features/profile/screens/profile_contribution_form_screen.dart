import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';

class ProfileContributionFormScreen extends StatefulWidget {
  const ProfileContributionFormScreen({super.key});

  @override
  State<ProfileContributionFormScreen> createState() =>
      _ProfileContributionFormScreenState();
}

class _ProfileContributionFormScreenState
    extends State<ProfileContributionFormScreen> {
  final _amount = TextEditingController();
  String _payment = 'Payme';
  bool _anonymous = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.pageBackground,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 76, 16, 82),
              children: [
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biz bilan birga rivojlaning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Loyihamizni 2 milliondan ortiq foydalanuvchiga xizmat qiladigan tizimga aylantirish uchun sizning yordamingiz kerak.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFE4EAF1)),
                      const Text('Summa', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        style: const TextStyle(fontSize: 14),
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: _input('0'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: ['5 000', '15 000', '50 000', '100 000']
                            .map(
                              (value) => InkWell(
                                borderRadius: BorderRadius.circular(21),
                                    onTap: () {
                                      _amount.text = value.replaceAll(' ', '');
                                      setState(() {});
                                    },
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  child: Text(value, style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To‘lov turi', style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _PaymentOption(
                              title: 'Payme',
                              iconPath: 'assets/images/payme.png',
                              icon: Icons.payment,
                              selected: _payment == 'Payme',
                              onTap: () => setState(() => _payment = 'Payme'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _PaymentOption(
                              title: 'Uzum bank',
                              iconPath: 'assets/images/uzumbank.png',
                              icon: Icons.account_balance,
                              selected: _payment == 'Uzum bank',
                              onTap: () =>
                                  setState(() => _payment = 'Uzum bank'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _PaymentOption(
                              title: 'Click',
                              iconPath: 'assets/images/click.png',
                              icon: Icons.circle_outlined,
                              selected: _payment == 'Click',
                              onTap: () => setState(() => _payment = 'Click'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset('assets/icons/anonymous.svg'),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Anonim yuborish',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.82,
                        child: CupertinoSwitch(
                          activeTrackColor: Color(0xff2B7FFF),
                          value: _anonymous,
                          onChanged: (value) => setState(() => _anonymous = value),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const HeaderScreen(title: 'Loyihaga hissa qo‘shish'),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80FF),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                  child: const Text(
                    'Hissa qo‘shish',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
    ),
    child: child,
  );

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
    isDense: true,
    filled: true,
    fillColor: AppTheme.pageBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
    ),
  );

  bool get _canSubmit =>
      (int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) > 0;

  Future<void> _submit() => showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .22),
    builder: (_) => const _ContributionSuccessDialog(),
  );
}

class _ContributionSuccessDialog extends StatelessWidget {
  const _ContributionSuccessDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              CustomIconDesign(
                icon: 'assets/icons/thankyou.svg',
                mainColor: const Color(0xFFF1C8AFF),
                secondaryColor: const Color(0xFF69AFFF),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rahmat, hissangiz qabul qilindi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sizning yordamingiz loyiha rivojiga hissa\nqo‘shadi. Qo‘llab-quvvatlaganingizdan\nxursandmiz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.profile,
                        (route) => false
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF101828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                  child: Text(
                    'Bosh sahifaga o‘tish',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0, // Set to 0 so it aligns with the top of the Stack within bounds
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 15, color: Color(0xFF475569)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
class _PaymentOption extends StatelessWidget {
  final String title;
  final String iconPath;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.iconPath,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.pageBackground,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF2F80FF) : const Color(0xFFDCE3EC),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents Column overflow
          children: [
            SizedBox(
              height: 45,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft, // Aligns image to the left
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(icon, size: 26),
                ),
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFE4EAF1),
              margin: const EdgeInsets.only(top: 8, bottom: 10), // Tightened margin to clear 3px overflow
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
