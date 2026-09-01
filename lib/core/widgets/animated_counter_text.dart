import 'package:flutter/material.dart';

import '../utils/values/text_styles.dart';

class AnimatedCounterText extends StatefulWidget {
  final int maxNumber;
  const AnimatedCounterText({required this.maxNumber, super.key});

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText> {
  late final Stream<int> _numberStream;
  int limitCounter = 10;
  int streamMilliseconds = 300;
  int widgetMilliseconds = 200;

  @override
  void initState() {
    _numberStream = createNumberStream(widget.maxNumber);
    super.initState();
  }

  Stream<int> createNumberStream(int maxNumber) async* {
    int j = 0;
    if (maxNumber > 0) {
      j = 1;
    }
    int editMaxNumber = maxNumber > limitCounter ? limitCounter : maxNumber;
    for (int i = j; i <= editMaxNumber; i++) {
      await Future.delayed(Duration(milliseconds: streamMilliseconds));
      yield i;
    }
    if (maxNumber > limitCounter) {
      await Future.delayed(Duration(milliseconds: streamMilliseconds + 100));
      yield maxNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _numberStream,
      builder: (context, snapshot) {
        int counter = snapshot.data ?? 0;
        return AnimatedSwitcher(
          duration: Duration(
            milliseconds: counter > limitCounter
                ? widgetMilliseconds + 100
                : widgetMilliseconds,
          ),
          transitionBuilder: (child, animation) {
            final position = Tween<Offset>(
              begin: (animation.status == AnimationStatus.completed)
                  ? counter > limitCounter
                        ? const Offset(0, 3.5)
                        : const Offset(0, 1)
                  : const Offset(0, -1),
              end: .zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: position, child: child),
            );
          },
          child: Text(
            snapshot.data?.toString() ?? '',
            style: TextStyles.of(size: 16, weight: .w700),
            key: UniqueKey(),
          ),
        );
      },
    );
  }
}
