import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/advokat_repository.dart';
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
  bool _isSubmitting = false;

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
                      Text(
                        context.tr('contribution_intro_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('contribution_intro_body'),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Divider(height: 24, color: AppTheme.color_FFE4EAF1),
                      Text(
                        context.tr('amount'),
                        style: const TextStyle(fontSize: 14),
                      ),
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
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 10,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppTheme.color_FFF1F5F9,
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
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
                      Text(
                        context.tr('payment_type'),
                        style: const TextStyle(fontSize: 15),
                      ),
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
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.color_FFF1F5F9,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset('assets/icons/anonymous.svg'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('anonymous_submit'),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.82,
                        child: CupertinoSwitch(
                          activeTrackColor: AppTheme.color_FF2B7FFF,
                          value: _anonymous,
                          onChanged: (value) =>
                              setState(() => _anonymous = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          HeaderScreen(title: context.tr('contribution')),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _canSubmit && !_isSubmitting ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.color_FF2F80FF,
                    disabledBackgroundColor: AppTheme.color_FFCBD5E1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(44),
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
                          context.tr('add_contribution'),
                          style: const TextStyle(fontSize: 16),
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
      color: AppTheme.surface,
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
      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.color_FFE2E8F0, width: 1.0),
    ),
  );

  bool get _canSubmit =>
      (int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) > 0;

  Future<void> _submit() async {
    final amount = int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<AdvokatRepository>().addContribution(
        amount: amount,
        paymentMethod: _payment.toLowerCase().replaceAll(' ', ''),
        isAnonymous: _anonymous,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierColor: AppTheme.black.withValues(alpha: .22),
        builder: (_) => const _ContributionSuccessDialog(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('contribution_error'))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _ContributionSuccessDialog extends StatelessWidget {
  const _ContributionSuccessDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppTheme.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
                mainColor: AppTheme.color_FF1C8AFF,
                secondaryColor: AppTheme.color_FF69AFFF,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('contribution_success'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.color_FF101828,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('contribution_success_body'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  color: AppTheme.color_FF475569,
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
                    (route) => false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.color_FFF1F5F9,
                    foregroundColor: AppTheme.color_FF101828,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                  child: Text(
                    context.tr('back_home'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top:
                0, // Set to 0 so it aligns with the top of the Stack within bounds
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: AppTheme.color_FFF1F5F9,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 15,
                  color: AppTheme.color_FF475569,
                ),
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
            color: selected ? AppTheme.color_FF2F80FF : AppTheme.color_FFDCE3EC,
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
              color: AppTheme.color_FFE4EAF1,
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 10,
              ), // Tightened margin to clear 3px overflow
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
