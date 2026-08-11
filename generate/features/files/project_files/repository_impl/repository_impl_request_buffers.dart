import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class RepositoryImplRequestBuffers extends BaseRequestBuffers{
  
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import '../../domain/entities/${requestNameSnakeCase}_response.dart';");
    if(hasParams){
      buffer.write("import '../../domain/usecases/${requestNameSnakeCase}_usecase.dart';");
    }else{
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
    buffer.writeln('  @override');
    String params = 'NoParams';
    if(hasParams){
      params = '${request.names.classCase}Params';
    }
    buffer.writeln('  Future<Either<Failure, ${request.names.classCase}Response>> ${request.names.camelCase}({required $params params}) async {');
    // buffer.writeln('    if (await networkInfo.isConnected) {');
    buffer.writeln('    try {');
    if(hasParams){
      buffer.writeln('      final ${request.names.classCase}Response response = await remote.${request.names.camelCase}(params: params);');
    }else {
      buffer.writeln('      final ${request.names.classCase}Response response = await remote.${request.names.camelCase}();');
    }
    buffer.writeln('        return Right<Failure, ${request.names.classCase}Response>(response);');
    buffer.writeln('      } on AppException catch (error) {');
    buffer.writeln("        Log.e('[${request.names.camelCase}] [\${error.runtimeType.toString()}] ---- \${error.message}');");
    buffer.writeln('        return Left<Failure, ${request.names.classCase}Response>(error.toFailure());');
    buffer.writeln('      }');
    // buffer.writeln('    } else {');
    // buffer.writeln('      return Left(NetworkFailure(message: Strings.noInternetConnection));');
    // buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    return buffer;
  }
}