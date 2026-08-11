import '../../../../utils/enums.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';


class CubitStatesRequestBuffers extends BaseRequestBuffers{
  
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("part of '${requestNameSnakeCase}_cubit.dart';");
    return buffer;
  }
  
  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    DartType? dataType = request.dartType;
    String modelClassName = request.modelClassNames.classCase;

    buffer.writeln('sealed class ${responseClassName}State extends Equatable {');
    buffer.writeln('  const ${responseClassName}State();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[];');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('final class ${responseClassName}InitialState extends ${responseClassName}State {');
    buffer.writeln('  const ${responseClassName}InitialState();');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('final class ${responseClassName}LoadingState extends ${responseClassName}State {');
    buffer.writeln('  const ${responseClassName}LoadingState();');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('final class ${responseClassName}SuccessState extends ${responseClassName}State {');
    if(dataType != null){
      buffer.writeln('  final ${dataType.typeName(modelClass: modelClassName)}${!dataType.isList? '?' : ''} data;');
      buffer.writeln();
      buffer.writeln('  const ${responseClassName}SuccessState({required this.data});');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  List<Object?> get props => <Object?>[data];');
    }else{
      buffer.writeln('  const ${responseClassName}SuccessState();');
    }
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('final class ${responseClassName}ErrorState extends ${responseClassName}State {');
    buffer.writeln('  final String message;');
    buffer.writeln();
    buffer.writeln('  const ${responseClassName}ErrorState({required this.message});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[message];');
    buffer.writeln('}');

    return buffer;
  }

}