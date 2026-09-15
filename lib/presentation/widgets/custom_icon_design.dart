import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconDesign extends StatelessWidget {
  final String icon;
  final Color mainColor;
  final Color secondaryColor;
  final double padding;
  const CustomIconDesign({
    super.key, required this.icon, required this.mainColor, required this.secondaryColor, this.padding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: mainColor, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0A0D12).withValues(alpha: 0.3),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -2,
          ),
          // 0px 12px 16px -4px #0A0D1214
          BoxShadow(
            color: Color(0xff0A0D12).withValues(alpha: 0.2),
            offset: Offset(0, 12),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD0D8E5),
            mainColor,
          ],
        ),

      ),
      child: Container(
        width: 55,
        height: 55,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),),
      ),
    );
  }
}