import 'package:flutter/material.dart';

import '../../core/presentation/api_call_state.dart';
import 'empty_widget.dart';
import 'loading_widget.dart';

/// Switches between widgets from a shared [ApiCallState].
class ApiCallWidget<T> extends StatelessWidget {
  final ApiCallState<T> state;
  final Widget Function()? loadingWidget;
  final Widget Function() successWidget;
  final Widget Function() errorWidget;
  final Widget Function()? emptyWidget;
  final Widget Function()? holdingWidget;
  final Widget Function()? refreshWidget;
  final Duration? animationDuration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;
  final bool hideSuccessWidgetWhileRefreshing;

  const ApiCallWidget({
    required this.state,
    required this.errorWidget,
    required this.successWidget,
    this.loadingWidget,
    this.holdingWidget,
    this.emptyWidget,
    this.refreshWidget,
    this.animationDuration,
    this.transitionBuilder,
    this.hideSuccessWidgetWhileRefreshing = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration ?? const Duration(milliseconds: 300),
      transitionBuilder:
          transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
      child: switch (state) {
        ApiCallSuccess<T>() => successWidget,
        ApiCallError<T>() => errorWidget,
        ApiCallHolding<T>() => holdingWidget ?? _emptyBox,
        ApiCallLoading<T>() => loadingWidget ?? () => const LoadingWidget(),
        ApiCallEmpty<T>() => emptyWidget ?? () => const EmptyWidget(),
        ApiCallRefresh<T>() =>
          refreshWidget ??
              (hideSuccessWidgetWhileRefreshing ? successWidget : _emptyBox),
        ApiCallPagination<T>() => successWidget,
      }(),
    );
  }

  static Widget _emptyBox() => const SizedBox.shrink();
}
