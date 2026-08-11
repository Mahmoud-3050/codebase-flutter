import 'dart:convert';
import 'dart:io';

import '../features/models/names.dart';
import '../utils/exceptions.dart';
import '../utils/constants.dart';

/// TO run this file, write this command in terminal:
/// "dart generate/strings/main.dart"
void main(List<String> args) async{
  String mode = 'update';
  if(args.isNotEmpty && args[0] == '--d'){
    mode = 'delete';
  }
  const String filePath = GenerateConstants.langJsonAssetFilePath;
  final File file = File(filePath);
  final String previousContent = file.readAsStringSync();
  handleFileChange(mode, file, previousContent);
  // final Map<String, dynamic> jsonMap = json.decode(previousContent);
  // final Map<String, dynamic> jsonEnMap = await generateJsonTranslate(lang: 'en', jsonMap: jsonMap);
  // await generateJsonTranslate(lang: 'ar', jsonMap: jsonMap);
  // await generateAppStrings(jsonEnMap);
}

void handleFileChange(String mode, File file, String previousContent) async{
  final String currentContent = file.readAsStringSync();
  // final List<String> currentLines = currentContent.split('\n');
  // final List<String> previousLines = previousContent.split('\n');
  // for (int i = 0; i < currentLines.length; i++) {
  //   if (i >= previousLines.length || currentLines[i] != previousLines[i]) {
  //     print('Line ${i + 1} changed');
  //     print('Previous: ${(i) >= previousLines.length? 'null': previousLines[i]}');
  //     print('Current: ${currentLines[i]}');
  //     print('------------------------------------------------------');
  //   }
  // }
  previousContent = currentContent;
  final Map<String, dynamic> jsonMap = json.decode(currentContent);
  final Map<String, dynamic> jsonEnMap = await generateJsonTranslate(
    mode: mode,
    lang: 'en',
    jsonMap: jsonMap,
  );
  await generateJsonTranslate(
    mode: mode,
    lang: 'ar',
    jsonMap: jsonMap,
  );
  await generateAppStrings(jsonEnMap);
}

Future<Map<String, dynamic>> generateJsonTranslate({
  required String mode,
  required String lang,
  required Map<String, dynamic> jsonMap,
}) async{
  try{
    final StringBuffer buffer = StringBuffer();
    String filePath = lang == 'en'
        ? GenerateConstants.langEnJsonAssetFilePath
        : lang == 'ar'
        ? GenerateConstants.langArJsonAssetFilePath
        : '';
    File file = File(filePath);
    String content = file.readAsStringSync().trim();
    final Map<String, dynamic> fileMap = json.decode(content);
    List<String> lines = content.split('\n');
    List<String> linesWithoutLastCurlBrace = lines.sublist(0, lines.length - 1);
    buffer.writeAll(linesWithoutLastCurlBrace, '\n');
    String bufferStringTrim = buffer.toString().trim();
    bufferStringTrim = '$bufferStringTrim,';
    buffer.clear();
    buffer.writeln(bufferStringTrim);
    int counter = 0;
    jsonMap.forEach((String key, dynamic value) {
      try{
        String newKey = '';
        String newContent = '';
        if(key.contains('#;#')){
          newKey = key.split('#;#')[0].trim();
          newContent = key.split('#;#')[1].trim();
        }
        String usingKey = newKey.isEmpty? key : newKey;
        if(dartKeywords.contains(usingKey)){
          print('${GenerateConstants.blueColorCode} $usingKey ${GenerateConstants.redColorCode}is a keyword!');
          return;
        }
        late final Names keyNames;
        if(usingKey.endsWith('_')){
          keyNames = Names.fromString(usingKey.substring(0, usingKey.length - 1));
        } else {
          keyNames = Names.fromString(usingKey);
        }
        if(!fileMap.containsKey(keyNames.snakeCase)){
          lang == 'en'
              ? buffer.write('  "${keyNames.snakeCase}${usingKey.endsWith('_') ? '_' : ''}": "${newContent.isEmpty? keyNames.original: newContent}"')
              : buffer.write('  "${keyNames.snakeCase}${usingKey.endsWith('_') ? '_' : ''}": "$value"');
          if(counter < jsonMap.length - 1){
            buffer.write(',');
          }
          buffer.writeln();
        }


      }on NamesException {
        String keyStr = '[$key]';
        if(key.contains('#;#')){
          keyStr = '[${key.split('#;#')[0]}]';
        }
        if(lang == 'en' && key.contains('#;#')){
          keyStr = '[${key.split('#;#')[0]}]';
        }
        const String errorMessage = 'is not valid!';
        print('${GenerateConstants.blueColorCode} $keyStr ${GenerateConstants.redColorCode}$errorMessage');
      }
      counter++;
    });
    List<String> linesAfterWrite = buffer.toString().trim().split('\n');
    String lastLineOfLinesAfterWrite = linesAfterWrite.last.trimRight();
    if(lastLineOfLinesAfterWrite[lastLineOfLinesAfterWrite.length -1] == ','){
      lastLineOfLinesAfterWrite = lastLineOfLinesAfterWrite.substring(0, lastLineOfLinesAfterWrite.length - 1);
      linesAfterWrite[linesAfterWrite.length -1] = lastLineOfLinesAfterWrite;
      buffer.clear();
      buffer.writeAll(linesAfterWrite, '\n');
    }
    buffer.writeln();
    buffer.writeln('}');
    if(buffer.isNotEmpty){
      await file.writeAsString(buffer.toString());
      print('${GenerateConstants.greenColorCode} lang.json Updated successfully at $filePath ${GenerateConstants.resetColorCode}');
    }
    return json.decode(buffer.toString());
  }catch(e){
    print('generateJsonTranslate Error: ${e.toString()}');
    rethrow;
  }
}


Future<void> generateAppStrings(Map<String, dynamic> jsonMap) async{
  final StringBuffer buffer = StringBuffer();
  buffer.writeln("import 'package:get/get_utils/src/extensions/internacionalization.dart';");
  buffer.writeln();
  buffer.writeln('abstract class Strings {');
  jsonMap.forEach((String key, _) {
    try{
      String keyStr = key;
      if(key.endsWith('_')){
        keyStr = key.replaceAll('_', '');
      }
      final Names keyNames = Names.fromString(keyStr);
      // buffer.writeln("  static const String _${keyNames.camelCase} = '${keyNames.original}';");
      buffer.writeln("  static String get ${keyNames.camelCase}${key.endsWith('_') ? '_' : ''} => '${keyNames.original}${key.endsWith('_') ? '_' : ''}'.tr;");
      buffer.writeln();
    }on NamesException {
      final String keyStr = '[$key]';
      const String errorMessage = 'is not valid!';
      print('${GenerateConstants.blueColorCode} $keyStr ${GenerateConstants.redColorCode}$errorMessage');
    }
  });
  buffer.writeln('}');
  File file = File(GenerateConstants.outputStringsFilePath);
  await file.writeAsString(buffer.toString());
  print('${GenerateConstants.greenColorCode} class Strings Generated successfully at ${GenerateConstants.outputStringsFilePath} ${GenerateConstants.resetColorCode}');
}

List<String> dartKeywords = [
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
];
