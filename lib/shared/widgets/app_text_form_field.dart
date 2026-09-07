import 'package:field_validator/field_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart' hide PhoneValidator;
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/services/phone_number/phone_validation_service.dart';
import '../../core/utils/values/text_styles.dart';
import 'app_shimmer.dart';
import 'field_errors_scope.dart';

class AppTextFormField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget Function(bool hasFocus)? suffix;
  final Widget Function(bool hasFocus)? prefix;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed, onPrefixIconPressed;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final double paddingVerticalFactory;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final BorderRadius? borderRadius;
  final String? labelText;
  final bool showRequiredSymbol;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final BaseValidator? validatorType;
  final String? Function(String?)? validator;
  final Color? backgroundColor, prefixIconColor, suffixIconColor, cursorColor;
  final Color? borderColor, focusBorderColor;
  final Color? maxLengthTextColor;
  final TextStyle? textStyle, hintTextStyle, labelTextStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final String? errorText;
  final PointerDownEventListener? onTapOutside;
  final String? fieldName;
  final Map<String, List<String>>? fieldErrors;

  const AppTextFormField({
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText = '',
    this.obscureText = false,
    this.showRequiredSymbol = false,
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
    this.contentPadding,
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
    this.maxLengthTextColor,
    this.borderColor,
    this.focusBorderColor,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.onTapOutside,
    this.errorText,
    this.fieldName,
    this.fieldErrors,
    super.key,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();

  factory AppTextFormField.nameTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    IconData? prefixIcon = Icons.person_outline_rounded,
    String? hintText = '',
    String? labelText,
    String? errorText,
    int? maxLength,
    int? maxLines = 1,
    TextInputAction? textInputAction = .next,
    BaseValidator? validatorType,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
    bool readOnly = false,
    bool showRequiredSymbol = false,
    Widget Function(bool hasFocus)? suffix,
    String? fieldName = 'name',
    Map<String, List<String>>? fieldErrors,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText?.isEmpty == true ? Strings.name : hintText,
      labelText: labelText?.isEmpty == true ? Strings.name : labelText,
      errorText: errorText,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validatorType: validatorType ?? FieldValidator.required(),
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      readOnly: readOnly,
      showRequiredSymbol: showRequiredSymbol,
      suffix: suffix,
      fieldName: fieldName,
      fieldErrors: fieldErrors,
    );
  }

  factory AppTextFormField.emailTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    String? labelText,
    String? errorText,
    TextInputAction? textInputAction = .next,
    ValueChanged<String>? onFieldSubmitted,
    bool autofocus = false,
    bool readOnly = false,
    bool isValidate = true,
    bool showRequiredSymbol = false,
    BaseValidator? validatorType,
    ValueChanged<String>? onChanged,
    Widget Function(bool hasFocus)? suffix,
    IconData? prefixIcon = Icons.email_outlined,
    Color? backgroundColor,
    Color? prefixIconColor,
    Color? cursorColor,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    TextStyle? labelTextStyle,
    Color? borderColor,
    Color? focusBorderColor,
    String? fieldName = 'email',
    Map<String, List<String>>? fieldErrors,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText ?? Strings.email,
      labelText: labelText,
      errorText: errorText,
      autofocus: autofocus,
      readOnly: readOnly,
      showRequiredSymbol: showRequiredSymbol,
      keyboardType: .emailAddress,
      textInputAction: textInputAction,
      autofillHints: const <String>[AutofillHints.email],
      maxLines: 1,
      prefixIcon: prefixIcon,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      suffix: suffix,
      validatorType: isValidate ? (validatorType ?? FieldValidator.email()) : null,
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      fieldName: fieldName,
      fieldErrors: fieldErrors,
    );
  }

  factory AppTextFormField.phoneTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction = .next,
    BaseValidator? validatorType,
    String? errorText,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    Widget Function(bool hasFocus)? suffix,
    Widget Function(bool hasFocus)? prefix,
    IconData? prefixIcon = Icons.phone_outlined,
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
    bool autofocus = false,
    String? fieldName = 'phone',
    Map<String, List<String>>? fieldErrors,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText ?? Strings.phoneNumber,
      labelText: labelText,
      errorText: errorText,
      maxLines: 1,
      keyboardType: .phone,
      textInputAction: textInputAction,
      prefixIcon: prefix == null ? prefixIcon : null,
      prefix: prefix,
      validatorType: validatorType ?? FieldValidator.phone(),
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      readOnly: readOnly,
      autofocus: autofocus,
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      suffix: suffix,
      fieldName: fieldName,
      fieldErrors: fieldErrors,
      inputFormatters: <TextInputFormatter>[
        ArabicToEnglishNumberFormatter(),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  static Widget phoneWithCountryCode({
    required TextEditingController controller,
    required String dialingCode,
    required ValueChanged<String> onDialingCodeChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction = .next,
    BaseValidator? validatorType,
    String? errorText,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    Widget Function(bool hasFocus)? suffix,
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
    bool autofocus = false,
    String? fieldName = 'phone',
    Map<String, List<String>>? fieldErrors,
  }) {
    return _PhoneWithCountryCodeField(
      controller: controller,
      dialingCode: dialingCode,
      onDialingCodeChanged: onDialingCodeChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      validatorType: validatorType,
      errorText: errorText,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      suffix: suffix,
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      labelText: labelText,
      hintText: hintText,
      readOnly: readOnly,
      autofocus: autofocus,
      fieldName: fieldName,
      fieldErrors: fieldErrors,
    );
  }

  static Widget passwordTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction = .done,
    BaseValidator? validatorType,
    String? errorText,
    TextEditingController? confirmPasswordController,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
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
    bool readOnly = false,
    String? fieldName = 'password',
    Map<String, List<String>>? fieldErrors,
  }) {
    bool isSecureText = true;
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AppTextFormField(
          controller: controller,
          focusNode: focusNode,
          hintText: hintText ?? Strings.password,
          labelText: labelText,
          errorText: errorText,
          obscureText: isSecureText,
          keyboardType: .visiblePassword,
          textInputAction: textInputAction,
          maxLines: 1,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: isSecureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixIconPressed: () {
            setState(() => isSecureText = !isSecureText);
          },
          validatorType:
              validatorType ??
              (confirmPasswordController == null
                  ? const PasswordValidator()
                  : _PasswordMatchValidator(confirmPasswordController)),
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          onTap: onTap,
          backgroundColor: backgroundColor,
          prefixIconColor: prefixIconColor,
          suffixIconColor: suffixIconColor,
          cursorColor: cursorColor,
          textStyle: textStyle,
          hintTextStyle: hintTextStyle,
          labelTextStyle: labelTextStyle,
          borderColor: borderColor,
          focusBorderColor: focusBorderColor,
          readOnly: readOnly,
          fieldName: fieldName,
          fieldErrors: fieldErrors,
        );
      },
    );
  }

  factory AppTextFormField.search({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool readOnly = false,
    BaseValidator? validatorType,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool autofocus = false,
    String? hintText,
    Color? backgroundColor,
  }) {
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      backgroundColor: backgroundColor,
      borderRadius: .circular(16.r),
      hintText: hintText ?? '${Strings.search}...',
      validatorType: validatorType ?? FieldValidator.required(),
      keyboardType: .text,
      textInputAction: .search,
      prefixIcon: Icons.search_rounded,
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
    String? errorText,
    Color? borderColor,
    bool isValidator = true,
    BaseValidator? validatorType,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    EdgeInsetsGeometry? contentPadding,
    Widget Function(bool hasFocus)? prefix,
    String? fieldName,
    Map<String, List<String>>? fieldErrors,
  }) {
    final BaseValidator? resolvedValidator = isValidator
        ? (validatorType ?? FieldValidator.numbers())
        : validatorType;
    return AppTextFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      prefix: prefix,
      keyboardType: const .numberWithOptions(decimal: true),
      maxLines: 1,
      contentPadding: contentPadding,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validatorType: resolvedValidator,
      borderColor: borderColor,
      inputFormatters:
          resolvedValidator?.inputFormatters ??
          <TextInputFormatter>[ArabicToEnglishNumberFormatter()],
      fieldName: fieldName,
      fieldErrors: fieldErrors,
    );
  }

  static Widget shimmer({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final BorderRadius resolvedRadius = borderRadius ?? .circular(16.r);
    return ContainerShimmer(
      borderRadius: resolvedRadius,
      child: AppTextFormField(
        backgroundColor: Colors.transparent,
        borderRadius: resolvedRadius,
        contentPadding: contentPadding,
        readOnly: true,
      ),
    );
  }
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  static const WidgetStateProperty<Color> _transparentOverlay =
      WidgetStatePropertyAll<Color>(Colors.transparent);

  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  bool _ignoreExternalError = false;
  Map<String, List<String>>? _lastFieldErrors;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.fieldErrors != widget.fieldErrors ||
        oldWidget.errorText != widget.errorText) {
      _ignoreExternalError = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, List<String>> current = _resolveFieldErrors();
    if (!mapEquals(current, _lastFieldErrors)) {
      _lastFieldErrors = current;
      _ignoreExternalError = false;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Map<String, List<String>> _resolveFieldErrors() {
    return widget.fieldErrors ?? FieldErrorsScope.of(context);
  }

  String? get _visibleError {
    if (_ignoreExternalError) {
      return null;
    }
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return widget.errorText;
    }
    return _resolveFieldErrors().messageFor(widget.fieldName);
  }

  void _onChanged(String value) {
    if (!_ignoreExternalError && _visibleError != null) {
      setState(() => _ignoreExternalError = true);
    }
    widget.onChanged?.call(value);
  }

  String? _validate(String? value) {
    if (widget.validatorType != null) {
      return widget.validatorType!.validate(value);
    }
    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final Color cursor = widget.cursorColor ?? context.colors.primary;
    return TextFormField(
      initialValue: widget.initialValue,
      focusNode: _focusNode,
      controller: widget.controller,
      validator: _validate,
      obscureText: widget.obscureText,
      obscuringCharacter: '*',
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      buildCounter:
          (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
            if (maxLength == null) {
              return null;
            }
            return Text(
              '$currentLength/$maxLength',
              style: TextStyles.of(
                size: 10,
                color: widget.maxLengthTextColor ?? context.colors.textSecondary,
              ),
            );
          },
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLengthEnforcement: .enforced,
      style: widget.textStyle ?? TextStyles.of(size: 14, weight: .w500),
      cursorColor: cursor,
      cursorErrorColor: cursor,
      cursorRadius: .circular(8.r),
      decoration: _decoration(context),
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: _onChanged,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside ?? (_) => _focusNode.unfocus(),
    );
  }

  InputDecoration _decoration(BuildContext context) {
    final colors = context.colors;
    return InputDecoration(
      hintText: widget.hintText,
      labelText: widget.showRequiredSymbol ? null : widget.labelText,
      label: widget.showRequiredSymbol ? _requiredLabel(context) : null,
      alignLabelWithHint: false,
      contentPadding: _padding,
      errorText: _visibleError,
      errorMaxLines: 2,
      fillColor: widget.backgroundColor ?? colors.primary.withValues(alpha: 0.05),
      filled: true,
      focusColor: colors.primary,
      border: _createBorder(widget.borderColor ?? colors.primary.withValues(alpha: 0.05)),
      enabledBorder: _createBorder(widget.borderColor ?? colors.hint),
      focusedBorder: _createBorder(widget.focusBorderColor ?? colors.primary),
      focusedErrorBorder: _createBorder(colors.primary),
      errorBorder: _createBorder(colors.error),
      errorStyle: TextStyles.of(size: 12, color: colors.error),
      hintStyle:
          widget.hintTextStyle ?? TextStyles.of(size: 12, color: colors.textSecondary),
      labelStyle:
          widget.labelTextStyle ?? TextStyles.of(size: 12, color: colors.textSecondary),
      prefixIcon: _prefixIcon(context),
      prefixIconColor: _iconStateColor(context, fallback: widget.prefixIconColor),
      prefixIconConstraints: widget.prefix == null
          ? null
          : BoxConstraints(minHeight: 48.h),
      suffixIcon: _suffixIcon(context),
      suffixIconColor: _iconStateColor(context, fallback: widget.suffixIconColor),
      suffixIconConstraints: BoxConstraints(maxHeight: 32.r, maxWidth: 48.r),
    );
  }

  WidgetStateColor _iconStateColor(BuildContext context, {Color? fallback}) {
    final colors = context.colors;
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.focused)) {
        return colors.primary;
      }
      if (states.contains(WidgetState.error)) {
        return colors.error;
      }
      return fallback ?? colors.hint;
    });
  }

  Widget _requiredLabel(BuildContext context) {
    final TextStyle style =
        widget.labelTextStyle ??
        TextStyles.of(size: 12, color: context.colors.textSecondary);
    return Text.rich(
      TextSpan(
        text: widget.labelText,
        style: style,
        children: <InlineSpan>[
          TextSpan(
            text: ' *',
            style: style.copyWith(color: context.colors.error),
          ),
        ],
      ),
    );
  }

  EdgeInsetsGeometry get _padding =>
      widget.contentPadding ??
      .symmetric(horizontal: 16.w, vertical: 16.h * widget.paddingVerticalFactory);

  Widget? _prefixIcon(BuildContext context) {
    if (widget.prefixIcon != null) {
      return _boxedIcon(icon: widget.prefixIcon, onTap: widget.onPrefixIconPressed);
    }
    if (widget.prefix != null) {
      return _focusAwareSlot(builder: widget.prefix!);
    }
    return null;
  }

  Widget? _suffixIcon(BuildContext context) {
    if (widget.suffixIcon != null) {
      return Padding(
        padding: EdgeInsetsDirectional.only(end: 10.w),
        child: _boxedIcon(icon: widget.suffixIcon, onTap: widget.onSuffixIconPressed),
      );
    }
    if (widget.suffix != null) {
      return Padding(
        padding: EdgeInsetsDirectional.only(end: 10.w),
        child: _focusAwareSlot(builder: widget.suffix!),
      );
    }
    return null;
  }

  Widget _boxedIcon({required IconData? icon, VoidCallback? onTap}) {
    final Widget child = Icon(icon);
    return Column(
      mainAxisAlignment: .center,
      children: [
        if (onTap == null)
          child
        else
          InkWell(onTap: onTap, overlayColor: _transparentOverlay, child: child),
      ],
    );
  }

  Widget _focusAwareSlot({required Widget Function(bool hasFocus) builder}) {
    return ListenableBuilder(
      listenable: _focusNode,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: .center,
          children: [builder(_focusNode.hasFocus)],
        );
      },
    );
  }

  OutlineInputBorder _createBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? .circular(16.r),
      borderSide: BorderSide(color: color),
    );
  }
}

class _PhoneWithCountryCodeField extends StatelessWidget {
  const _PhoneWithCountryCodeField({
    required this.controller,
    required this.dialingCode,
    required this.onDialingCodeChanged,
    this.focusNode,
    this.textInputAction,
    this.validatorType,
    this.errorText,
    this.onFieldSubmitted,
    this.onChanged,
    this.suffix,
    this.backgroundColor,
    this.prefixIconColor,
    this.cursorColor,
    this.textStyle,
    this.hintTextStyle,
    this.labelTextStyle,
    this.borderColor,
    this.focusBorderColor,
    this.labelText,
    this.hintText,
    this.readOnly = false,
    this.autofocus = false,
    this.fieldName,
    this.fieldErrors,
  });

  final TextEditingController controller;
  final String dialingCode;
  final ValueChanged<String> onDialingCodeChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final BaseValidator? validatorType;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget Function(bool hasFocus)? suffix;
  final Color? backgroundColor;
  final Color? prefixIconColor;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? labelTextStyle;
  final Color? borderColor;
  final Color? focusBorderColor;
  final String? labelText;
  final String? hintText;
  final bool readOnly;
  final bool autofocus;
  final String? fieldName;
  final Map<String, List<String>>? fieldErrors;

  @override
  Widget build(BuildContext context) {
    final PhoneValidationService phoneValidation = PhoneValidationService();
    final IsoCode isoCode = phoneValidation.isoCodeFromDialingCode(dialingCode);

    return AppTextFormField.phoneTextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      errorText: errorText,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      suffix: suffix,
      backgroundColor: backgroundColor,
      prefixIconColor: prefixIconColor,
      cursorColor: cursorColor,
      textStyle: textStyle,
      hintTextStyle: hintTextStyle,
      labelTextStyle: labelTextStyle,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      labelText: labelText,
      hintText: hintText,
      readOnly: readOnly,
      autofocus: autofocus,
      fieldName: fieldName,
      fieldErrors: fieldErrors,
      validatorType:
          validatorType ??
          FieldValidator.phone(
            phoneCode: dialingCode,
            phoneValidationHandler: (String phone, String code) {
              return phoneValidation
                  .validatePhoneNumber(phoneNumber: phone, phoneCode: code)
                  .isValidPhone;
            },
          ),
      prefix: (bool _) => _DialingCodeButton(
        isoCode: isoCode,
        enabled: !readOnly,
        textStyle: textStyle,
        onTap: readOnly ? null : () => _pickCountry(context, phoneValidation),
      ),
    );
  }

  Future<void> _pickCountry(
    BuildContext context,
    PhoneValidationService phoneValidation,
  ) async {
    const CountrySelectorNavigator navigator = .draggableBottomSheet(
      favorites: <IsoCode>[.SA],
    );
    final IsoCode? selected = await navigator.show(context);
    if (selected == null || !context.mounted) {
      return;
    }
    onDialingCodeChanged(phoneValidation.formatDialingCode(selected));
  }
}

class _DialingCodeButton extends StatelessWidget {
  const _DialingCodeButton({
    required this.isoCode,
    required this.enabled,
    required this.onTap,
    this.textStyle,
  });

  final IsoCode isoCode;
  final bool enabled;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: CountryButton(
        isoCode: isoCode,
        onTap: onTap,
        enabled: enabled,
        flagSize: 20.r,
        textStyle: textStyle ?? TextStyles.of(size: 14, weight: .w500),
        dropdownIconColor: context.colors.hint,
      ),
    );
  }
}

final class _PasswordMatchValidator extends BaseValidator {
  final TextEditingController confirmController;

  _PasswordMatchValidator(this.confirmController);

  @override
  String? validate(String? value) {
    return PasswordValidator(password: confirmController.text).validate(value);
  }
}
