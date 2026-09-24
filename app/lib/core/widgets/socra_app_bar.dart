import 'package:flutter/material.dart';
import 'package:socra_task/core/widgets/socra_logo.dart';

/// Shared app bar so Dashboard / Tasks / Sticky Notes / Habits / Calendar
/// headings never shift: same height, same insets, same title style.
class SocraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SocraAppBar({
    required this.title,
    this.actions = const [],
    super.key,
  });

  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 12, top: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const SocraLogo(size: 28),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
