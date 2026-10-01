import '../../../core/presentation/api_call_state.dart';

/// Field errors for the current call, or an empty map when the call is not
/// an error. The empty map is a shared constant so a loading change does not
/// rebuild the form.
Map<String, List<String>> authFieldErrors<T>(ApiCallState<T> state) {
  return switch (state) {
    ApiCallError(:final fieldErrors) => fieldErrors,
    _ => const <String, List<String>>{},
  };
}
