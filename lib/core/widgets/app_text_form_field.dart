import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';
import 'package:field_validator/field_validator.dart';
import '../utils/values/strings.dart';
import '../utils/values/text_styles.dart';

class AppTextFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed, onPrefixIconPressed;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final double paddingVerticalFactory;
  final ValueChanged<String>? onChanged;
  final void Function()? onEditingComplete;
  final bool autofocus;
  final BorderRadius? borderRadius;
  final String? labelText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onTap;
  final Iterable<String>? autofillHints;
  final BaseValidator? validatorType;
  final String? Function(String?)? validator;
  final Color? backgroundColor, prefixIconColor, suffixIconColor, cursorColor;
  final Color? borderColor, focusBorderColor;
  final TextStyle? textStyle, hintTextStyle, labelTextStyle;

  const AppTextFormField({
    required this.controller, this.focusNode,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.prefix,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onPrefixIconPressed,
    this.onFieldSubmitted,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.autofocus = false,
    this.paddingVerticalFactory = 1,
    this.borderRadius,
    this.labelText,
    this.maxLines,
    this.readOnly = false,
    this.inputFormatters,
    this.onTap,
    this.autofillHints,
    this.validatorType,
    this.validator,
    this.backgroundColor,
    this.prefixIconColor,
    this.suffixIconColor,
    this.cursorColor,
    this.textStyle,
    this.hintTextStyle,
    this.labelTextStyle,
    this.borderColor,
    this.focusBorderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = this.focusNode?? FocusNode();
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      validator: validatorType != null
          ? (String? value) => validatorType?.validate(value)
          : validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
        if(maxLength == null){
          return null;
        }
        return Text(
          '$currentLength/$maxLength',
          style: TextStyles.regular10(color: colors.textSecondary),
        );
      },
      maxLines: maxLines,
      readOnly: readOnly,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      style: textStyle?? TextStyles.medium14(color: colors.textPrimary),
      cursorColor: cursorColor,
      cursorRadius: Radius.circular(8.r),
      decoration: _decoration,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      onTapOutside: (PointerDownEvent event) => focusNode.unfocus(),
    );
  }

  InputDecoration get _decoration => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    alignLabelWithHint: false,
    contentPadding: _padding,
    errorMaxLines: 2,
    fillColor: backgroundColor?? colors.primary.withValues(alpha: 0.05),
    filled: backgroundColor != null,
    focusColor: colors.primary,
    border: _createBorder(borderColor?? colors.primary.withValues(alpha: 0.05)),
    enabledBorder: _createBorder(borderColor?? colors.hint),
    focusedBorder: _createBorder(focusBorderColor?? colors.primary),
    focusedErrorBorder: _createBorder(colors.primary),
    errorBorder: _createBorder(colors.error),
    errorStyle: TextStyles.regular12(color: colors.error),
    hintStyle: hintTextStyle?? TextStyles.regular12(color: colors.textSecondary),
    labelStyle: labelTextStyle?? TextStyles.regular12(color: colors.textSecondary),
    prefixIcon: _prefixIcon,
    suffixIcon: _suffixIcon,
  );

  EdgeInsetsGeometry get _padding => EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 16.h * paddingVerticalFactory,
  );

  Widget? get _prefixIcon => (prefixIcon == null)
      ? prefix
      : InkWell(
          onTap: onPrefixIconPressed,
          child: Icon(
            prefixIcon,
            color: prefixIconColor ?? colors.hint,
          ),
        );

  Widget? get _suffixIcon => suffixIcon == null
      ? suffix
      : InkWell(
          onTap: onSuffixIconPressed,
          child: Icon(
            suffixIcon,
            color: suffixIconColor ?? colors.hint,
          ),
        );

  OutlineInputBorder _createBorder(Color color) {
    return OutlineInputBorder(
        borderRadius: borderRadius != null ? borderRadius! : BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color));
  }

  factory AppTextFormField.nameTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    IconData? prefixIcon = Icons.person_rounded,
    String? hintText = '',
    String? labelText,
    int? maxLength,
    int? maxLines = 1,
    TextInputAction? textInputAction = TextInputAction.next,
    BaseValidator? validatorType,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText?.isEmpty == true? Strings.name : hintText,
      labelText: labelText?.isEmpty == true? Strings.name : labelText,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validatorType: validatorType?? EmptyValidator(),
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
    );
  }

  factory AppTextFormField.emailTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    String? labelText,
    TextInputAction? textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
    final bool autofocus = false,
    final bool readOnly = false,
    final bool isValidate = true,
    BaseValidator? validatorType,
    void Function(String)? onChanged,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText?? Strings.email,
      labelText: labelText,
      autofocus: autofocus,
      readOnly: readOnly,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const <String>[AutofillHints.email],
      maxLines: 1,
      prefixIcon: Icons.email_rounded,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validatorType: validatorType?? EmptyValidator(),
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
    );
  }

  factory AppTextFormField.phoneTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction = TextInputAction.next,
    BaseValidator? validatorType,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
    String? labelText,
    String? hintText,
    bool readOnly = false,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText?? Strings.phoneNumber,
      labelText: labelText,
      maxLines: 1,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      prefixIcon: Icons.phone_rounded,
      validatorType: validatorType?? PhoneValidator(),
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      readOnly: readOnly,
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
    );
  }

  static Widget passwordTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction = TextInputAction.done,
    BaseValidator? validatorType,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    void Function(void Function(void Function()) localSetState)? onSuffixIconPressed,
    String? hintText,
    String? labelText,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? suffixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
  }) {
    bool isSecureText = true;
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      hintText ??= Strings.password;
      return AppTextFormField(
        controller: controller,
        focusNode: focusNode,
        hintText: hintText,
        labelText: labelText,
        obscureText: isSecureText,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        maxLines: 1,
        prefixIcon: Icons.lock_rounded,
        suffixIcon: isSecureText
            ? Icons.visibility_rounded
            : Icons.visibility_off_rounded,
        onSuffixIconPressed: () {
          setState(() {
            isSecureText = !isSecureText;
          });
        },
        validatorType: validatorType?? PasswordValidator(),
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        backgroundColor: backgroundColor,
        prefixIconColor: prefixIconColor,
        suffixIconColor: suffixIconColor,
        cursorColor: cursorColor,
        textStyle: textStyle,
        hintTextStyle: hintTextStyle,
        labelTextStyle: labelTextStyle,
        borderColor: borderColor,
        focusBorderColor: focusBorderColor,
      );
    });
  }

  factory AppTextFormField.search({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool readOnly = false,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool autofocus = false,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      // backgroundColor: colors.upBackground,
      borderRadius: BorderRadius.circular(24.r),
      // borderColor: colors.upBackground.withValues(alpha: 0.2),
      focusBorderColor: colors.primary,
      cursorColor: colors.primary,
      hintText: '${Strings.search}...',
      // hintTextStyle: TextStyles.regular14(color: colors.upBackground.withValues(alpha: 0.8)),
      // textStyle: TextStyles.regular14(color: colors.secondary),
      validatorType: EmptyValidator(),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icons.search_rounded,
      // prefixIconColor: colors.upBackground.withValues(alpha: 0.8),
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  factory AppTextFormField.numbersTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    String? labelText,
    bool isValidator = true,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      labelText: labelText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validatorType: isValidator ? NumbersValidator() : null,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\d{0,2}')),
      ],
    );
  }
}
