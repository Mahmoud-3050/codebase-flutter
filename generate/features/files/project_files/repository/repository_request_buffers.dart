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
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      '  Future<Either<Failure, ${request.names.classCase}Response>> ${request.names.camelCase}({',
    );
    buffer.writeln('    required Params params,');
    buffer.writeln('  });');
    buffer.writeln();
    return buffer;
  }
}
