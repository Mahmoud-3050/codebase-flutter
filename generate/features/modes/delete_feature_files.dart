import 'dart:io';

import '../../utils/console_logger.dart';
import '../../utils/functions.dart';
import '../models/feature.dart';
import '../models/request.dart';

abstract class DeleteFeature {
  static Future<void> deleteRequests({
    required Feature feature,
    required List<Request> requests,
  }) async {
    if (requests.isEmpty) {
      ConsoleLogger.warning('No requests marked for deletion.');
      return;
    }

    for (final Request request in requests) {
      final List<File> targets = _perRequestFiles(request);
      ConsoleLogger.warning(
        'Deleting generated files for request "${request.names.original}":',
      );
      for (final File file in targets) {
        ConsoleLogger.info('  ${file.path}');
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      final String cubitDirectory =
          request.files.cubit.path.parentDirectoryPath;
      if (cubitDirectory.isNotEmpty) {
        final Directory directory = Directory(cubitDirectory);
        if (directory.existsSync() && directory.listSync().isEmpty) {
          ConsoleLogger.info('  $cubitDirectory');
          directory.deleteSync();
        }
      }

      ConsoleLogger.success(
        'Request "${request.names.original}" files deleted. JSON left as tombstone (mode: 3).',
      );
    }
  }

  static List<File> _perRequestFiles(Request request) {
    return <File>[
      request.files.entity,
      request.files.model,
      request.files.useCase,
      request.files.cubit,
      request.files.cubitStates,
      request.files.cubitTest,
      request.files.useCaseTest,
      request.files.repositoryTest,
      request.files.datasourceTest,
      if (request.files.blocConsumer != null) request.files.blocConsumer!,
    ];
  }
}
