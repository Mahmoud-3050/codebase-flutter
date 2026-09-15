import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/utils/values/text_styles.dart';
import 'app_shimmer.dart';
import 'field_errors_scope.dart';

class AppDropdown<T> extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final String? textItemBuilder;
  final T? value;
  final List<T> values;
  final List<String> names;
  final Widget? iconItemBuilder;
  final Widget? iconItemMenu;
  final List<Widget?> itemIcons;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function(T?)? onChanged;
  final bool isOptional;
  final bool showRequiredSymbol;
  final bool hasError;
  final String? errorText;
  final String? fieldName;
  final bool showArrow;
  final bool enabled;

  const AppDropdown({
    required this.value,
    required this.values,
    required this.names,
    required this.hintText,
    required this.onChanged,
    super.key,
    this.labelText,
    this.iconItemBuilder,
    this.backgroundColor,
    this.borderColor,
    this.textItemBuilder,
    this.iconItemMenu,
    this.itemIcons = const [],
    this.isOptional = false,
    this.showRequiredSymbol = false,
    this.hasError = false,
    this.errorText,
    this.fieldName,
    this.showArrow = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final models = _models;
    final visibleError = _visibleError(context);
    final isInvalid = hasError || visibleError != null;
    final isEnabled = enabled && onChanged != null;

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (labelText != null) ...[_buildLabel(colors), SizedBox(height: 4.h)],
        _buildDropdown(
          colors: colors,
          models: models,
          isInvalid: isInvalid,
          isEnabled: isEnabled,
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

  List<DropdownItemModel<T>> get _models {
    final length = values.length < names.length ? values.length : names.length;
    return [
      for (var i = 0; i < length; i++)
        DropdownItemModel<T>(
          name: names[i],
          value: values[i],
          icon: i < itemIcons.length ? itemIcons[i] : iconItemMenu,
        ),
    ];
  }

  T? get _safeValue {
    final selected = value;
    if (selected == null) return null;
    for (final item in values) {
      if (item == selected) return selected;
    }
    return null;
  }

  String? _visibleError(BuildContext context) {
    if (errorText != null && errorText!.isNotEmpty) return errorText;
    return FieldErrorsScope.of(context).messageFor(fieldName);
  }

  Widget _buildLabel(ThemeColors colors) {
    final style = TextStyles.of(size: 16, weight: .w500);
    final label = labelText ?? '';
    if (!showRequiredSymbol) {
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

  Widget _buildDropdown({
    required ThemeColors colors,
    required List<DropdownItemModel<T>> models,
    required bool isInvalid,
    required bool isEnabled,
  }) {
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: .circular(8.r),
        color: backgroundColor,
        border: .all(color: isInvalid ? colors.error : (borderColor ?? colors.hint)),
      ),
      child: DropdownButton<T>(
        value: _safeValue,
        menuMaxHeight: 0.35.sh,
        icon: showArrow
            ? Icon(
                Icons.arrow_drop_down_rounded,
                color: isEnabled && models.isNotEmpty
                    ? (isInvalid ? colors.error : colors.textPrimary)
                    : colors.hint,
                size: 20.r,
              )
            : const SizedBox.shrink(),
        hint: _buildHintText(colors),
        borderRadius: .circular(8.r),
        isExpanded: true,
        underline: const SizedBox(),
        selectedItemBuilder: (BuildContext context) => _selectedItems(colors, models),
        items: _menuItems(models),
        onChanged: isEnabled ? onChanged : null,
      ),
    );
  }

  List<Widget> _selectedItems(ThemeColors colors, List<DropdownItemModel<T>> models) {
    return [
      if (isOptional) _buildHintText(colors),
      for (final item in models) _buildSelectedItem(colors, item),
    ];
  }

  List<DropdownMenuItem<T>> _menuItems(List<DropdownItemModel<T>> models) {
    return [
      if (isOptional)
        DropdownMenuItem<T>(
          child: Text(Strings.none, style: TextStyles.of(size: 14, weight: .w500)),
        ),
      for (final item in models)
        DropdownMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null) ...[item.icon!, SizedBox(width: 4.w)],
              Expanded(
                child: Text(item.name, style: TextStyles.of(size: 14, weight: .w500)),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildSelectedItem(ThemeColors colors, DropdownItemModel<T> item) {
    final prefix = textItemBuilder;
    if (prefix != null) {
      return Row(
        children: [
          showRequiredSymbol
              ? Text.rich(
                  TextSpan(
                    text: prefix,
                    style: TextStyles.of(size: 12, color: colors.textSecondary),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyles.of(size: 12, color: colors.error),
                      ),
                    ],
                  ),
                )
              : Text(prefix, style: TextStyles.of(size: 12, color: colors.textSecondary)),
          SizedBox(width: 8.w),
          Container(width: 2.w, height: 32.h, color: colors.divider),
          SizedBox(width: 8.w),
          if (item.icon != null) ...[item.icon!, SizedBox(width: 8.w)],
          Expanded(child: _buildSelectedText(item.name)),
        ],
      );
    }
    if (item.icon != null) {
      return Row(
        children: [
          item.icon!,
          SizedBox(width: 8.w),
          Expanded(child: _buildSelectedText(item.name)),
        ],
      );
    }
    return _buildSelectedText(item.name);
  }

  Widget _buildHintText(ThemeColors colors) {
    final hintStyle = TextStyles.of(size: 14, color: colors.hint);
    final Widget hint = showRequiredSymbol && labelText == null
        ? Text.rich(
            TextSpan(
              text: hintText,
              style: hintStyle,
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyles.of(size: 12, color: colors.error),
                ),
              ],
            ),
          )
        : Text(hintText, style: hintStyle);

    final icon = iconItemBuilder;
    if (icon == null) return hint;
    return Row(
      children: [
        icon,
        SizedBox(width: 8.w),
        Expanded(child: hint),
      ],
    );
  }

  Widget _buildSelectedText(String value) {
    return Text(
      value,
      style: TextStyles.of(size: 14, weight: .w500),
      maxLines: 2,
      overflow: .ellipsis,
    );
  }
}

class AppDropdownShimmer extends StatelessWidget {
  final String? labelText;

  const AppDropdownShimmer({this.labelText, super.key});

  @override
  Widget build(BuildContext context) {
    final label = labelText;
    if (label == null) return _dropdown(context);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: TextStyles.of(size: 16, weight: .w500)),
        SizedBox(height: 4.h),
        _dropdown(context),
      ],
    );
  }

  Widget _dropdown(BuildContext context) {
    final colors = context.colors;
    return AppShimmer(
      child: Container(
        padding: .symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(borderRadius: .circular(8.r), color: colors.foreground),
        child: DropdownButton<int>(
          icon: Icon(Icons.arrow_drop_down_rounded, color: colors.unselected, size: 20.r),
          hint: Text(
            'hintText',
            style: TextStyles.of(size: 14, color: colors.unselected),
          ),
          borderRadius: .circular(8.r),
          isExpanded: true,
          underline: const SizedBox(),
          items: const [],
          onChanged: null,
        ),
      ),
    );
  }
}

class AppDropdownErrorWidget extends StatelessWidget {
  final String errorText;
  final String? labelText;
  final VoidCallback? onRetry;

  const AppDropdownErrorWidget({
    required this.errorText,
    this.labelText,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final label = labelText;
    if (label == null) return _dropdown(context);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: TextStyles.of(size: 16, weight: .w500)),
        SizedBox(height: 4.h),
        _dropdown(context),
      ],
    );
  }

  Widget _dropdown(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: .circular(8.r),
        color: colors.foreground,
        border: .all(color: colors.error),
      ),
      child: DropdownButton<int>(
        icon: GestureDetector(
          onTap: onRetry,
          child: Icon(Icons.refresh_rounded, color: colors.hint, size: 20.r),
        ),
        hint: Text(errorText, style: TextStyles.of(size: 14, color: colors.error)),
        borderRadius: .circular(8.r),
        isExpanded: true,
        underline: const SizedBox(),
        items: const [],
        onChanged: null,
      ),
    );
  }
}

class DropdownItemModel<T> {
  final String name;
  final T value;
  final Widget? icon;

  const DropdownItemModel({required this.name, required this.value, this.icon});

  DropdownItemModel<T> copyWith({String? name, T? value, Widget? icon}) {
    return DropdownItemModel<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      icon: icon ?? this.icon,
    );
  }
}
