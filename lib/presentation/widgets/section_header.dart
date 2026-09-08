import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 10, right: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (action != null) ...[
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                action!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFCA9D38)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}