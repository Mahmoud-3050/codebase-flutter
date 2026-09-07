import '../../../../utils/enums.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class CubitStatesRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    return StringBuffer();
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    final String responseClassName = request.names.classCase;
    final DartType? dataType = request.dartType;
    final String modelClassName = request.modelClassNames.classCase;

    buffer.writeln(
      'sealed class ${responseClassName}State extends Equatable {',
    );
    buffer.writeln('  const ${responseClassName}State();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[];');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'final class ${responseClassName}InitialState extends ${responseClassName}State {',
    );
    buffer.writeln('  const ${responseClassName}InitialState();');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'final class ${responseClassName}LoadingState extends ${responseClassName}State {',
    );
    buffer.writeln('  const ${responseClassName}LoadingState();');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'final class ${responseClassName}SuccessState extends ${responseClassName}State {',
    );
    if (dataType != null) {
      buffer.writeln(
        '  final ${dataType.typeName(modelClass: modelClassName)}${!dataType.isList ? '?' : ''} data;',
      );
      buffer.writeln();
      buffer.writeln(
        '  const ${responseClassName}SuccessState({required this.data});',
      );
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  List<Object?> get props => <Object?>[data];');
    } else {
      buffer.writeln('  const ${responseClassName}SuccessState();');
    }
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'final class ${responseClassName}ErrorState extends ${responseClassName}State {',
    );
    buffer.writeln('  final String message;');
    buffer.writeln('  final Map<String, List<String>> fieldErrors;');
    buffer.writeln();
    buffer.writeln('  const ${responseClassName}ErrorState({');
    buffer.writeln('    required this.message,');
    buffer.writeln('    this.fieldErrors = const <String, List<String>>{},');
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  List<Object?> get props => <Object?>[message, fieldErrors];',
    );
    buffer.writeln('}');

    return buffer;
  }
}
