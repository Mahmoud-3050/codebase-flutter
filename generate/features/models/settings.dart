import 'dart:convert';
import 'dart:io';

class Settings {
  final File? file;
  final int mode;

  const Settings({required this.mode, this.file});

  factory Settings.fromJson({
    required Map<String, dynamic> json,
    required File file,
  }) {
    return Settings(file: file, mode: (json['mode'] as num?)?.toInt() ?? 1);
  }

  Settings copyWith({File? file, int? mode}) {
    return Settings(file: file ?? this.file, mode: mode ?? this.mode);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mode': mode};
  }

  void persist() {
    final targetFile = file;
    if (targetFile != null) {
      targetFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(toJson()),
      );
    }
  }
}
