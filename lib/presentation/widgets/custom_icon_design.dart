import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/theme/app_theme.dart';

class CustomIconDesign extends StatelessWidget {
  final String icon;
  final Color mainColor;
  final Color secondaryColor;
  final double padding;
  final bool home;
  const CustomIconDesign({
    super.key, required this.icon, required this.mainColor, required this.secondaryColor, this.padding = 10.0, this.home=false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: mainColor, width: 1),
        borderRadius: BorderRadius.circular(home?12:16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.color_FF0A0D12.withValues(alpha: home?0.1:0.3),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -2,
          ),
          // 0px 12px 16px -4px #0A0D1214
          BoxShadow(
            color: AppTheme.color_FF0A0D12.withValues(alpha:  home?0.1:0.2),
            offset: Offset(0, 12),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.color_FFD0D8E5,
            mainColor,
          ],
        ),

      ),
      child: Container(
        width: home?38:53,
        height: home?38:53,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(home?12:16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              secondaryColor,
              mainColor,
            ],
          ),
        ),
        child: SvgPicture.asset(icon,
          colorFilter: ColorFilter.mode(AppTheme.surface, BlendMode.srcATop),),
      ),
    );
  }
}
