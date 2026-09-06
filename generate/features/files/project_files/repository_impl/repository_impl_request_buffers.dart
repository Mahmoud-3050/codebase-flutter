import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class RepositoryImplRequestBuffers extends BaseRequestBuffers {
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
    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<Either<Failure, ${request.names.classCase}Response>> ${request.names.camelCase}({required Params params}) =>',
    );
    buffer.writeln('      guard(');
    buffer.writeln(
      '        () => remote.${request.names.camelCase}(params: params),',
    );
    buffer.writeln("        '${request.names.camelCase}',");
    buffer.writeln('      );');
    buffer.writeln();
    return buffer;
  }
}
