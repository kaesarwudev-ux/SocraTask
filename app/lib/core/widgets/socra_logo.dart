import 'package:flutter/material.dart';
import 'package:socra_task/core/theme/app_theme.dart';

/// SocraTask brand mark, shown at the front of every page's app bar.
/// Falls back to the date badge if the asset ever fails to load.
class SocraLogo extends StatelessWidget {
  const SocraLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4.5),
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, err, _) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SocraTheme.ecoGreen,
            borderRadius: BorderRadius.circular(size / 4.5),
          ),
          child: Text(
            '${DateTime.now().day}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size / 2.25,
            ),
          ),
        ),
      ),
    );
  }
}
