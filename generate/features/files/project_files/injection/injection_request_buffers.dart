import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class InjectionRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      "import 'domain/usecases/${requestNameSnakeCase}_usecase.dart';",
    );
    buffer.writeln(
      "import 'presentation/controller/$requestNameSnakeCase/${requestNameSnakeCase}_cubit.dart';",
    );
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();

    ///-> Cubit
    buffer.writeln(
      '  _sl.registerFactory<${request.names.classCase}Cubit>(() => ${request.names.classCase}Cubit(_sl()));',
    );

    buffer.writeln('***');

    ///-> UseCase
    buffer.write(
      '  _sl.registerLazySingleton<${request.names.classCase}UseCase>(() => ${request.names.classCase}UseCase(repository: _sl()));',
    );

    buffer.writeln('***');

    ///-> BlocProvider
    buffer.writeln('  BlocProvider<${request.names.classCase}Cubit>(');
    buffer.writeln(
      '    create: (BuildContext context) => _sl<${request.names.classCase}Cubit>(),',
    );
    buffer.writeln('  ),');
    return buffer;
  }
}
