import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class RepositoryRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      "import '../../domain/entities/${requestNameSnakeCase}_response.dart';",
    );
    if (hasParams) {
      buffer.write(
        "import '../../domain/usecases/${requestNameSnakeCase}_usecase.dart';",
      );
    } else {
      buffer.write("import '../../../../core/usecases/usecase.dart';");
    }
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    bool hasParams = request.params != null;
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      '  Future<Either<Failure, ${request.names.classCase}Response>> ${request.names.camelCase}({',
    );
    if (hasParams) {
      buffer.writeln('    required ${request.names.classCase}Params params,');
    } else {
      buffer.writeln('    required NoParams params,');
    }
    buffer.writeln('  });');
    buffer.writeln();

    return buffer;
  }
}
