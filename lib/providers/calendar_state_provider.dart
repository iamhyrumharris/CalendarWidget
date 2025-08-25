import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_models.dart';
import '../utils/constants.dart';
import '../utils/date_extensions.dart';

final currentDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final visibleMonthsProvider = StateNotifierProvider<VisibleMonthsNotifier, List<DateTime>>((ref) {
  return VisibleMonthsNotifier();
});

class VisibleMonthsNotifier extends StateNotifier<List<DateTime>> {
  VisibleMonthsNotifier() : super([]) {
    _initializeVisibleMonths();
  }

  void _initializeVisibleMonths() {
    final now = DateTime.now();
    final months = <DateTime>[];
    
    for (int i = -3; i <= 3; i++) {
      months.add(DateTime(now.year, now.month + i, 1));
    }
    
    state = months;
  }

  void updateVisibleRange(DateTime firstMonth, DateTime lastMonth) {
    final months = <DateTime>[];
    DateTime current = firstMonth.firstDayOfMonth;
    
    while (current.isBefore(lastMonth) || current.isSameMonth(lastMonth)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    
    state = months;
  }

  void addMonthsAtEnd(int count) {
    if (state.isEmpty) return;
    
    final lastMonth = state.last;
    final newMonths = List<DateTime>.from(state);
    
    for (int i = 1; i <= count; i++) {
      newMonths.add(DateTime(lastMonth.year, lastMonth.month + i, 1));
    }
    
    if (newMonths.length > CalendarConstants.maxCachedMonths) {
      newMonths.removeRange(0, newMonths.length - CalendarConstants.maxCachedMonths);
    }
    
    state = newMonths;
  }

  void addMonthsAtStart(int count) {
    if (state.isEmpty) return;
    
    final firstMonth = state.first;
    final newMonths = <DateTime>[];
    
    for (int i = count; i >= 1; i--) {
      newMonths.add(DateTime(firstMonth.year, firstMonth.month - i, 1));
    }
    
    newMonths.addAll(state);
    
    if (newMonths.length > CalendarConstants.maxCachedMonths) {
      newMonths.removeRange(
        CalendarConstants.maxCachedMonths, 
        newMonths.length
      );
    }
    
    state = newMonths;
  }
}

final monthDataProvider = StateNotifierProvider.family<MonthDataNotifier, MonthData?, DateTime>(
  (ref, month) => MonthDataNotifier(month),
);

class MonthDataNotifier extends StateNotifier<MonthData?> {
  final DateTime month;
  
  MonthDataNotifier(this.month) : super(null) {
    _loadMonthData();
  }

  void _loadMonthData() {
    final days = <CalendarDay>[];
    final daysInMonth = month.daysInMonth;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      days.add(CalendarDay(
        date: date,
        imagePath: null,
        thumbnailPath: null,
        hasEntry: false,
      ));
    }
    
    state = MonthData(
      month: month,
      days: days,
      isLoaded: true,
    );
  }

  void updateDay(CalendarDay day) {
    if (state == null) return;
    
    final updatedDays = state!.days.map((d) {
      if (d.date.isSameDay(day.date)) {
        return day;
      }
      return d;
    }).toList();
    
    state = state!.copyWith(days: updatedDays);
  }

  void addImageToDay(DateTime date, String imagePath, String thumbnailPath) {
    if (state == null) return;
    
    final updatedDays = state!.days.map((day) {
      if (day.date.isSameDay(date)) {
        return day.copyWith(
          imagePath: imagePath,
          thumbnailPath: thumbnailPath,
          hasEntry: true,
        );
      }
      return day;
    }).toList();
    
    state = state!.copyWith(days: updatedDays);
  }
}

final scrollPositionProvider = StateNotifierProvider<ScrollPositionNotifier, double>(
  (ref) => ScrollPositionNotifier(),
);

class ScrollPositionNotifier extends StateNotifier<double> {
  Timer? _debounceTimer;
  
  ScrollPositionNotifier() : super(0.0);

  void updatePosition(double position) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(CalendarConstants.scrollDebounce, () {
      state = position;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final calendarViewportProvider = Provider<CalendarViewportInfo>((ref) {
  final visibleMonths = ref.watch(visibleMonthsProvider);
  final scrollPosition = ref.watch(scrollPositionProvider);
  
  if (visibleMonths.isEmpty) {
    final now = DateTime.now();
    return CalendarViewportInfo(
      firstVisibleMonth: now.firstDayOfMonth,
      lastVisibleMonth: now.firstDayOfMonth,
      scrollOffset: 0.0,
    );
  }
  
  return CalendarViewportInfo(
    firstVisibleMonth: visibleMonths.first,
    lastVisibleMonth: visibleMonths.last,
    scrollOffset: scrollPosition,
  );
});

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final calendarDaysCache = <String, List<DateTime?>>{};

final calendarDaysProvider = Provider.family<List<DateTime?>, DateTime>((ref, month) {
  final key = '${month.year}-${month.month}';
  
  if (calendarDaysCache.containsKey(key)) {
    return calendarDaysCache[key]!;
  }
  
  final days = month.getCalendarDaysForMonth();
  calendarDaysCache[key] = days;
  
  if (calendarDaysCache.length > 20) {
    final keysToRemove = calendarDaysCache.keys.take(5).toList();
    for (final k in keysToRemove) {
      calendarDaysCache.remove(k);
    }
  }
  
  return days;
});

final jumpToDateProvider = Provider<void Function(DateTime)>((ref) {
  return (DateTime date) {
    final visibleMonths = ref.read(visibleMonthsProvider.notifier);
    // Load 3 months before and 3 months after the selected date (7 months total)
    final firstMonth = DateTime(date.year, date.month - 3, 1);
    final lastMonth = DateTime(date.year, date.month + 3, 1);
    visibleMonths.updateVisibleRange(firstMonth, lastMonth);
  };
});

// Loading states for pull-to-load functionality
final isLoadingEarlierMonthsProvider = StateProvider<bool>((ref) => false);
final isLoadingLaterMonthsProvider = StateProvider<bool>((ref) => false);

// Pull progress tracking
final pullProgressTopProvider = StateProvider<double>((ref) => 0.0);
final pullProgressBottomProvider = StateProvider<double>((ref) => 0.0);