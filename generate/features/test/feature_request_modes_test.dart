import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../utils/enums.dart';
import '../models/feature.dart';
import '../models/names.dart';
import '../models/request.dart';
import '../models/settings.dart';

void main() {
  group('Feature vs request modes', () {
    test(
      'Generate request + Modification feature: only mode 1 is writable',
      () {
        final Feature feature = _feature(<Request>[
          _request(name: 'get_student_profile', mode: 0),
          _request(name: 'update_student_profile', mode: 0),
          _request(name: 'change_student_password', mode: 1),
        ]);

        expect(feature.modeType, ModeType.modify);
        expect(feature.generateRequests.map(_name), <String>[
          'change_student_password',
        ]);
        expect(feature.modifyRequests, isEmpty);
        expect(feature.writableRequests.map(_name), <String>[
          'change_student_password',
        ]);
        expect(feature.deleteRequests, isEmpty);
        expect(feature.activeRequests.map(_name), <String>[
          'get_student_profile',
          'update_student_profile',
          'change_student_password',
        ]);
        expect(feature.hasModifyWork, isTrue);
      },
    );

    test('Delete request + Modification feature: only mode 3 is deleted', () {
      final Feature feature = _feature(<Request>[
        _request(name: 'get_student_profile', mode: 0),
        _request(name: 'update_student_profile', mode: 0),
        _request(name: 'get_company_profile', mode: 3),
      ]);

      expect(feature.modeType, ModeType.modify);
      expect(feature.writableRequests, isEmpty);
      expect(feature.deleteRequests.map(_name), <String>[
        'get_company_profile',
      ]);
      expect(feature.activeRequests.map(_name), <String>[
        'get_student_profile',
        'update_student_profile',
      ]);
      expect(feature.hasModifyWork, isTrue);
    });

    test(
      'Modification request + Modification feature: only mode 2 is writable',
      () {
        final Feature feature = _feature(<Request>[
          _request(name: 'get_student_profile', mode: 0),
          _request(name: 'update_student_profile', mode: 2),
          _request(name: 'change_student_password', mode: 0),
        ]);

        expect(feature.modeType, ModeType.modify);
        expect(feature.generateRequests, isEmpty);
        expect(feature.modifyRequests.map(_name), <String>[
          'update_student_profile',
        ]);
        expect(feature.writableRequests.map(_name), <String>[
          'update_student_profile',
        ]);
        expect(feature.deleteRequests, isEmpty);
        expect(feature.activeRequests.map(_name), <String>[
          'get_student_profile',
          'update_student_profile',
          'change_student_password',
        ]);
        expect(feature.hasModifyWork, isTrue);
      },
    );

    test('protected requests are never writable or deleted', () {
      final Feature feature = _feature(<Request>[
        _request(name: 'get_student_profile', mode: 0),
        _request(name: 'update_student_profile', mode: 0),
      ]);

      expect(feature.writableRequests, isEmpty);
      expect(feature.deleteRequests, isEmpty);
      expect(feature.hasModifyWork, isFalse);
      expect(feature.activeRequests, hasLength(2));
    });

    test('one modify run can mix generate, modify, and delete requests', () {
      final Feature feature = _feature(<Request>[
        _request(name: 'keep_me', mode: 0),
        _request(name: 'add_me', mode: 1),
        _request(name: 'update_me', mode: 2),
        _request(name: 'remove_me', mode: 3),
      ]);

      expect(feature.generateRequests.map(_name), <String>['add_me']);
      expect(feature.modifyRequests.map(_name), <String>['update_me']);
      expect(feature.writableRequests.map(_name), <String>[
        'add_me',
        'update_me',
      ]);
      expect(feature.deleteRequests.map(_name), <String>['remove_me']);
      expect(feature.activeRequests.map(_name), <String>[
        'keep_me',
        'add_me',
        'update_me',
      ]);
    });
  });
}

Feature _feature(List<Request> requests) {
  return Feature(
    names: Names.fromString('profile'),
    settings: const Settings(mode: 2),
    modeType: ModeType.modify,
    requests: requests,
  );
}

Request _request({required String name, required int mode}) {
  return Request.init(
    file: File('generate/requests/profile/${name}_request.json'),
    featureProjectPath: 'lib/features/profile',
    json: <String, dynamic>{
      'name': name,
      'endpoint': '/x',
      'type': 'GET',
      'mode': mode,
      'response': <String, dynamic>{
        'status': true,
        'message': '',
        'data': null,
      },
    },
  );
}

String _name(Request request) => request.names.snakeCase;
