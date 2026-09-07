import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../utils/enums.dart';
import '../files/request_files/cubit/cubit_buffers.dart';
import '../files/request_files/entity/entity_buffers.dart';
import '../files/request_files/model/model_buffers.dart';
import '../files/request_files/usecase/usecase_buffers.dart';
import '../models/names.dart';
import '../models/request.dart';

void main() {
  group('Request pagination', () {
    test('detects pagination on the response and injects page params', () {
      final Request request = _paginatedRequest();

      expect(request.hasPagination, isTrue);
      expect(request.isPaginatedList, isTrue);
      expect(request.hasRequestParams, isTrue);
      expect(request.endpoint.hasQueryParams, isTrue);
      expect(request.effectiveParams, containsPair('page', 1));
      expect(request.effectiveParams, containsPair('per_page', 10));
      expect(request.effectiveParams, containsPair('search', 'eng'));
      expect(request.paginationItemTypeName, 'Job');
    });

    test('does not treat a non-list payload as a paginated list cubit', () {
      final Request request = Request.init(
        file: File('generate/requests/temp/x_request.json'),
        featureProjectPath: 'lib/features/temp',
        json: <String, dynamic>{
          'name': 'getJob',
          'model_class': 'Job',
          'endpoint': '/jobs/1',
          'type': 'GET',
          'response': <String, dynamic>{
            'status': 'success',
            'data': <String, dynamic>{'id': 1},
            'pagination': <String, dynamic>{
              'total': 1,
              'count': 1,
              'per_page': 10,
              'current_page': 1,
              'total_pages': 1,
            },
            'message': 'ok',
          },
        },
      );

      expect(request.hasPagination, isTrue);
      expect(request.isPaginatedList, isFalse);
      expect(request.dartType, DartType.model);
    });

    test('entity uses PaginationMeta instead of a nested pagination class', () {
      final Request request = _paginatedRequest();
      final String body = EntityRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('jobs'),
            request: request,
          )
          .toString();

      expect(body, contains('final PaginationMeta pagination;'));
      expect(body, isNot(contains('class Pagination ')));
    });

    test('model parses pagination with PaginationMetaModel', () {
      final Request request = _paginatedRequest();
      final String body = ModelRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('jobs'),
            request: request,
          )
          .toString();

      expect(body, contains('required super.pagination,'));
      expect(body, contains('PaginationMetaModel.fromJson'));
    });

    test('usecase params include page and perPage', () {
      final Request request = _paginatedRequest();
      final String body = UseCaseRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('jobs'),
            request: request,
          )
          .toString();

      expect(
        body,
        contains(
          'class GetJobsUseCase extends UseCase<GetJobsResponse, GetJobsParams>',
        ),
      );
      expect(body, contains('final int page;'));
      expect(body, contains('final int perPage;'));
      expect(body, contains("map['page'] = page;"));
      expect(body, contains("map['per_page'] = perPage;"));
    });

    test('cubit extends PaginationCubit and implements fetchPage', () {
      final Request request = _paginatedRequest();
      final String body = CubitRequestBuffers()
          .generateBody(
            featureNames: Names.fromString('jobs'),
            request: request,
          )
          .toString();

      expect(body, contains('class GetJobsCubit extends PaginationCubit<Job>'));
      expect(
        body,
        contains('Future<Either<Failure, PaginationPage<Job>>> fetchPage'),
      );
      expect(body, contains('meta: response.pagination,'));
      expect(body, contains('items: response.data,'));
      expect(body, contains('String? search;'));
      expect(body, isNot(contains('sealed class GetJobsState')));
    });
  });
}

Request _paginatedRequest() {
  return Request.init(
    file: File('generate/requests/temp/get_jobs_request.json'),
    featureProjectPath: 'lib/features/jobs',
    json: <String, dynamic>{
      'name': 'getJobs',
      'model_class': 'Job',
      'endpoint': '/jobs',
      'type': 'GET',
      'params': <String, dynamic>{'search': 'eng'},
      'response': <String, dynamic>{
        'status': 'success',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'title': 'Engineer'},
        ],
        'pagination': <String, dynamic>{
          'total': 100,
          'count': 10,
          'per_page': 10,
          'current_page': 1,
          'total_pages': 10,
        },
        'message': 'ok',
      },
    },
  );
}
