import 'dart:convert';
import 'dart:io';

import '../../utils/enums.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import 'names.dart';
import 'request.dart';
import 'settings.dart';

class Feature {
  final Names names;
  final List<Request> requests;
  final Settings settings;

  /// Feature-level mode from `settings.json`, not from request JSON files.
  final ModeType modeType;
  final List<File> jsonFiles;
  final List<Map<String, dynamic>> jsonMaps;

  const Feature({
    required this.names,
    required this.settings,
    required this.modeType,
    this.requests = const <Request>[],
    this.jsonFiles = const <File>[],
    this.jsonMaps = const <Map<String, dynamic>>[],
  });

  factory Feature.fromString(String featureName) {
    final Names names = Names.fromString(featureName);
    final String featureJsonFilePath =
        '${GenerateConstants.requestsAssetsPath}/${names.snakeCase}';
    final File settingsFile = File('$featureJsonFilePath/settings.json');

    Map<String, dynamic> settingsMap = <String, dynamic>{};
    if (settingsFile.existsSync()) {
      settingsMap =
          jsonDecode(settingsFile.readAsStringSync()) as Map<String, dynamic>;
    } else {
      createFile(settingsFile.path);
      settingsMap = <String, dynamic>{'mode': 1};
      settingsFile.writeAsStringSync(jsonEncode(settingsMap));
    }

    final Settings settingsModel = Settings.fromJson(
      json: settingsMap,
      file: settingsFile,
    );
    final ModeType modeType = .fromCode(settingsModel.mode);

    return Feature(names: names, settings: settingsModel, modeType: modeType);
  }

  Feature markAsProtected() {
    final Settings updatedSettings = settings.copyWith(mode: 0);
    updatedSettings.persist();
    return copyWith(settings: updatedSettings, modeType: .protected);
  }

  /// Requests that belong in aggregate files (datasource / repo / injection).
  /// Excludes tombstones (`mode: 3`).
  List<Request> get activeRequests =>
      requests.where((Request request) => request.mode != .delete).toList();

  /// New requests to add (`mode: 1`).
  List<Request> get generateRequests =>
      requests.where((Request request) => request.mode == .generate).toList();

  /// Existing requests whose per-request files should be overwritten (`mode: 2`).
  List<Request> get modifyRequests =>
      requests.where((Request request) => request.mode == .modify).toList();

  /// Per-request files to create or overwrite during feature modify.
  /// Protected requests (`mode: 0`) are left untouched.
  List<Request> get writableRequests => requests
      .where(
        (Request request) =>
            request.mode == .generate || request.mode == .modify,
      )
      .toList();

  List<Request> get deleteRequests =>
      requests.where((Request request) => request.mode == .delete).toList();

  /// Feature modify has work when any request is generate, modify, or delete.
  bool get hasModifyWork =>
      writableRequests.isNotEmpty || deleteRequests.isNotEmpty;

  Feature copyWith({
    Names? names,
    List<Request>? requests,
    Settings? settings,
    ModeType? modeType,
    List<File>? jsonFiles,
    List<Map<String, dynamic>>? jsonMaps,
  }) {
    return Feature(
      names: names ?? this.names,
      requests: requests ?? this.requests,
      settings: settings ?? this.settings,
      modeType: modeType ?? this.modeType,
      jsonFiles: jsonFiles ?? this.jsonFiles,
      jsonMaps: jsonMaps ?? this.jsonMaps,
    );
  }
}
