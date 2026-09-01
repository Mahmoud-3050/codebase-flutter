import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../utils/values/text_styles.dart';
import 'app_shimmer.dart';

class AppDropdown<T> extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final String? textItemBuilder;
  final T? value;
  final List<T> values;
  final List<String> names;
  final Widget? iconItemBuilder;
  final Widget? iconItemMenu;
  final Color? backgroundColor, borderColor;
  final void Function(T?)? onChanged;
  final bool isOptional;

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
    this.isOptional = false,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  Map<T, String> mapNamesValues = <T, String>{};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.values.length; i++) {
      mapNamesValues[widget.values[i]] = widget.names[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labelText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.labelText!,
            style: TextStyles.of(size: 16, weight: FontWeight.w500),
          ),
          SizedBox(height: 4.h),
          _dropdown,
        ],
      );
    }
    return _dropdown;
  }

  Widget get _dropdown {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: widget.backgroundColor,
        border: Border.all(color: widget.borderColor ?? context.colors.hint),
      ),
      child: DropdownButton<T>(
        value: widget.value,
        menuMaxHeight: 0.35.sh,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: widget.values.isEmpty
              ? context.colors.hint
              : widget.onChanged != null
                  ? context.colors.textPrimary
                  : context.colors.hint,
          size: 20.r,
        ),
        hint: _buildHintText(),
        borderRadius: BorderRadius.circular(8.r),
        isExpanded: true,
        underline: const SizedBox(),
        selectedItemBuilder: (context) {
          List<Widget> selectedItems = [];
          if (widget.isOptional) {
            final noneItem = DropdownMenuItem<T>(child: _buildHintText());
            selectedItems.add(noneItem);
          }
          List<Widget> valuesSelectedItems =
              mapNamesValues.entries.map((MapEntry<T, String> entry) {
            return DropdownMenuItem<T>(
              value: entry.key,
              child: Builder(
                builder: (context) {
                  if (widget.textItemBuilder != null) {
                    return Row(
                      children: <Widget>[
                        Text(
                          widget.textItemBuilder!,
                          style: TextStyles.of(
                              size: 12, color: context.colors.textSecondary),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 2.w,
                          height: 32.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 8.h),
                          color: context.colors.divider,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildSelectedText(entry.value),
                        ),
                      ],
                    );
                  }
                  return _buildSelectedText(entry.value);
                },
              ),
            );
          }).toList();
          selectedItems.addAll(valuesSelectedItems);
          return selectedItems;
        },
        items: _getItems(),
        onChanged: widget.onChanged,
      ),
    );
  }

  List<DropdownMenuItem<T>> _getItems() {
    List<DropdownMenuItem<T>> selectedItems = [];
    if (widget.isOptional) {
      final noneItem = DropdownMenuItem<T>(
        child: Row(
          children: <Widget>[
            Builder(
              builder: (context) {
                if (widget.iconItemMenu != null) {
                  return widget.iconItemMenu!;
                }
                return const SizedBox();
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                Strings.none,
                style: TextStyles.of(size: 14, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
      selectedItems.add(noneItem);
    }
    final valuesItems = mapNamesValues.entries.map((MapEntry<T, String> entry) {
      return DropdownMenuItem<T>(
        value: entry.key,
        child: Row(
          children: <Widget>[
            Builder(
              builder: (context) {
                if (widget.iconItemMenu != null) {
                  return widget.iconItemMenu!;
                }
                return const SizedBox();
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                entry.value,
                style: TextStyles.of(size: 14, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }).toList();
    selectedItems.addAll(valuesItems);
    return selectedItems;
  }

  Widget _buildHintText() {
    return Builder(
      builder: (BuildContext context) {
        if (widget.iconItemBuilder != null) {
          return Row(
            children: <Widget>[
              widget.iconItemBuilder!,
              SizedBox(width: 8.w),
              Text(
                widget.hintText,
                style: TextStyles.of(size: 14, color: context.colors.hint),
              ),
            ],
          );
        }
        return Text(
          widget.hintText,
          style: TextStyles.of(size: 12, color: context.colors.hint),
        );
      },
    );
  }

  Widget _buildSelectedText(String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyles.of(size: 14, weight: FontWeight.w500),
          ),
        ],
      ),
      maxLines: 100,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AppDropdownShimmer extends StatelessWidget {
  final String? labelText;
  const AppDropdownShimmer({super.key, this.labelText});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      if (labelText != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              labelText!,
              style: TextStyles.of(size: 18, weight: FontWeight.w500),
            ),
            SizedBox(height: 4.h),
            _dropdown(context),
          ],
        );
      }
      return _dropdown(context);
    });
  }

  Widget _dropdown(BuildContext context) {
    return AppShimmer(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: context.colors.foreground,
          ),
          child: DropdownButton<int>(
            value: 0,
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: context.colors.unselected,
            ),
            hint: Builder(builder: (BuildContext context) {
              return Text(
                'hintText',
                style: TextStyles.of(size: 15, color: context.colors.unselected),
              );
            }),
            borderRadius: BorderRadius.circular(8.r),
            isExpanded: true,
            underline: const SizedBox(),
            items: <DropdownMenuItem<int>>[
              DropdownMenuItem<int>(
                value: 0,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add, color: context.colors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      'entry.value',
                      style: TextStyles.of(
                          size: 14,
                          weight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ],
                ),
              )
            ],
            onChanged: (int? value) {},
          ),
        ),
      );
  }
}

