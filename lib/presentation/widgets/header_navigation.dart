import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HeaderNavigation extends StatelessWidget {
  final String firstIconPath;
  final String secondIconPath;
  final VoidCallback firstIconOnTap;
  final VoidCallback secondIconOnTap;
  const HeaderNavigation({
    super.key, required this.firstIconPath, required this.secondIconPath, required this.firstIconOnTap, required this.secondIconOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(47),
        color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFD9B875),
          ],
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
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: firstIconOnTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(firstIconPath),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: secondIconOnTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(secondIconPath),
              ),
            ),
          ],
        ),
      ),
    );
  }
}