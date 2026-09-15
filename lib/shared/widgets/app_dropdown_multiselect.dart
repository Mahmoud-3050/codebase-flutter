import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/utils/values/text_styles.dart';
import 'field_errors_scope.dart';

class AppDropdownMultiSelect<T> extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final String? textItemBuilder;
  final List<T> values;
  final List<String> names;
  final List<T> selectedItems;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function(List<T>)? onChanged;
  final bool hasError;
  final String? errorText;
  final String? fieldName;
  final bool showRequiredSymbol;
  final bool enabled;
  final bool closeOnSelect;

  const AppDropdownMultiSelect({
    required this.selectedItems,
    required this.values,
    required this.names,
    required this.hintText,
    super.key,
    this.labelText,
    this.textItemBuilder,
    this.backgroundColor,
    this.borderColor,
    this.onChanged,
    this.hasError = false,
    this.errorText,
    this.fieldName,
    this.showRequiredSymbol = false,
    this.enabled = true,
    this.closeOnSelect = false,
  });

  @override
  State<AppDropdownMultiSelect<T>> createState() =>
      _AppDropdownMultiSelectState<T>();
}

class _AppDropdownMultiSelectState<T> extends State<AppDropdownMultiSelect<T>> {
  static const Duration _borderAnimation = Duration(milliseconds: 150);
  static const double _maxMenuHeightFraction = 0.35;
  static const double _minMenuHeight = 72;
  static const double _itemHeight = 48;
  static const double _menuGap = 4;
  static const double _menuEdgeInset = 8;

  late List<T> _selected;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? _overlayEntry;
  ScrollPosition? _ancestorScrollPosition;
  bool _isMenuOpen = false;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  String? get _visibleError {
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return widget.errorText;
    }
    return FieldErrorsScope.of(context).messageFor(widget.fieldName);
  }

  bool get _isInvalid => widget.hasError || _visibleError != null;

  int get _itemCount {
    return widget.values.length < widget.names.length
        ? widget.values.length
        : widget.names.length;
  }

  @override
  void initState() {
    super.initState();
    _selected = List<T>.of(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant AppDropdownMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.selectedItems, widget.selectedItems)) {
      _selected = List<T>.of(widget.selectedItems);
      _rebuildOpenOverlay();
    }
    if (!listEquals(oldWidget.values, widget.values) ||
        !listEquals(oldWidget.names, widget.names)) {
      _selected = _selected.where(widget.values.contains).toList();
      if (_isMenuOpen) {
        _closeMenu();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isEnabled) _openMenu();
        });
      }
    }
  }

  @override
  void dispose() {
    _detachScrollListener();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _isMenuOpen = false;
    _scrollController.dispose();
    super.dispose();
  }

  void _rebuildOpenOverlay() {
    if (!_isMenuOpen || _overlayEntry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isMenuOpen) _overlayEntry?.markNeedsBuild();
    });
  }

  void _notifyChange() {
    widget.onChanged?.call(List<T>.of(_selected));
  }

  void _toggleItemSelection(T item) {
    if (!_isEnabled) return;
    if (_selected.contains(item)) {
      _selected.remove(item);
    } else {
      _selected.add(item);
    }
    setState(() {});
    _notifyChange();
    _overlayEntry?.markNeedsBuild();
    if (widget.closeOnSelect) _closeMenu();
  }

  void _toggleMenu() {
    if (!_isEnabled) return;
    _isMenuOpen ? _closeMenu() : _openMenu();
  }

  void _openMenu() {
    if (!_isEnabled || widget.values.isEmpty || _itemCount == 0) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    _attachScrollListener();
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    _detachScrollListener();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    if (!mounted) {
      _isMenuOpen = false;
      return;
    }
    if (_isMenuOpen) {
      setState(() => _isMenuOpen = false);
    }
  }

  void _attachScrollListener() {
    final scrollable = Scrollable.maybeOf(context);
    _ancestorScrollPosition = scrollable?.position;
    _ancestorScrollPosition?.addListener(_onAncestorScroll);
  }

  void _detachScrollListener() {
    _ancestorScrollPosition?.removeListener(_onAncestorScroll);
    _ancestorScrollPosition = null;
  }

  void _onAncestorScroll() {
    if (_isMenuOpen) _closeMenu();
  }

  OverlayEntry _createOverlayEntry() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxMenuHeight = _maxMenuHeightFraction.sh;
    final minMenuHeight = _minMenuHeight.h;
    final spaceBelow = screenHeight - offset.dy - size.height - minMenuHeight;
    final spaceAbove = offset.dy;
    final estimatedHeight =
        (_itemCount * _itemHeight.h) +
        ((_itemCount - 1) * 1) +
        _menuEdgeInset.h;
    final idealHeight = estimatedHeight.clamp(minMenuHeight, maxMenuHeight);
    final openUpward = spaceBelow < idealHeight && spaceAbove > spaceBelow;
    final menuOffset = openUpward ? -(idealHeight + _menuGap.h) : size.height;
    final finalHeight = openUpward
        ? (spaceAbove - _menuEdgeInset.h).clamp(minMenuHeight, idealHeight)
        : (spaceBelow - _menuEdgeInset.h).clamp(minMenuHeight, idealHeight);

    return OverlayEntry(
      builder: (BuildContext overlayContext) {
        final colors = overlayContext.colors;
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, menuOffset),
          child: TapRegion(
            groupId: this,
            onTapOutside: (_) => _closeMenu(),
            child: SizedBox(
              width: size.width,
              child: Material(
                color: colors.foreground,
                elevation: 4,
                borderRadius: .circular(8.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: finalHeight,
                    minHeight: minMenuHeight,
                  ),
                  child: _buildMenuList(colors),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuList(ThemeColors colors) {
    if (_itemCount == 0) {
      return Padding(
        padding: .all(16.r),
        child: Center(
          child: Text(
            Strings.noDataFound,
            style: TextStyles.of(size: 14, color: colors.hint),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 4.w,
      radius: .circular(2.r),
      child: ListView.builder(
        controller: _scrollController,
        padding: .zero,
        itemCount: _itemCount,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final item = widget.values[index];
          final name = widget.names[index];
          final isSelected = _selected.contains(item);
          return InkWell(
            onTap: () => _toggleItemSelection(item),
            child: Padding(
              padding: .symmetric(horizontal: 12.w, vertical: 10.h).add(
                .only(
                  top: index == 0 ? 4.h : 0,
                  bottom: index == _itemCount - 1 ? 4.h : 0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyles.of(
                        size: 14,
                        weight: .w500,
                        color: isSelected ? colors.primary : colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8.w),
                    Icon(Icons.check, color: colors.primary, size: 18.r),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visibleError = _visibleError;

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        if (widget.labelText != null) ...[
          _buildLabel(colors),
          SizedBox(height: 4.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: TapRegion(
            groupId: this,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: _buildField(colors),
            ),
          ),
        ),
        if (visibleError != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: .symmetric(horizontal: 12.w),
            child: Text(
              visibleError,
              style: TextStyles.of(size: 12, color: colors.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(ThemeColors colors) {
    final style = TextStyles.of(size: 16, weight: .w500);
    final label = widget.labelText ?? '';
    if (!widget.showRequiredSymbol) {
      return Text(label, style: style);
    }
    return Text.rich(
      TextSpan(
        text: label,
        style: style,
        children: [
          TextSpan(
            text: ' *',
            style: style.copyWith(color: colors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildField(ThemeColors colors) {
    final Color borderColor;
    if (_isInvalid) {
      borderColor = colors.error;
    } else if (_isMenuOpen) {
      borderColor = colors.primary;
    } else {
      borderColor = widget.borderColor ?? colors.hint;
    }

    return AnimatedContainer(
      duration: _borderAnimation,
      constraints: BoxConstraints(minHeight: 48.h, minWidth: 1.sw),
      padding: .symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: .circular(8.r),
        color: widget.backgroundColor,
        border: .all(color: borderColor),
      ),
      child: _buildFieldContent(colors),
    );
  }

  Widget _buildFieldContent(ThemeColors colors) {
    if (_selected.isEmpty) return _buildHintRow(colors);
    if (widget.textItemBuilder != null) {
      return _buildPrefixedTextRow(colors);
    }
    return Row(
      children: [
        Expanded(child: _buildChips(colors)),
        SizedBox(width: 8.w),
        _buildDropdownIcon(colors),
      ],
    );
  }

  Widget _buildHintRow(ThemeColors colors) {
    final hintStyle = TextStyles.of(size: 14, color: colors.hint);
    final Widget hint = widget.showRequiredSymbol && widget.labelText == null
        ? Text.rich(
            TextSpan(
              text: widget.hintText,
              style: hintStyle,
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyles.of(size: 12, color: colors.error),
                ),
              ],
            ),
          )
        : Text(
            widget.hintText,
            style: hintStyle,
            overflow: .ellipsis,
            maxLines: 1,
          );
    return Row(
      children: [
        Expanded(child: hint),
        SizedBox(width: 8.w),
        _buildDropdownIcon(colors),
      ],
    );
  }

  Widget _buildPrefixedTextRow(ThemeColors colors) {
    final prefix = widget.textItemBuilder ?? '';
    final prefixStyle = TextStyles.of(size: 12, color: colors.textSecondary);
    final Widget prefixLabel = widget.showRequiredSymbol
        ? Text.rich(
            TextSpan(
              text: prefix,
              style: prefixStyle,
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyles.of(size: 12, color: colors.error),
                ),
              ],
            ),
          )
        : Text(prefix, style: prefixStyle);
    return Row(
      children: [
        prefixLabel,
        SizedBox(width: 8.w),
        Container(width: 2.w, height: 32.h, color: colors.divider),
        SizedBox(width: 8.w),
        Expanded(child: _buildJoinedSelectedText(colors)),
        _buildDropdownIcon(colors),
      ],
    );
  }

  Widget _buildChips(ThemeColors colors) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 4.h,
      children: [for (final item in _selected) _buildChip(colors, item)],
    );
  }

  Widget _buildChip(ThemeColors colors, T item) {
    return Container(
      padding: .symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: .circular(12.r),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Text(_nameOf(item), style: TextStyles.of(size: 12, weight: .w600)),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _toggleItemSelection(item),
            behavior: .opaque,
            child: Icon(Icons.close, size: 12.r, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedSelectedText(ThemeColors colors) {
    return Text(
      _selected.map(_nameOf).join(', '),
      style: TextStyles.of(size: 14, weight: .w500),
      maxLines: 2,
      overflow: .ellipsis,
    );
  }

  String _nameOf(T item) {
    final index = widget.values.indexOf(item);
    if (index < 0 || index >= widget.names.length) return item.toString();
    return widget.names[index];
  }

  Widget _buildDropdownIcon(ThemeColors colors) {
    final Color iconColor;
    if (!_isEnabled || widget.values.isEmpty) {
      iconColor = colors.hint;
    } else if (_isInvalid) {
      iconColor = colors.error;
    } else if (_isMenuOpen) {
      iconColor = colors.primary;
    } else {
      iconColor = colors.textPrimary;
    }

    return Icon(
      _isMenuOpen ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
      color: iconColor,
      size: 20.r,
    );
  }
}
