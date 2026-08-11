import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class UseCaseRequestBuffers extends BaseRequestBuffers{
  
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    if(hasParams){
      buffer.writeln('import \'package:equatable/equatable.dart\';');
    }
    buffer.writeln('import \'package:either/either.dart\';');
    buffer.writeln();
    buffer.writeln('import \'../../../../core/error/failures.dart\';');
    buffer.writeln('import \'../../../../core/usecases/usecase.dart\';');
    buffer.writeln('import \'../entities/${requestNameSnakeCase}_response.dart\';');
    buffer.writeln('import \'../repositories/${featureNameSnakeCase}_repo.dart\';');
    return buffer;
  }
  
  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    bool hasParams = request.params != null;


    ///-> UseCase Model
    buffer.writeln(_generateUseCaseModel(
      featureClassName: featureNames.classCase,
      responseClassName: responseClassName,
      responseNameCamelCase: request.names.camelCase,
      hasParams: hasParams,
    ).toString());

    ///-> Params Model
    if(hasParams){
      buffer.writeln(_generateParamsModel(
        responseClassName: responseClassName,
        params: request.params?? <String, dynamic>{},
        paramsTerms: request.endpoint.terms,
      ).toString());
    }


    return buffer;
  }



  StringBuffer _generateUseCaseModel({
    required String featureClassName,
    required String responseClassName,
    required String responseNameCamelCase,
    required bool hasParams,
  }){
    final StringBuffer buffer = StringBuffer();
    if (hasParams) {
      buffer.writeln('class ${responseClassName}UseCase extends UseCase<${responseClassName}Response, ${responseClassName}Params> {');
    } else {
      buffer.writeln('class ${responseClassName}UseCase extends UseCase<${responseClassName}Response, NoParams> {');
    }

    buffer.writeln('  final ${featureClassName}Repository repository;');
    buffer.writeln();
    buffer.writeln('  ${responseClassName}UseCase({required this.repository});');
    buffer.writeln();
    buffer.writeln('  @override');
    if (hasParams) {
      buffer.writeln(
          '  Future<Either<Failure, ${responseClassName}Response>> call(${responseClassName}Params params) async {');
    } else {
      buffer.writeln(
          '  Future<Either<Failure, ${responseClassName}Response>> call(NoParams params) async {');
    }
    buffer.writeln('    return await repository.$responseNameCamelCase(params: params);');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
    return buffer;
  }

  StringBuffer _generateParamsModel({
    required List<String> paramsTerms,
    required String responseClassName,
    required Map<String, dynamic> params,
  }){
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('class ${responseClassName}Params extends Equatable {');

    ///Attributes
    Map<String, String> attributes = <String, String>{}; // example: key = id, value = int
    params.forEach((String key, dynamic value) {
      final Names keyNames = Names.fromString(key);
      String valueInStr = getDartType(value);
      buffer.writeln('  final $valueInStr? ${keyNames.camelCase};');
      attributes.putIfAbsent(keyNames.camelCase, () => valueInStr);
    });
    buffer.writeln();

    ///Named Argument Constructor
    buffer.writeln('  const ${responseClassName}Params({');
    attributes.forEach((String key, String value) {
      buffer.writeln('    required this.$key,');
    });
    buffer.writeln('  });\n');

    ///ToJson
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    final Map<String, dynamic> map = {};');
    attributes.forEach((String key, String value){
      bool isParam = false;
      for(String term in paramsTerms){
        // print('line[123]loop: key: $key, term: $term');
        if(key == term.split('.').last.replaceAll('}', '')){
          isParam = true;
          break;
        }
      }
      if(!isParam){
        final Names keyNames = Names.fromString(key);
        buffer.writeln('    if ($key != null) {');
        buffer.writeln("      map['${keyNames.snakeCase}'] = $key;");
        buffer.writeln('    }');
      }
    });
    buffer.writeln('    return map;');
    buffer.writeln('  }\n');

    ///Equatable props
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    attributes.forEach((String key, String value) {
      buffer.writeln('    $key,');
    });
    buffer.writeln('  ];\n');

    ///End of Params Class
    buffer.writeln('}\n');

    return buffer;
  }

}