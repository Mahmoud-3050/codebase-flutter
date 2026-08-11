import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';



class ModelFile extends RequestFile{

  ModelFile({required super.file});


  @override
  Future<void> generate({required Names featureNames, required Request request}) async {
    final StringBuffer buffer = StringBuffer();
    ///-> File imports
    buffer.writeln(request.buffers.model.generateImports(requestNameSnakeCase: request.names.snakeCase).toString());

    ///-> Class Response
    buffer.writeln(request.buffers.model.generateBody(featureNames: featureNames, request: request).toString());

    ///-> Write file
    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }


  @override
  Future<void> modify({required Names featureNames, required Request request}) {
    // TODO: implement modify
    throw UnimplementedError();
  }

}