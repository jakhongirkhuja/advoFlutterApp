import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HeaderNavigation extends StatelessWidget {
  final String firstIconPath;
  final String? secondIconPath;
  final VoidCallback firstIconOnTap;
  final VoidCallback? secondIconOnTap;
  final bool moveBack;

  const HeaderNavigation({
    super.key,
    required this.firstIconPath,
    this.secondIconPath,
    required this.firstIconOnTap,
    this.secondIconOnTap,
    this.moveBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final double? containerWidth = moveBack ? 46.0 : null;
    return Container(
      height: 44,
      width: containerWidth,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(47),
        color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFD9B875)],
          stops: [0.5, 1.0],
        ),
      ),
      child: Container(
        height: 40,

        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(47),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: moveBack ? () => Navigator.pop(context) : firstIconOnTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(firstIconPath),
              ),
            ),
            if (secondIconPath != null)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: secondIconOnTap,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(secondIconPath!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
