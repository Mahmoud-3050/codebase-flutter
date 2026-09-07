import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../files/project_files/datasource/datasource_request_buffers.dart';
import '../files/request_files/entity/entity_buffers.dart';
import '../files/request_files/model/model_buffers.dart';
import '../models/names.dart';
import '../models/request.dart';

void main() {
  group('Request form errors', () {
    test(
      'entity skips envelope errors instead of generating a nested class',
      () {
        final Request request = _requestWithErrors();
        final String body = EntityRequestBuffers()
            .generateBody(
              featureNames: Names.fromString('auth'),
              request: request,
            )
            .toString();

        expect(body, isNot(contains('class Errors')));
        expect(body, isNot(contains('final Errors errors;')));
        expect(body, contains('final String status;'));
        expect(body, contains('final Student data;'));
      },
    );

    test('model does not parse envelope errors', () {
      final Request request = _requestWithErrors();
      final String body = ModelRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('auth'),
            request: request,
          )
          .toString();

      expect(body, isNot(contains('class Errors')));
      expect(body, isNot(contains('ErrorsModel')));
      expect(body, isNot(contains("json['errors']")));
      expect(body, contains("data: StudentModel.fromJson(json['data']),"));
    });

    test('datasource throws ApiResponse.exceptionOf on failure', () {
      final Request request = _requestWithErrors();
      final String body = DatasourceRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('auth'),
            request: request,
          )
          .toString();

      expect(body, contains('throw ApiResponse.exceptionOf(response);'));
      expect(
        body,
        isNot(contains('throw ServerException(message: ApiResponse.messageOf')),
      );
    });
  });
}

Request _requestWithErrors() {
  return Request.init(
    file: File('generate/requests/temp/login_request.json'),
    featureProjectPath: 'lib/features/auth',
    json: <String, dynamic>{
      'name': 'login',
      'model_class': 'Student',
      'endpoint': '/common/login',
      'type': 'POST',
      'params': <String, dynamic>{'login': '', 'password': ''},
      'response': <String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{'id': 1, 'email': 'a@b.c'},
        'message': 'ok',
        'errors': <String, dynamic>{
          'email': <String>['The email has already been taken.'],
          'password': <String>['The password field is required.'],
        },
      },
    },
  );
}
