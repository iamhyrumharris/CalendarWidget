import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar/performance_calendar_view.dart' show PerformanceCalendarView, PerformanceCalendarViewState;
import '../widgets/common/date_picker_modal.dart';
import '../providers/calendar_state_provider.dart';
import '../providers/theme_provider.dart' as app_theme;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final GlobalKey<PerformanceCalendarViewState> _calendarKey = GlobalKey();

  void _showDatePicker() {
    final currentDate = ref.read(currentDateProvider);
    showDatePickerModal(
      context,
      currentDate,
      (selectedDate) {
        _calendarKey.currentState?.jumpToDate(selectedDate);
      },
    );
  }

  void _toggleTheme() {
    ref.read(app_theme.themeModeProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(app_theme.themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == app_theme.ThemeMode.dark
                  ? Icons.light_mode
                  : themeMode == app_theme.ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.brightness_auto,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showDatePicker,
            tooltip: 'Jump to date',
          ),
        ],
      ),
      body: PerformanceCalendarView(
        key: _calendarKey,
      ),
    );
  }
}