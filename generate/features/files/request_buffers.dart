import '../models/names.dart';
import '../models/request.dart';

abstract class BaseRequestBuffers{

  StringBuffer generateImports({String featureNameSnakeCase, bool hasParams, String requestNameSnakeCase, bool isDataModel});

  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  });
}