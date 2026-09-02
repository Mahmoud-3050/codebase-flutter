import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';
import '../utils/values/text_styles.dart';

class AppDropdownMultiSelect<T> extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final String? textItemBuilder;
  final List<T> values;
  final List<String> names;
  final List<T> selectedItems;
  final Color? backgroundColor, borderColor;
  final void Function(List<T>)? onChanged;

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
  });

  @override
  State<AppDropdownMultiSelect<T>> createState() => _AppDropdownMultiSelectState<T>();
}

class _AppDropdownMultiSelectState<T> extends State<AppDropdownMultiSelect<T>> {
  List<T> _internalSelectedItems = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _internalSelectedItems = .from(widget.selectedItems);
  }

  void _toggleItemSelection(T item, Function setStateOverlay) {
    setStateOverlay(() {
      _internalSelectedItems.contains(item) ? _internalSelectedItems.remove(item) : _internalSelectedItems.add(item);
    });
    widget.onChanged?.call(_internalSelectedItems);
  }

  void _toggleDropdownMenu() {
    _isMenuOpen ? _closeMenu() : _openMenu();
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isMenuOpen = true;
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isMenuOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 0.35.sh),
              child: _buildMenuList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return StatefulBuilder(
      builder: (BuildContext context, Function setStateOverlay) {
        return ListView(
          padding: .zero,
          shrinkWrap: true,
          children: widget.values.map((T item) {
            final isSelected = _internalSelectedItems.contains(item);
            return _buildMenuItem(item, isSelected, setStateOverlay);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMenuItem(T item, bool isSelected, Function setStateOverlay) {
    return ListTile(
      title: Text(
        widget.names[widget.values.indexOf(item)],
        style: TextStyles.of(
          size: 14,
          weight: .w500,
          color: isSelected ? context.colors.green : context.colors.textPrimary,
        ),
        maxLines: 3,
      ),
      trailing: isSelected ? Icon(Icons.check, color: context.colors.green) : null,
      onTap: () => _toggleItemSelection(item, setStateOverlay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleDropdownMenu, child: _buildDropdownContainer()),
    );
  }

  Widget _buildDropdownContainer() {
    return Container(
      constraints: BoxConstraints(minHeight: 48.h, minWidth: 1.sw),
      padding: .symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: .circular(8.r),
        color: widget.backgroundColor,
        border: .all(color: widget.borderColor ?? context.colors.hint),
      ),
      child: _buildDropdownContent(),
    );
  }

  Widget _buildDropdownContent() {
    if (_internalSelectedItems.isEmpty) {
      return _buildHintRow();
    }
    return widget.textItemBuilder != null ? _buildCustomTextRow() : _buildSelectedItemsRow();
  }

  Widget _buildHintRow() {
    return Row(
      children: [
        Expanded(
          child: Text(widget.hintText, style: TextStyles.of(size: 12, color: context.colors.hint)),
        ),
        SizedBox(width: 8.w),
        _buildDropdownIcon(),
      ],
    );
  }

  Widget _buildCustomTextRow() {
    return Row(
      children: <Widget>[
        Text(widget.textItemBuilder!, style: TextStyles.of(size: 14, weight: .w500)),
        SizedBox(width: 8.w),
        Container(width: 2.w, height: 32.h, color: context.colors.divider),
        SizedBox(width: 8.w),
        Expanded(child: _buildSelectedText()),
        _buildDropdownIcon(),
      ],
    );
  }

  Widget _buildSelectedItemsRow() {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(child: _buildSelectedText()),
        _buildDropdownIcon(),
      ],
    );
  }

  Widget _buildSelectedText() {
    List<TextSpan> textSpans = _internalSelectedItems.asMap().entries.map((entry) {
      int index = entry.key;
      T item = entry.value;
      return TextSpan(
        text: widget.names[widget.values.indexOf(item)] + (index < _internalSelectedItems.length - 1 ? ', ' : ''),
        style: TextStyles.of(
          size: 14,
          weight: .w500,
          color: index.isEven ? context.colors.textPrimary : context.colors.textPrimary.withValues(alpha: 0.86),
        ),
      );
    }).toList();
    return RichText(
      text: TextSpan(children: textSpans),
      maxLines: 100,
      overflow: .ellipsis,
    );
  }

  Widget _buildDropdownIcon() {
    return Icon(
      Icons.arrow_drop_down_rounded,
      color: widget.values.isEmpty
          ? context.colors.hint
          : widget.onChanged != null
          ? context.colors.textPrimary
          : context.colors.hint,
      size: 20.r,
    );
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }
}
