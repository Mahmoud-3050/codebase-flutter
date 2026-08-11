import 'dart:io';

import '../models/names.dart';
import '../models/request.dart';

abstract class ProjectFile {
  final File file;

  ProjectFile({
    required this.file,
  });

  Future<void> generate(
      {required Names featureNames, required List<Request> requests});

  Future<void> modify(
      {required Names featureNames, required List<Request> requests});
}