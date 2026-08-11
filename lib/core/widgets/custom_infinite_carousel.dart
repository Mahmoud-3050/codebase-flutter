import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfiniteSmoothAutoScroll extends StatefulWidget {
  final List<Widget> items;
  final Duration scrollSpeed;
  final Duration startDelay;

  const InfiniteSmoothAutoScroll({
    required this.items, super.key,
    this.scrollSpeed = const Duration(milliseconds: 16), // ~60 FPS
    this.startDelay = const Duration(seconds: 1), 
  });

  @override
  State<InfiniteSmoothAutoScroll> createState() => _InfiniteSmoothAutoScrollState();
}

class _InfiniteSmoothAutoScrollState extends State<InfiniteSmoothAutoScroll>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  bool _appShouldScroll = true;      // controlled by AppLifecycle
  bool _userIsDragging = false;      // controlled by user gestures
  bool _scrollLoopRunning = true;    // keeps the loop going
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller.addListener(() {
      if (_userIsDragging) return; // Already dragging
      if (_controller.position.isScrollingNotifier.value) {
        // User started interacting via touch or mouse
        _onScrollStart();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.startDelay, () => _startAutoScrollLoop());
    });
  }

  @override
  void dispose() {
    _scrollLoopRunning = false;
    _autoScrollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Pause/resume based on app lifecycle (background/foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appShouldScroll = true;
    } else {
      _appShouldScroll = false;
    }
  }

  // Starts the continuous auto‐scroll loop:
  void _startAutoScrollLoop() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.scrollSpeed, (_) {
      // if either the app is backgrounded OR user is dragging, skip
      if (!_scrollLoopRunning || !_appShouldScroll || _userIsDragging) return;
      if (!_controller.hasClients) return;

      final double currentOffset = _controller.offset + 1.65;
      final double maxExtent = _controller.position.maxScrollExtent;

      // When we get near the end, jump back by a chunk so it appears infinite.
      if (currentOffset >= maxExtent - 300) {
        _controller.jumpTo(_controller.offset - 300);
      } else {
        _controller.jumpTo(currentOffset);
      }
    });
  }

  // Called by NotificationListener when user starts dragging
  void _onScrollStart() {
    _userIsDragging = true;
  }

  // Called by NotificationListener when user stops dragging
  Timer? _resumeTimer;

  void _onScrollEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 750), () {
      _userIsDragging = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox();

    return SizedBox(
      height: 0.11.sh,
      child: GestureDetector(
        onPanDown: (_) => _onScrollStart(),
        onPanEnd: (_) => _onScrollEnd(),
        onPanCancel: _onScrollEnd,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          // **REMOVE** NeverScrollableScrollPhysics so that user can drag
          itemBuilder: (context, index) {
            final item = widget.items[index % widget.items.length];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: item,
            );
          },
        ),
      ),
    );
  }
}
