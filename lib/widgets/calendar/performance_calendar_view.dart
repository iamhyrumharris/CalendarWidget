import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_state_provider.dart';
import '../../utils/date_extensions.dart';
import '../headers/sticky_week_header.dart';
import 'optimized_month_sliver.dart';

class PerformanceCalendarView extends ConsumerStatefulWidget {
  const PerformanceCalendarView({super.key});

  @override
  ConsumerState<PerformanceCalendarView> createState() => PerformanceCalendarViewState();
}

class PerformanceCalendarViewState extends ConsumerState<PerformanceCalendarView> {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    
    if (visibleMonths.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
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