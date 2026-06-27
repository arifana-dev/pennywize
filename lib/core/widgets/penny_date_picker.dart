import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';

class PennyDatePicker {
  PennyDatePicker._();

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: AppColors.charcoal.withValues(alpha: 0.45),
      builder: (_) => _PennyDatePickerSheet(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime.now().add(const Duration(days: 1)),
      ),
    );
  }
}

class _PennyDatePickerSheet extends StatefulWidget {
  const _PennyDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_PennyDatePickerSheet> createState() => _PennyDatePickerSheetState();
}

class _PennyDatePickerSheetState extends State<_PennyDatePickerSheet> {
  late DateTime _selected;
  late DateTime _visibleMonth;
  late final PageController _pageController;

  static const int _monthsRange = 240;
  late final int _initialPageIndex;

  @override
  void initState() {
    super.initState();
    _selected = _dateOnly(widget.initialDate);
    _visibleMonth = DateTime(_selected.year, _selected.month);
    _initialPageIndex = _monthsRange ~/ 2;
    _pageController = PageController(initialPage: _initialPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _monthForPage(int page) {
    final delta = page - _initialPageIndex;
    return DateTime(
      widget.initialDate.year,
      widget.initialDate.month + delta,
    );
  }

  void _goToMonth(int direction) {
    final next = _pageController.page!.round() + direction;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  bool _withinRange(DateTime d) {
    final start = _dateOnly(widget.firstDate);
    final end = _dateOnly(widget.lastDate);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(_visibleMonth);
    final selectedLabel =
        DateFormat('EEE, d MMM yyyy', 'id_ID').format(_selected);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PILIH TANGGAL',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedLabel,
                            style: GoogleFonts.fraunces(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.close_rounded,
                              size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _QuickPresets(
                selected: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onSelect: (d) {
                  setState(() {
                    _selected = d;
                    _visibleMonth = DateTime(d.year, d.month);
                  });
                  final delta = (d.year - widget.initialDate.year) * 12 +
                      (d.month - widget.initialDate.month);
                  _pageController.animateToPage(
                    _initialPageIndex + delta,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        toBeginningOfSentenceCase(monthLabel) ?? monthLabel,
                        style: GoogleFonts.fraunces(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _ArrowButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _goToMonth(-1),
                    ),
                    const SizedBox(width: 8),
                    _ArrowButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _goToMonth(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _WeekdayLabels(),
              const SizedBox(height: 4),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _monthsRange,
                  onPageChanged: (page) {
                    setState(() => _visibleMonth = _monthForPage(page));
                  },
                  itemBuilder: (ctx, page) {
                    final month = _monthForPage(page);
                    return _MonthGrid(
                      month: month,
                      selected: _selected,
                      isSelectable: _withinRange,
                      onSelect: (d) => setState(() => _selected = d),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(_selected),
                          child: const Text('Pilih tanggal'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _QuickPresets extends StatelessWidget {
  const _QuickPresets({
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDays = today.subtract(const Duration(days: 2));
    final lastWeek = today.subtract(const Duration(days: 7));

    final presets = <_Preset>[
      _Preset('Hari ini', today),
      _Preset('Kemarin', yesterday),
      _Preset('2 hari lalu', twoDays),
      _Preset('Minggu lalu', lastWeek),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = presets[i];
          final isSelected = _isSameDay(p.date, selected);
          final inRange = !p.date.isBefore(firstDate) &&
              !p.date.isAfter(lastDate);
          return _PresetChip(
            label: p.label,
            selected: isSelected,
            enabled: inRange,
            onTap: inRange ? () => onSelect(p.date) : null,
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Preset {
  const _Preset(this.label, this.date);
  final String label;
  final DateTime date;
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.charcoal
        : (enabled ? AppColors.card : AppColors.secondary);
    final fg = selected
        ? Colors.white
        : (enabled ? AppColors.textPrimary : AppColors.textMuted);
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppColors.charcoal : AppColors.divider,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  @override
  Widget build(BuildContext context) {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: labels.map((l) {
          final isWeekend = l == 'Sab' || l == 'Min';
          return Expanded(
            child: Center(
              child: Text(
                l.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isWeekend
                      ? AppColors.primaryDark
                      : AppColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.isSelectable,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final bool Function(DateTime) isSelectable;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = (first.weekday + 6) % 7;
    final cells = leadingEmpty + daysInMonth;
    final rows = (cells / 7).ceil();
    final totalCells = rows * 7;

    final today = DateTime.now();
    final todayStripped = DateTime(today.year, today.month, today.day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: totalCells,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (ctx, i) {
          final dayNum = i - leadingEmpty + 1;
          if (dayNum < 1 || dayNum > daysInMonth) {
            return const SizedBox.shrink();
          }
          final cellDate = DateTime(month.year, month.month, dayNum);
          final isSelected = cellDate.year == selected.year &&
              cellDate.month == selected.month &&
              cellDate.day == selected.day;
          final isToday = cellDate == todayStripped;
          final selectable = isSelectable(cellDate);
          final weekday = cellDate.weekday;
          final isWeekend = weekday == DateTime.saturday ||
              weekday == DateTime.sunday;

          return _DayCell(
            day: dayNum,
            isSelected: isSelected,
            isToday: isToday,
            isWeekend: isWeekend,
            selectable: selectable,
            onTap: selectable ? () => onSelect(cellDate) : null,
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
    required this.selectable,
    this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool selectable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.charcoal : Colors.transparent;
    Color fg;
    if (isSelected) {
      fg = Colors.white;
    } else if (!selectable) {
      fg = AppColors.textMuted.withValues(alpha: 0.45);
    } else if (isWeekend) {
      fg = AppColors.primaryDark;
    } else {
      fg = AppColors.textPrimary;
    }

    return Semantics(
      label: 'Tanggal $day${isToday ? ', hari ini' : ''}',
      button: selectable,
      selected: isSelected,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isToday && !isSelected
              ? const BorderSide(color: AppColors.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              '$day',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight:
                    (isSelected || isToday) ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
