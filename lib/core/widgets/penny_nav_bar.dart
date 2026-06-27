import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class PennyNavTab {
  const PennyNavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class PennyFloatingNavBar extends StatelessWidget {
  const PennyFloatingNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterAction,
    this.centerLabel = 'Tambah',
    this.centerIcon = Icons.add_rounded,
  });

  final List<PennyNavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterAction;
  final String centerLabel;
  final IconData centerIcon;

  @override
  Widget build(BuildContext context) {
    assert(tabs.length == 2, 'PennyFloatingNavBar expects exactly 2 tabs');
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 86,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              top: 18,
              child: _NavCapsule(
                tabs: tabs,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ),
            Positioned(
              top: 0,
              child: _CenterAction(
                label: centerLabel,
                icon: centerIcon,
                onTap: onCenterAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCapsule extends StatelessWidget {
  const _NavCapsule({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<PennyNavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Row(
          children: [
            Expanded(
              child: _NavTabButton(
                tab: tabs[0],
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            const SizedBox(width: 78),
            Expanded(
              child: _NavTabButton(
                tab: tabs[1],
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final PennyNavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.55);
    return Semantics(
      label: tab.label,
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: Icon(
                    selected ? tab.activeIcon : tab.icon,
                    key: ValueKey(selected),
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.2,
                    color: color,
                  ),
                  child: Text(tab.label),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: selected ? 18 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
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

class _CenterAction extends StatefulWidget {
  const _CenterAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CenterAction> createState() => _CenterActionState();
}

class _CenterActionState extends State<_CenterAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Semantics(
          label: widget.label,
          button: true,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: AppColors.background,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Icon(widget.icon, size: 26, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
