import 'dart:io';

import '../utils/constants.dart';

void main() async{
  print('${GenerateConstants.blueColorCode} Fix TextController and FocusNode dispose Starting... ${GenerateConstants.resetColorCode}');
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    print('${GenerateConstants.redColorCode} ERROR: Directory "${directory.path}" does not exist! ${GenerateConstants.resetColorCode}');
    print('${GenerateConstants.redColorCode} Fix TextController and FocusNode dispose Closed. ${GenerateConstants.resetColorCode}');
    return;
  }
  final List<File> searchFiles = searchInDirectory(directory);
  await run(searchFiles);
  print('${GenerateConstants.greenColorCode} Fix TextController and FocusNode dispose Finished. ${GenerateConstants.resetColorCode}');
}

List<File> searchInDirectory(Directory directory) {
  final List<FileSystemEntity> files = directory.listSync(recursive: true).where((entity) {
    return entity is File && entity.path.endsWith('.dart');
  }).toList();
  return files.map((FileSystemEntity item) => File(item.path)).toList();
}

Future<void> run(List<File> searchFiles) async{
  for(File file in searchFiles){
    final bool isTermExists = searchInFile(file);
    if(isTermExists){
      final List<String> textControllersNames = getTextControllersNames(file);
      writeDispose(file, textControllersNames);
    }
  }
}

bool searchInFile(File file) {
  String fileString = getFileAsString(file);
  return fileString.contains('=TextEditingController(') || fileString.contains('=FocusNode(');
}

String getFileAsString(File file, {bool withLines = true}){
  String fileString = file.readAsStringSync().trim()
      .replaceAllMapped(RegExp(r'\(\s*\)'), (match) => '()')
      .replaceAllMapped(RegExp(r'TextEditingController\s+\('), (match) => 'TextEditingController(')
      .replaceAllMapped(RegExp(r'FocusNode\s+\('), (match) => 'FocusNode(')
      .replaceAllMapped(RegExp(r'=\s+'), (match) => '=')
      .replaceAllMapped(RegExp(r'\s+;'), (match) => ';');
  if(!withLines){
    fileString.replaceAll('\n', '');
  }
  return fileString;
}

List<String> getTextControllersNames(File file){
  final String fileString = getFileAsString(file, withLines: false);
  List<String> textControllersNames = [];
  for(String item in fileString.split(';')){
    final bool isItemNotCommented = !item.contains('//');
    if(isItemNotCommented && (item.contains('=TextEditingController(') || item.contains('=FocusNode('))){
      String nameTerm = item.split('=')[0].trim();
      String name = '';
      for(int i=nameTerm.length-1; i>=0 ; i--){
        if(nameTerm[i].trim() != ''){
          name = '${nameTerm[i]}$name';
        }else{
          break;
        }
      }
      textControllersNames.add(name);
    }
  }
  return textControllersNames;
}

void writeDispose(File file, List<String> controllersNames){
  if(file.readAsStringSync().contains('super.dispose')){
    final splitItems = file.readAsStringSync()
        .replaceAllMapped(RegExp(r'\(\s*\)'), (match) => '()')
        .replaceAllMapped(RegExp(r'super.dispose\s+\('), (match) => 'super.dispose(')
        .split('super.dispose()');

    List<String> filterControllersNames = [];
    for(String item in controllersNames){
      if(!file.readAsStringSync().contains('$item.dispose')){
        filterControllersNames.add(item);
      }
    }

    if(splitItems.length == 2){
      String firstSplit = splitItems.first.trim();
      if(firstSplit.isNotEmpty){
        String content = firstSplit;
        for(String name in filterControllersNames){
          content += '\n\t\t$name.dispose();';
        }
        content += '\n\t\tsuper.dispose()';
        content += splitItems.last;
        file.writeAsStringSync(content);
        return;
      }
    }
  }
  String content = '\t@override\n\tvoid dispose() {';
  for(String name in controllersNames){
    content += '\n\t\t$name.dispose();';
  }
  content += '\n\t\tsuper.dispose();';
  content += '\n\t}';

  final String fileString = file.readAsStringSync().trim();
  String fileContent = fileString.substring(0, fileString.length - 1);
  fileContent = '$fileContent\n$content\n}';
  file.writeAsStringSync(fileContent);
}
