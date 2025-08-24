import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_models.dart';
import '../../providers/calendar_state_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_extensions.dart';

class OptimizedMonthSliver extends ConsumerStatefulWidget {
  final DateTime month;
  
  const OptimizedMonthSliver({
    super.key,
    required this.month,
  });

  @override
  ConsumerState<OptimizedMonthSliver> createState() => _OptimizedMonthSliverState();
}

class _OptimizedMonthSliverState extends ConsumerState<OptimizedMonthSliver> 
    with AutomaticKeepAliveClientMixin {
  late String _monthName;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _monthName = DateFormat.yMMMM().format(widget.month);
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final calendarDays = ref.watch(calendarDaysProvider(widget.month));
    
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _MonthHeader(monthName: _monthName),
        ),
        _MonthGrid(
          month: widget.month,
          calendarDays: calendarDays,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: CalendarConstants.monthSpacing),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthName;
  
  const _MonthHeader({required this.monthName});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        monthName,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: CalendarConstants.monthHeaderFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  final DateTime month;
  final List<DateTime?> calendarDays;
  
  const _MonthGrid({
    required this.month,
    required this.calendarDays,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthData = ref.watch(monthDataProvider(month));
    final dayMap = <DateTime, CalendarDay>{};
    
    if (monthData != null) {
      for (final day in monthData.days) {
        dayMap[day.date] = day;
      }
    }
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: CalendarConstants.dayGap),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: CalendarConstants.dayGap,
          crossAxisSpacing: CalendarConstants.dayGap,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= calendarDays.length) return null;
            
            final date = calendarDays[index];
            
            if (date == null) {
              return const _EmptyCell();
            }
            
            final calendarDay = dayMap[date];
            
            return OptimizedDayCell(
              key: ValueKey(date),
              day: calendarDay,
              date: date,
            );
          },
          childCount: calendarDays.length,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark 
          ? CalendarColors.darkDayBackground.withValues(alpha: 0.3)
          : CalendarColors.lightDayBackground.withValues(alpha: 0.3),
    );
  }
}

class OptimizedDayCell extends StatelessWidget {
  final CalendarDay? day;
  final DateTime date;
  
  const OptimizedDayCell({
    super.key,
    this.day,
    required this.date,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final isToday = date.isSameDay(now);
    
    return Container(
      decoration: BoxDecoration(
        color: day?.hasImage == true 
            ? null 
            : (isDark ? CalendarColors.emptyDayDark : CalendarColors.emptyDayLight),
        border: isToday
            ? Border.all(
                color: isDark
                    ? CalendarColors.todayBorderDark
                    : CalendarColors.todayBorderLight,
                width: CalendarColors.todayBorderWidth,
              )
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (day?.hasImage == true) _buildImage(),
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: day?.hasImage == true
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: CalendarConstants.dayNumberFontSize,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                shadows: day?.hasImage == true
                    ? const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImage() {
    return const SizedBox.shrink();
  }
}