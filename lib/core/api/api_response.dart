/// Single place to decide whether a JSON body is a successful API payload.
///
/// Change this if the backend switches from `status: 'success'` to
/// `success: true` (or needs both).
abstract final class ApiResponse {
  static bool isSuccess(dynamic data) {
    if (data is! Map) {
      return false;
    }
    final Object? status = data['status'];
    if (status == 'success' || status == true) {
      return true;
    }
    return data['success'] == true;
  }

  static String messageOf(dynamic data) {
    if (data is! Map) {
      return '';
    }
    final Object? message = data['message'];
    if (message is String) {
      return message;
    }
    return '';
  }
}
