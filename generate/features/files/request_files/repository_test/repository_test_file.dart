import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';


class RepositoryTestFile extends RequestFile {
  RepositoryTestFile({required super.file});

  @override
  Future<void> generate({required Names featureNames, required Request request}) async {
    final StringBuffer buffer = StringBuffer();
    ///--> File imports
    buffer.writeln(request.buffers.repositoryTest.generateImports(
      featureNameSnakeCase: featureNames.snakeCase,
      requestNameSnakeCase: request.names.snakeCase,
      hasParams: request.params != null,
    ).toString());

    ///--> Test body
    buffer.writeln(request.buffers.repositoryTest.generateBody(featureNames: featureNames, request: request).toString());

    ///-> Write file
    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }


  @override
  Future<void> modify({required Names featureNames, required Request request}) {
    throw UnimplementedError();
  }
}
