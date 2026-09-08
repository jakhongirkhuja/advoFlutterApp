import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/home/lawyer.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;

  const LawyerCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppTheme.pageBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  'https://loremflickr.com/320/240/',
                  fit: BoxFit.cover,
                  errorBuilder: (context, exception, stackTrace) {
                    return Center(
                      child: Text(
                        _initials(lawyer.name),
                        style: const TextStyle(
                          color: Color(0xFF31527A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
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
                            lawyer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        if (lawyer.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 17,
                            color: Color(0xFF3E9B6B),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/star.svg'),
                        const SizedBox(width: 4),
                        Text(
                          '${lawyer.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '(${lawyer.comment_count} ta sharh)',
                          style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textChoco, fontSize: 16),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(40)
                ),
                child: SvgPicture.asset('assets/icons/bookmarkfilled.svg'),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: lawyer.tags.take(2).map(_tag).toList(),
              ),
              if(lawyer.tags.length>2) ...[
                const SizedBox(width: 8),
                _tag('+${lawyer.tags.length-2}'),
              ]
            ],
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.pageBackground,
            ),
          ),
          Row(
            children: [
              Text(
                lawyer.pricePerMinute
                    .toString()
                    .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]} ',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '/so\'mdan',
                style: TextStyle(
                    color: AppTheme.textChoco,
                    fontSize: 16
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRouter.lawyerProfile, arguments: lawyer),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 9.5, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGold,
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Text('Ko\'rish', style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textChoco)),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}