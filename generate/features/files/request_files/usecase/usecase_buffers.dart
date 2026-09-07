import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class UseCaseRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('import \'package:either/either.dart\';');
    buffer.writeln();
    buffer.writeln('import \'../../../../core/error/failures.dart\';');
    buffer.writeln("import '../../../../core/usecases/usecase.dart';");
    buffer.writeln(
      'import \'../entities/${requestNameSnakeCase}_response.dart\';',
    );
    buffer.writeln(
      'import \'../repositories/${featureNameSnakeCase}_repo.dart\';',
    );
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    bool hasParams = request.hasRequestParams;

    ///-> UseCase Model
    buffer.writeln(
      _generateUseCaseModel(
        featureClassName: featureNames.classCase,
        responseClassName: responseClassName,
        responseNameCamelCase: request.names.camelCase,
        hasParams: hasParams,
      ).toString(),
    );

    ///-> Params Model
    if (hasParams) {
      buffer.writeln(
        _generateParamsModel(
          responseClassName: responseClassName,
          params: request.effectiveParams,
          paramsTerms: request.endpoint.terms,
          request: request,
        ).toString(),
      );
    }

    return buffer;
  }

  StringBuffer _generateUseCaseModel({
    required String featureClassName,
    required String responseClassName,
    required String responseNameCamelCase,
    required bool hasParams,
  }) {
    final StringBuffer buffer = StringBuffer();
    if (hasParams) {
      buffer.writeln(
        'class ${responseClassName}UseCase extends UseCase<${responseClassName}Response, ${responseClassName}Params> {',
      );
    } else {
      buffer.writeln(
        'class ${responseClassName}UseCase extends UseCase<${responseClassName}Response, Params> {',
      );
    }

    buffer.writeln('  final ${featureClassName}Repository repository;');
    buffer.writeln();
    buffer.writeln(
      '  ${responseClassName}UseCase({required this.repository});',
    );
    buffer.writeln();
    buffer.writeln('  @override');
    if (hasParams) {
      buffer.writeln(
        '  Future<Either<Failure, ${responseClassName}Response>> call(${responseClassName}Params params) async {',
      );
    } else {
      buffer.writeln(
        '  Future<Either<Failure, ${responseClassName}Response>> call(Params params) async {',
      );
    }
    buffer.writeln(
      '    return await repository.$responseNameCamelCase(params: params);',
    );
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
    return buffer;
  }

  StringBuffer _generateParamsModel({
    required List<String> paramsTerms,
    required String responseClassName,
    required Map<String, dynamic> params,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('class ${responseClassName}Params extends Params {');

    final Map<String, String> attributes = <String, String>{};
    params.forEach((String key, dynamic value) {
      final Names keyNames = Names.fromString(key);
      if (request.isPagingParam(key)) {
        buffer.writeln('  final int ${keyNames.camelCase};');
        attributes.putIfAbsent(keyNames.camelCase, () => 'int');
        return;
      }
      final String valueInStr = request.dartTypeForParam(key, value);
      buffer.writeln('  final $valueInStr? ${keyNames.camelCase};');
      attributes.putIfAbsent(keyNames.camelCase, () => valueInStr);
    });
    buffer.writeln('  @override');
    buffer.writeln('  final Object? cancellation;');
    buffer.writeln();

    buffer.writeln('  const ${responseClassName}Params({');
    attributes.forEach((String key, String value) {
      buffer.writeln('    required this.$key,');
    });
    buffer.writeln('    this.cancellation,');
    buffer.writeln('  });\n');

    buffer.writeln('  @override');
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    final Map<String, dynamic> map = {};');
    params.forEach((String key, dynamic value) {
      if (request.isPagingParam(key)) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln(
          "      map['${keyNames.snakeCase}'] = ${keyNames.camelCase};",
        );
        return;
      }
      if (request.isFileParam(key)) {
        return;
      }
      bool isParam = false;
      for (final String term in paramsTerms) {
        if (Names.fromString(key).camelCase ==
            term.split('.').last.replaceAll('}', '')) {
          isParam = true;
          break;
        }
      }
      if (!isParam) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln('    if (${keyNames.camelCase} != null) {');
        buffer.writeln(
          "      map['${keyNames.snakeCase}'] = ${keyNames.camelCase};",
        );
        buffer.writeln('    }');
      }
    });
    buffer.writeln('    return map;');
    buffer.writeln('  }\n');

    if (request.hasFileParams) {
      buffer.writeln('  FormData toFormData() {');
      buffer.writeln('    final FormData formData = FormData();');
      params.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        if (request.isFileParam(key)) {
          buffer.writeln('    if (${keyNames.camelCase} != null) {');
          buffer.writeln('      formData.files.add(');
          buffer.writeln('        MapEntry(');
          buffer.writeln("          '${keyNames.snakeCase}',");
          buffer.writeln(
            '          MultipartFile.fromFileSync(${keyNames.camelCase}!.path, filename: ${keyNames.camelCase}!.path.split(Platform.pathSeparator).last),',
          );
          buffer.writeln('        ),');
          buffer.writeln('      );');
          buffer.writeln('    }');
        } else {
          buffer.writeln('    if (${keyNames.camelCase} != null) {');
          buffer.writeln(
            "      formData.fields.add(MapEntry('${keyNames.snakeCase}', ${keyNames.camelCase}.toString()));",
          );
          buffer.writeln('    }');
        }
      });
      buffer.writeln('    return formData;');
      buffer.writeln('  }\n');
    }

    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    attributes.forEach((String key, String value) {
      buffer.writeln('    $key,');
    });
    buffer.writeln('  ];\n');

    buffer.writeln('}\n');

    return buffer;
  }
}
