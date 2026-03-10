import 'package:flutter/material.dart';
import '../constants.dart';

class CustomGasButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;
  final IconData? icon;

  const CustomGasButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.textColor = Colors.white,
    this.width =
        110, // Slightly narrower to fit 2-3 in row comfortably if needed, or stick to flex
    this.height = 55,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness if strict width isn't used by parent
    // However, usually we wrap these in Expanded or flexible containers in the parent.
    // For safety, we keep the minimumSize approach.

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: color,
        elevation: AppConstants.defaultElevation,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shadowColor: color.withOpacity(0.35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: textColor),
            SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 16, // Slightly smaller for modern clean look
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
