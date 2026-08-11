import '../../../../utils/enums.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class DatasourceRequestBuffers extends BaseRequestBuffers{
  
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import '../models/${requestNameSnakeCase}_model.dart';");
    if(hasParams){
      buffer.writeln("import '../../domain/usecases/${requestNameSnakeCase}_usecase.dart';");
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

    /// Func
    if(hasParams){
      buffer.writeln('  Future<${request.names.classCase}Model> ${request.names.camelCase}({');
      buffer.writeln('    required ${request.names.classCase}Params params,');
      buffer.writeln('  });');
    }else {
      buffer.writeln('  Future<${request.names.classCase}Model> ${request.names.camelCase}();');
    }

    buffer.writeln();

    /// Separator
    buffer.writeln('***');


    /// Func impl
    buffer.writeln('  @override');
    if(hasParams){
      buffer.writeln('  Future<${request.names.classCase}Model> ${request.names.camelCase}({');
      buffer.writeln('    required ${request.names.classCase}Params params,');
      buffer.writeln('  }) async {');
    }else {
      buffer.writeln('  Future<${request.names.classCase}Model> ${request.names.camelCase}() async {');
    }

    buffer.writeln('    try {');
    if(request.endpoint.hasParams){
      buffer.writeln("      String ${request.names.camelCase}Endpoint = '${request.endpoint.endpoint}';");
    } else {
      buffer.writeln("      const String ${request.names.camelCase}Endpoint = '${request.endpoint.endpoint}';");
    }
    buffer.writeln('      final dynamic response = await dioConsumer.${request.type.name.toLowerCase()}(');
    buffer.writeln('        ${request.names.camelCase}Endpoint,');
    bool isBodyRequest = request.type == RequestType.post ||
        request.type == RequestType.put ||
        request.type == RequestType.patch;
    if (hasParams && isBodyRequest) {
      buffer.writeln('        body: params.toJson(),');
    }
    if (hasParams && request.type == RequestType.get && request.endpoint.hasQueryParams) {
      buffer.writeln('        queryParameters: params.toJson(),');
    }
    buffer.writeln('      );');
    buffer.writeln();
    buffer.writeln("      if(response['status'] == 'success'){");
    buffer.writeln('        return ${request.names.classCase}Model.fromJson(response);');
    buffer.writeln('      }');
    buffer.writeln("      throw ServerException(message: response['message']?? '');");
    buffer.writeln('    } catch (error) {');
    buffer.writeln('      rethrow;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
    return buffer;
  }
}