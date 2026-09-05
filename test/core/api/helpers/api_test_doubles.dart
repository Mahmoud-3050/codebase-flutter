import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:codebase/core/services/local_storage/interfaces/local_storage_interface.dart';

final class FakeAccessTokenStorage implements LocalStorageInterface {
  String? token;
  Object? readError;
  int _reads = 0;
  int? throwOnRead;

  @override
  Future<String?> read({String? key}) async {
    _reads++;
    if (readError != null && (throwOnRead == null || _reads >= throwOnRead!)) {
      throw readError!;
    }
    return token;
  }

  bool saveSucceeds = true;

  @override
  Future<bool> save({required String value, String? key}) async {
    if (!saveSucceeds) {
      return false;
    }
    token = value;
    return true;
  }

  @override
  Future<bool> remove({String? key}) async {
    token = null;
    return true;
  }
}

final class FakeUserTypeStorage implements LocalStorageInterface {
  String? value;

  @override
  Future<String?> read({String? key}) async => value;

  @override
  Future<bool> save({required String value, String? key}) async {
    this.value = value;
    return true;
  }

  @override
  Future<bool> remove({String? key}) async {
    value = null;
    return true;
  }
}

final class ScriptedAdapter implements HttpClientAdapter {
  FutureOr<ResponseBody> Function(RequestOptions options)? handler;
  int calls = 0;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    lastData = options.data;
    final FutureOr<ResponseBody> Function(RequestOptions options)? current =
        handler;
    if (current == null) {
      throw StateError('No adapter handler for ${options.path}');
    }
    return current(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int statusCode, Map<String, dynamic> data) {
  return .fromString(
    jsonEncode(data),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

ResponseBody redirectBody(int statusCode, String location) {
  return ResponseBody.fromString(
    '',
    statusCode,
    headers: <String, List<String>>{
      'location': <String>[location],
    },
  );
}

ResponseBody emptyBody(int statusCode) {
  return ResponseBody.fromString(
    '',
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}
