import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/home/lawyer.dart';
import '../../../widgets/header_navigation.dart';
import '../../../widgets/header_screen.dart';
import '../../../widgets/lawyer_card.dart';
import '../../home/viewmodels/home_viewmodel.dart';

class CourtRepresentationScreen extends StatefulWidget {
  final String title;
  final String about;
  final String description;

  const CourtRepresentationScreen({
    super.key,
    required this.title,
    required this.about,
    required this.description,
  });

  @override
  State<CourtRepresentationScreen> createState() =>
      _CourtRepresentationScreenState();
}

class _CourtRepresentationScreenState extends State<CourtRepresentationScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => {},
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.about,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0.0,
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 17,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ?_isExpanded
                            ? Align(
                                child: Text(widget.description),
                                alignment: Alignment.topLeft,
                              )
                            : null,
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (home.isLoading)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    ...home.popularLawyers.map(
                      (lawyer) => LawyerCard(lawyer: lawyer),
                    ),
                ],
              ),
              HeaderScreen(
                title: widget.title,
                firstActionIconPath: 'assets/icons/search.svg',
                onFirstActionTap: () {},
                secondActionIconPath: 'assets/icons/filter.svg',
                onSecondActionTap: (){},
              ),

            ],
          ),
        ),
      ),
    );
  }
}
