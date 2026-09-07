import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/language/strings.dart';
import '../../core/presentation/api_call_state.dart';
import '../../core/utils/extensions.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/api_call_widget.dart';
import 'pagination_cubit.dart';

class PaginationWidget<C extends PaginationCubit<T>, T extends Object>
    extends StatefulWidget {
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget? shimmerItem;
  final int shimmerCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Widget Function()? emptyWidget;
  final Widget Function(String message, VoidCallback onRetry)? errorWidget;
  final double loadMoreExtentThreshold;

  const PaginationWidget({
    required this.itemBuilder,
    this.separatorBuilder,
    this.shimmerItem,
    this.shimmerCount = 5,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.emptyWidget,
    this.errorWidget,
    this.loadMoreExtentThreshold = 200,
    super.key,
  });

  @override
  State<PaginationWidget<C, T>> createState() => _PaginationWidgetState<C, T>();
}

class _PaginationWidgetState<C extends PaginationCubit<T>, T extends Object>
    extends State<PaginationWidget<C, T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  C get _cubit => context.read<C>();

  void _onScroll() {
    if (_isNearEnd) {
      _cubit.fLoadNextPage();
    }
  }

  bool get _isNearEnd {
    if (!_scrollController.hasClients) {
      return false;
    }
    final ScrollPosition position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) {
      return false;
    }
    if (position.maxScrollExtent <= 0) {
      return false;
    }
    return position.pixels >=
        position.maxScrollExtent - widget.loadMoreExtentThreshold;
  }

  void _loadMoreIfViewportNotFilled() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_scrollController.hasClients) {
        return;
      }
      final ScrollPosition position = _scrollController.position;
      if (!position.hasContentDimensions) {
        return;
      }
      if (position.maxScrollExtent <= 0 && _cubit.hasMore) {
        _cubit.fLoadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<C, ApiCallState<List<T>>>(
      listener: (BuildContext context, ApiCallState<List<T>> state) {
        if (state is ApiCallSuccess<List<T>>) {
          _loadMoreIfViewportNotFilled();
        }
      },
      builder: (BuildContext context, ApiCallState<List<T>> state) {
        return ApiCallWidget<List<T>>(
          state: state,
          loadingWidget: _buildLoading,
          emptyWidget: widget.emptyWidget,
          errorWidget: () => _buildError(state),
          refreshWidget: () => _buildList(state),
          successWidget: () => _buildList(state),
        );
      },
    );
  }

  Widget _buildLoading() {
    if (widget.shimmerItem == null) {
      return Center(child: const CircularProgressIndicator().appLoading);
    }
    return ListView.separated(
      padding: _padding,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.shimmerCount,
      separatorBuilder: _separatorBuilder,
      itemBuilder: (BuildContext context, int index) {
        return AppShimmer(child: widget.shimmerItem!);
      },
    );
  }

  Widget _buildError(ApiCallState<List<T>> state) {
    final String message = switch (state) {
      ApiCallError<List<T>>(:final message) => message,
      _ => Strings.pleaseTryAgainLater,
    };
    final VoidCallback onRetry = _cubit.fLoadFirstPage;
    if (widget.errorWidget != null) {
      return widget.errorWidget!(message, onRetry);
    }
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(message),
          TextButton(
            onPressed: onRetry,
            child: Text(Strings.pleaseTryAgainLater),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ApiCallState<List<T>> state) {
    final List<T> items = switch (state) {
      ApiCallSuccess<List<T>>(:final data) => data,
      ApiCallPagination<List<T>>(:final data) => data,
      ApiCallRefresh<List<T>>(:final data) => data ?? _cubit.items,
      _ => _cubit.items,
    };
    final bool showFooter = state.isPagination;

    return RefreshIndicator(
      onRefresh: _cubit.fRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: _padding,
        physics:
            widget.physics ??
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
        shrinkWrap: widget.shrinkWrap,
        itemCount: items.length + (showFooter ? 1 : 0),
        separatorBuilder: _separatorBuilder,
        itemBuilder: (BuildContext context, int index) {
          if (index < items.length) {
            return widget.itemBuilder(context, index, items[index]);
          }
          return Center(child: const CircularProgressIndicator().appLoading);
        },
      ),
    );
  }

  EdgeInsetsGeometry get _padding =>
      widget.padding ?? Paddings.symmetric(h: 16, v: 16);

  Widget _separatorBuilder(BuildContext context, int index) {
    if (widget.separatorBuilder != null) {
      return widget.separatorBuilder!(context, index);
    }
    return SizedBox(height: 16.h);
  }
}
