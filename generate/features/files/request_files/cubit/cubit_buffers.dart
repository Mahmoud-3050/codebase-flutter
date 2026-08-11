import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class CubitRequestBuffers extends BaseRequestBuffers{
  
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
    buffer.writeln("import '../../../../../core/utils/values/strings.dart';");
    if(!hasParams){
      buffer.writeln("import '../../../../../core/usecases/usecase.dart';");
    }
    buffer.writeln("import '../../../domain/usecases/${requestNameSnakeCase}_usecase.dart';");
    buffer.writeln("import '../../../domain/entities/${requestNameSnakeCase}_response.dart';");
    buffer.writeln();
    buffer.writeln("part '${requestNameSnakeCase}_states.dart';");
    return buffer;
  }
  
  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    String responseNameCamelCase = request.names.camelCase;
    bool hasParams = request.params != null;
    DartType? dataType = request.dartType;
    buffer.writeln('class ${responseClassName}Cubit extends Cubit<${responseClassName}State> {');
    buffer.writeln('  final ${responseClassName}UseCase ${responseNameCamelCase}UseCase;');
    buffer.writeln();
    buffer.writeln('  ${responseClassName}Cubit(this.${responseNameCamelCase}UseCase) : super(const ${responseClassName}InitialState());');
    buffer.writeln();
    // if(dataType != null){
    //   if(dataType.startsWith('List')){
    //     buffer.writeln('  $dataType<$modelClassName> data = <$modelClassName>[];');
    //   } else if(dataType.startsWith('Map')){
    //     buffer.writeln('  $modelClassName? data;');
    //   }else {
    //     buffer.writeln('  $dataType? data;');
    //   }
    // }


    buffer.writeln();
    if(hasParams){
      buffer.writeln('  Future<void> f$responseClassName({');
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln('   required ${getDartType(value)} ${keyNames.camelCase},');
      });
      buffer.writeln('  }) async {');
    }else{
      buffer.writeln('  Future<void> f$responseClassName() async {');
    }

    buffer.writeln('    emit(const ${responseClassName}LoadingState());');
    if(hasParams){
      buffer.writeln('    final Either<Failure, ${responseClassName}Response> eitherResult = await ${responseNameCamelCase}UseCase(${responseClassName}Params(');
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        buffer.writeln('      ${keyNames.camelCase}: ${keyNames.camelCase},');
      });
      buffer.writeln('    ));');
    }else {
      buffer.writeln('    final Either<Failure, ${responseClassName}Response> eitherResult = await ${responseNameCamelCase}UseCase(NoParams());');
    }
    buffer.writeln('    eitherResult.fold((Failure failure) {');
    buffer.writeln('      emit(${responseClassName}ErrorState(message: failure.message?? Strings.pleaseTryAgainLater));');
    buffer.writeln('    }, (${responseClassName}Response response) {');
    // if(dataType != null){
    //   if(dataType.startsWith('List')){
    //     buffer.writeln('      data.clear();');
    //     buffer.writeln('      data.addAll(response.data);');
    //   } else{
    //     buffer.writeln('      data = response.data;');
    //   }
    //
    //   buffer.writeln('      emit(${responseClassName}SuccessState(value: response.data));');
    // }else{
    //   buffer.writeln('      emit(const ${responseClassName}SuccessState());');
    // }

    if(dataType != null){
      buffer.writeln('      emit(${responseClassName}SuccessState(data: response.data));');
    }else{
      buffer.writeln('      emit(const ${responseClassName}SuccessState());');
    }

    buffer.writeln('    });');
    buffer.writeln('  }');
    buffer.writeln('}');


    return buffer;
  }

}