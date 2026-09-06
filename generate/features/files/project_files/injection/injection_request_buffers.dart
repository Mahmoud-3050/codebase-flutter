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
    buffer.writeln('void register${request.names.classCase}(GetIt sl) {');
    buffer.writeln(
      '  sl.registerFactory<${request.names.classCase}Cubit>(() => ${request.names.classCase}Cubit(sl()));',
    );
    buffer.writeln(
      '  sl.registerLazySingleton<${request.names.classCase}UseCase>(() => ${request.names.classCase}UseCase(repository: sl()));',
    );
    buffer.writeln('}');
    return buffer;
  }
}
