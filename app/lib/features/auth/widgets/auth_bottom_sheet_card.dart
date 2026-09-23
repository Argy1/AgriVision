import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';

/// Sheet putih yang overlap panel hero (-20px margin, radius 22px atas) --
/// persis `5-app-login.html`.
class AuthBottomSheetCard extends StatelessWidget {
  const AuthBottomSheetCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: child,
      ),
    );
  }
}
