import 'dart:io';

import '../models/names.dart';
import '../models/request.dart';

abstract class RequestFile {
  final File file;

  RequestFile({
    required this.file,
  });

  Future<void> generate(
      {required Names featureNames, required Request request});

  Future<void> modify(
      {required Names featureNames, required Request request});
}