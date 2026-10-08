import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Full-width rounded Sign Out pill button matching iOS design specification.
/// Features a soft warm-orange surface (#FFF1E5), orange logout icon, and #FF7A00 label.
/// On tap, presents a platform-adaptive confirmation dialog before triggering sign out.
class SignOutButton extends StatelessWidget {
  final Future<void> Function() onConfirmSignOut;

  const SignOutButton({super.key, required this.onConfirmSignOut});

  Future<void> _handleTap(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Sign Out'),
          content: const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text('Are you sure you want to sign out of your account?'),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await onConfirmSignOut();
      }
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFFF7A00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await onConfirmSignOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sign out',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(33),
          child: Container(
            width: double.infinity,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E5),
              borderRadius: BorderRadius.circular(33),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(AppIcons.logOut, size: 22, color: Color(0xFFFF7A00)),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF7A00),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
