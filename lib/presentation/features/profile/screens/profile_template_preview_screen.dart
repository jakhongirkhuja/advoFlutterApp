import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';

class ProfileTemplatePreviewScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String company;
  final String position;
  final String manager;
  final String date;
  final String reason;

  const ProfileTemplatePreviewScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.company,
    required this.position,
    required this.manager,
    required this.date,
    required this.reason,
  });

  String get _documentText =>
      'Offer of Employment and Employment Contract\n\n'
      'Employee Name: $name\n'
      'Date: $date\n'
      'Address: Employee Address\n\n'
      'Dear Employee Name:\n'
      'We are pleased to offer you a position with $company.\n\n'
      'Your start date, manager, compensation, benefits, and other terms of employment will be as set forth below and on EXHIBIT A.\n\n'
      'TERMS OF EMPLOYMENT\n\n'
      'Position and Duties. Company hereby employs you, and you agree to competently and professionally perform such duties as are customarily the responsibility of the position set forth in the job description attached as EXHIBIT A and reasonably assigned to you from time to time by your Manager.\n\n'
      'Outside Business Activities. During your employment with Company, you shall devote competent energies, interests, and abilities to the performance of your duties under this Agreement. During the term of this Agreement, you shall not, without Company’s prior written consent, render any services to others for compensation or otherwise participate, advise, or render any other business activities that would interfere with the performance of your duties hereunder or compete with Company’s business.\n\n'
      'Employment Classification. You shall be a Full-Time Employee and shall not be entitled to benefits except as specifically outlined herein.\n\n'
      'Compensation/Benefits.\n\n'
      '1. Wage. Company shall pay you the wage as set forth in the job description attached as EXHIBIT A.\n\n'
      '2. Reimbursement of Expenses. You shall be reimbursed for all reasonable and necessary expenses paid or incurred by you in the performance of your duties.';

  @override
  Widget build(BuildContext context) {
    const showSearchAction = true;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 62, 12, 100),
                child: Container(
                  height: 366,
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                      child: Text(
                        _documentText,
                          style: const TextStyle(
                            fontSize: 6.2,
                            height: 1.25,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                          color: const Color(0xFFF1F5F9),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => showDialog<void>(
                              context: context,
                              builder: (_) => Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _documentText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.open_in_full,
                                size: 14,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            HeaderScreen(
              title: 'Ishdan bo‘shash arizasi',
              firstActionIconPath: showSearchAction
                  ? 'assets/icons/search.svg'
                  : null,
              onFirstActionTap: showSearchAction
                  ? () => Navigator.pushNamed(context, AppRouter.search)
                  : null,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: BorderSide.none,
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/edit.svg'),
                            SizedBox(width: 6),
                            Text(
                              'Tahrirlash',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: const Color(0xFF2F80FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/upload.svg'),
                            SizedBox(width: 6),
                            Text(
                              'Yuklab olish',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
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
