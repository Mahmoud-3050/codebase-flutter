import '../../../../utils/enums.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class CubitRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln("import 'package:equatable/equatable.dart';");
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln();
    buffer.writeln("import '../../../../../core/error/failures.dart';");
    buffer.writeln("import '../../../../../config/language/strings.dart';");
    buffer.writeln(
      "import '../../../../../core/presentation/cubit_request_canceller.dart';",
    );
    buffer.writeln("import '../../../../../core/usecases/usecase.dart';");
    buffer.writeln(
      "import '../../../domain/usecases/${requestNameSnakeCase}_usecase.dart';",
    );
    buffer.writeln(
      "import '../../../domain/entities/${requestNameSnakeCase}_response.dart';",
    );
    return buffer;
  }

  StringBuffer generatePaginationImports({
    required String requestNameSnakeCase,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:dio/dio.dart';");
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln();
    buffer.writeln("import '../../../../../core/error/failures.dart';");
    buffer.writeln(
      "import '../../../../../shared/pagination/pagination_cubit.dart';",
    );
    buffer.writeln(
      "import '../../../../../shared/pagination/pagination_entity.dart';",
    );
    buffer.writeln(
      "import '../../../domain/usecases/${requestNameSnakeCase}_usecase.dart';",
    );
    buffer.writeln(
      "import '../../../domain/entities/${requestNameSnakeCase}_response.dart';",
    );
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    if (request.isPaginatedList) {
      return _generatePaginationBody(request: request);
    }
    return _generateStandardBody(request: request);
  }

  StringBuffer _generatePaginationBody({required Request request}) {
    final StringBuffer buffer = StringBuffer();
    final String responseClassName = request.names.classCase;
    final String responseNameCamelCase = request.names.camelCase;
    final String itemType = request.paginationItemTypeName;
    final Map<String, dynamic> extraFilters = request.extraFilterParams;

    buffer.writeln(
      'class ${responseClassName}Cubit extends PaginationCubit<$itemType> {',
    );
    buffer.writeln(
      '  final ${responseClassName}UseCase ${responseNameCamelCase}UseCase;',
    );
    buffer.writeln();
    extraFilters.forEach((String key, dynamic value) {
      final Names keyNames = Names.fromString(key);
      buffer.writeln(
        '  ${request.dartTypeForParam(key, value)}? ${keyNames.camelCase};',
      );
    });
    if (extraFilters.isNotEmpty) {
      buffer.writeln();
    }
    buffer.writeln(
      '  ${responseClassName}Cubit(this.${responseNameCamelCase}UseCase);',
    );
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<Either<Failure, PaginationPage<$itemType>>> fetchPage({',
    );
    buffer.writeln('    required int page,');
    buffer.writeln('    required int perPage,');
    buffer.writeln('    required CancelToken cancellation,');
    buffer.writeln('  }) {');
    buffer.writeln(
      '    return ${responseNameCamelCase}UseCase(${responseClassName}Params(',
    );
    buffer.writeln('      page: page,');
    buffer.writeln('      perPage: perPage,');
    extraFilters.forEach((String key, dynamic value) {
      final Names keyNames = Names.fromString(key);
      buffer.writeln('      ${keyNames.camelCase}: ${keyNames.camelCase},');
    });
    buffer.writeln('      cancellation: cancellation,');
    buffer.writeln('    )).map(');
    buffer.writeln(
      '      (${responseClassName}Response response) => PaginationPage<$itemType>(',
    );
    buffer.writeln('        items: response.data,');
    buffer.writeln('        meta: response.pagination,');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer;
  }

  StringBuffer _generateStandardBody({required Request request}) {
    final StringBuffer buffer = StringBuffer();
    final String responseClassName = request.names.classCase;
    final String responseNameCamelCase = request.names.camelCase;
    final bool hasParams = request.hasRequestParams;
    final DartType? dataType = request.dartType;
    buffer.writeln(
      'class ${responseClassName}Cubit extends Cubit<${responseClassName}State> with CubitRequestCanceller<${responseClassName}State> {',
    );
    buffer.writeln(
      '  final ${responseClassName}UseCase ${responseNameCamelCase}UseCase;',
    );
    buffer.writeln();
    buffer.writeln(
      '  ${responseClassName}Cubit(this.${responseNameCamelCase}UseCase) : super(const ${responseClassName}InitialState());',
    );
    buffer.writeln();
    if (hasParams) {
      buffer.writeln('  Future<void> f$responseClassName({');
      request.effectiveParams.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln(
          '   required ${request.dartTypeForParam(key, value)} ${keyNames.camelCase},',
        );
      });
      buffer.writeln('  }) async {');
    } else {
      buffer.writeln('  Future<void> f$responseClassName() async {');
    }

    buffer.writeln('    emit(const ${responseClassName}LoadingState());');
    if (hasParams) {
      buffer.writeln(
        '    final Either<Failure, ${responseClassName}Response> eitherResult = await ${responseNameCamelCase}UseCase(${responseClassName}Params(',
      );
      request.effectiveParams.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln('      ${keyNames.camelCase}: ${keyNames.camelCase},');
      });
      buffer.writeln('      cancellation: nextRequestCancelToken(),');
      buffer.writeln('    ));');
    } else {
      buffer.writeln(
        '    final Either<Failure, ${responseClassName}Response> eitherResult = await ${responseNameCamelCase}UseCase(NoParams(cancellation: nextRequestCancelToken()));',
      );
    }
    buffer.writeln('    eitherResult.fold((Failure failure) {');
    buffer.writeln('      if (shouldIgnoreFailure(failure)) {');
    buffer.writeln('        return;');
    buffer.writeln('      }');
    buffer.writeln('      emit(${responseClassName}ErrorState(');
    buffer.writeln(
      '        message: failure.message ?? Strings.pleaseTryAgainLater,',
    );
    buffer.writeln('        fieldErrors: failure.fieldErrors,');
    buffer.writeln('      ));');
    buffer.writeln('    }, (${responseClassName}Response response) {');
    buffer.writeln('      if (isClosed) {');
    buffer.writeln('        return;');
    buffer.writeln('      }');
    if (dataType != null) {
      buffer.writeln(
        '      emit(${responseClassName}SuccessState(data: response.data));',
      );
    } else {
      buffer.writeln('      emit(const ${responseClassName}SuccessState());');
    }

    buffer.writeln('    });');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer;
  }
}
