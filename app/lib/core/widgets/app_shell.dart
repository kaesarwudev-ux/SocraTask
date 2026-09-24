import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/widgets/socra_logo.dart';

/// Responsive shell: phone (<600) → bottom nav; tablet/desktop → custom
/// sidebar rail (icon-only ≤1024, labeled >1024). The rail collapses to
/// icons via its header toggle and animates open again. Whole rows
/// highlight on hover; the selected row gets a whisper-green tint.
class AppShell extends StatefulWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _collapsed = false;

  static const _items = [
    (icon: Icons.auto_awesome_mosaic_outlined, label: 'Study Space'),
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (icon: Icons.check_circle_outlined, label: 'Tasks'),
    (icon: Icons.calendar_month_outlined, label: 'Calendar'),
    (icon: Icons.sticky_note_2_outlined, label: 'Sticky Notes'),
    (icon: Icons.repeat_outlined, label: 'Habits'),
    (icon: Icons.style_outlined, label: 'Flashcards'),
  ];

  void _go(int index) => widget.shell.goBranch(index);

  Widget _railRow(
    BuildContext context,
    int index, {
    required bool extended,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.shell.currentIndex == index;
    final fg = selected ? SocraTheme.ecoGreen : scheme.onSurfaceVariant;
    final label = _items[index].label;
    // One pill per destination: icon left of text, generous even spacing.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: MouseRegion(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            key: ValueKey('rail-pill-$label'),
            borderRadius: BorderRadius.circular(28),
            hoverColor: SocraTheme.rowHover,
            highlightColor: SocraTheme.rowTint,
            onTap: () => _go(index),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 20 : 0,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color:
                    selected ? SocraTheme.rowTint : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: extended
                  ? Row(
                      children: [
                        Icon(_items[index].icon, color: fg),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Icon(_items[index].icon, color: fg),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: widget.shell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: _go,
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }
        final extended =
            constraints.maxWidth > 1024 && !_collapsed;
        // The collapse toggle only matters on wide screens; the narrow
        // rail is already icons-only.
        final canCollapse = constraints.maxWidth > 1024;
        return Scaffold(
          body: Row(
            children: [
              AnimatedContainer(
                key: const ValueKey('app-rail'),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: extended ? 280 : 72,
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: 280,
                    // Centered: icons glide to the middle as labels clip.
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 280,
                      child: Column(
                        children: [
                          // Brand: breathing room above, logo + name when
                          // expanded, lone logo when collapsed.
                          const SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: extended ? 16 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: extended
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                const SocraLogo(size: 28),
                                if (extended) ...[
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      'SocraTask',
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (var i = 0;
                              i < _items.length;
                              i++)
                            _railRow(context, i,
                                extended: extended),
                          const Spacer(),
                          if (canCollapse)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: extended ? 12 : 0,
                                vertical: 8,
                              ),
                              child: extended
                                  ? Tooltip(
                                      message: 'Collapse sidebar',
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(28),
                                        child: InkWell(
                                          key: const ValueKey(
                                              'rail-collapse'),
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          hoverColor: SocraTheme.rowHover,
                                          onTap: () => setState(() =>
                                              _collapsed = !_collapsed),
                                          child: Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .keyboard_double_arrow_left_outlined,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Collapse',
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                            context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      key: const ValueKey(
                                          'rail-expand'),
                                      tooltip: 'Expand sidebar',
                                      icon: const Icon(Icons
                                          .keyboard_double_arrow_right_outlined),
                                      onPressed: () => setState(() =>
                                          _collapsed = !_collapsed),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: widget.shell),
            ],
          ),
        );
      },
    );
  }
}
