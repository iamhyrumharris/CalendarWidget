import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_state_provider.dart';
import '../../utils/date_extensions.dart';
import '../../utils/constants.dart';
import '../headers/sticky_week_header.dart';
import 'optimized_month_sliver.dart';
import 'circular_pull_indicator.dart';
import 'callback_scroll_physics.dart';
import 'dart:math' as math;

class PerformanceCalendarView extends ConsumerStatefulWidget {
  const PerformanceCalendarView({super.key});

  @override
  ConsumerState<PerformanceCalendarView> createState() => PerformanceCalendarViewState();
}

class PerformanceCalendarViewState extends ConsumerState<PerformanceCalendarView> {
  late ScrollController _scrollController;
  
  Timer? _scrollDebouncer;
  double _lastOverscrollAmount = 0.0;
  OverscrollDirection? _currentOverscrollDirection;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScrollChanged);
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }
  
  @override
  void dispose() {
    _scrollDebouncer?.cancel();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScrollChanged() {
    if (_isLoading) return;
    
    // Debounce scroll events to prevent performance issues
    _scrollDebouncer?.cancel();
    _scrollDebouncer = Timer(const Duration(milliseconds: 16), () {
      if (!mounted || !_scrollController.hasClients) return;
      
      final position = _scrollController.position;
      
      // Calculate overscroll amounts
      final topOverscroll = math.max(0.0, position.minScrollExtent - position.pixels);
      final bottomOverscroll = math.max(0.0, position.pixels - position.maxScrollExtent);
      
      if (topOverscroll > 0) {
        _handleOverscroll(topOverscroll, OverscrollDirection.top);
      } else if (bottomOverscroll > 0) {
        _handleOverscroll(bottomOverscroll, OverscrollDirection.bottom);
      } else if (_lastOverscrollAmount > 0) {
        _handleOverscrollEnd();
      }
    });
  }
  
  void _handleOverscroll(double amount, OverscrollDirection direction) {
    if (!mounted) return;
    
    _lastOverscrollAmount = amount;
    _currentOverscrollDirection = direction;
    
    // Clamp the overscroll amount to prevent excessive values
    final clampedAmount = amount.clamp(0.0, CalendarConstants.pullToLoadThreshold * 1.5);
    final progress = clampedAmount / CalendarConstants.pullToLoadThreshold;
    
    // Delay provider updates to avoid modifying during build
    Future(() {
      if (!mounted) return;
      
      // Update the appropriate progress provider
      if (direction == OverscrollDirection.top) {
        ref.read(pullProgressTopProvider.notifier).state = progress;
        ref.read(pullProgressBottomProvider.notifier).state = 0.0;
      } else {
        ref.read(pullProgressBottomProvider.notifier).state = progress;
        ref.read(pullProgressTopProvider.notifier).state = 0.0;
      }
    });
    
    // Provide haptic feedback when threshold is reached
    if (progress >= 1.0 && clampedAmount == amount) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _handleOverscrollEnd() {
    if (!mounted) return;
    
    // Delay the logic to avoid modifying providers during build
    Future(() {
      if (!mounted) return;
      
      // Check if we should trigger loading
      if (_lastOverscrollAmount >= CalendarConstants.pullToLoadThreshold) {
        if (_currentOverscrollDirection == OverscrollDirection.top) {
          _loadEarlierMonths();
        } else if (_currentOverscrollDirection == OverscrollDirection.bottom) {
          _loadLaterMonths();
        }
      } else {
        _resetOverscroll();
      }
      
      _lastOverscrollAmount = 0.0;
      _currentOverscrollDirection = null;
    });
  }
  
  void _resetOverscroll() {
    if (!mounted) return;
    
    // Delay provider updates to avoid modifying during build
    Future(() {
      if (!mounted) return;
      
      ref.read(pullProgressTopProvider.notifier).state = 0.0;
      ref.read(pullProgressBottomProvider.notifier).state = 0.0;
    });
  }
  
  Future<void> _loadEarlierMonths() async {
    if (_isLoading || ref.read(isLoadingEarlierMonthsProvider)) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simply add months at the start - they appear immediately
    ref.read(visibleMonthsProvider.notifier).addMonthsAtStart(CalendarConstants.monthsToLoadOnPull);
    
    // Reset immediately - no loading spinner shown
    setState(() {
      _isLoading = false;
    });
    
    _resetOverscroll();
    
    // Here you would trigger async loading of events/data for the new months
    // The months are already visible and data populates as it arrives
  }
  
  Future<void> _loadLaterMonths() async {
    if (_isLoading || ref.read(isLoadingLaterMonthsProvider)) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Add months at the end - they appear immediately
    ref.read(visibleMonthsProvider.notifier).addMonthsAtEnd(CalendarConstants.monthsToLoadOnPull);
    
    // Reset immediately - no loading spinner shown
    setState(() {
      _isLoading = false;
    });
    
    _resetOverscroll();
    
    // Here you would trigger async loading of events/data for the new months
    // The months are already visible and data populates as it arrives
  }
  
  void _scrollToCurrentMonth() {
    final visibleMonths = ref.read(visibleMonthsProvider);
    final now = DateTime.now();
    
    for (int i = 0; i < visibleMonths.length; i++) {
      if (visibleMonths[i].isSameMonth(now)) {
        final estimatedMonthHeight = 400.0;
        final targetOffset = i * estimatedMonthHeight;
        
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
        break;
      }
    }
  }
  
  void jumpToDate(DateTime date) {
    ref.read(jumpToDateProvider)(date);
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final visibleMonths = ref.read(visibleMonthsProvider);
      
      for (int i = 0; i < visibleMonths.length; i++) {
        if (visibleMonths[i].isSameMonth(date)) {
          final estimatedMonthHeight = 400.0;
          _scrollController.animateTo(
            i * estimatedMonthHeight,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleMonths = ref.watch(visibleMonthsProvider);
    final isLoadingEarlier = ref.watch(isLoadingEarlierMonthsProvider);
    final isLoadingLater = ref.watch(isLoadingLaterMonthsProvider);
    final pullProgressTop = ref.watch(pullProgressTopProvider);
    final pullProgressBottom = ref.watch(pullProgressBottomProvider);
    
    if (visibleMonths.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: CallbackScrollPhysics(
            onOverscroll: _handleOverscroll,
            onOverscrollEnd: _handleOverscrollEnd,
          ),
          cacheExtent: MediaQuery.of(context).size.height * 2,
          slivers: [
            const SliverPersistentHeader(
              pinned: true,
              delegate: _OptimizedWeekHeaderDelegate(),
            ),
            
            ...visibleMonths.map((month) => OptimizedMonthSliver(
              key: ValueKey(month),
              month: month,
            )),
          ],
        ),
        
        // Top pull indicator
        if (pullProgressTop > 0 || isLoadingEarlier)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: CircularPullIndicator(
              progress: pullProgressTop,
              isLoading: isLoadingEarlier,
              isTop: true,
            ),
          ),
        
        // Bottom pull indicator
        if (pullProgressBottom > 0 || isLoadingLater)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CircularPullIndicator(
              progress: pullProgressBottom,
              isLoading: isLoadingLater,
              isTop: false,
            ),
          ),
      ],
    );
  }
}

class _OptimizedWeekHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _OptimizedWeekHeaderDelegate();

  @override
  double get minExtent => 40.0;

  @override
  double get maxExtent => 40.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const StickyWeekHeader();
  }

  @override
  bool shouldRebuild(_OptimizedWeekHeaderDelegate oldDelegate) => false;
}