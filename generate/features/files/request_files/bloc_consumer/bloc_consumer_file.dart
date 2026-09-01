import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';

class BlocConsumerFile extends RequestFile {
  BlocConsumerFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required Request request,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln(
      request.buffers.blocConsumer
          ?.generateImports(
            requestNameSnakeCase: request.names.snakeCase,
            isDataModel:
                request.response['data'] != null &&
                request.response['data'] is List<dynamic>,
          )
          .toString(),
    );

    buffer.writeln();

    ///-> Class UseCase
    buffer.writeln(
      request.buffers.blocConsumer
          ?.generateBody(featureNames: featureNames, request: request)
          .toString(),
    );

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

// void generateBlocConsumerFile({
//   required String name,
//   required String feature,
//   required String? modelClassName,
// }) {
//
//   String camelCase = name;
//   if(isSnakeCase(camelCase)){
//     camelCase = snakeToCamelCase(camelCase);
//   }
//   String className = capitalizeFirstChar(camelCase);
//   String snakeName = upperToSnakeCase(className);
//
//
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("import 'package:flutter/material.dart';");
//   buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
//   buffer.writeln();
//   if(modelClassName != null){
//     buffer.writeln("import '../../../../core/constant/values/colors.dart';");
//     buffer.writeln("import '../../../../core/constant/values/size_config.dart';");
//     buffer.writeln("import '../../../../core/widgets/app_spacer.dart';");
//     buffer.writeln("import '../../../../core/widgets/no_results_widget.dart';");
//   }
//   buffer.writeln("import '../../../../core/widgets/toast.dart';");
//   if(modelClassName != null){
//     buffer.writeln("import '../../domain/entities/${snakeName}_response.dart';");
//   }
//   buffer.writeln("import '../controller/$snakeName/${snakeName}_cubit.dart';");
//   buffer.writeln();
//   buffer.writeln('class ${className}Consumer extends StatefulWidget {');
//   buffer.writeln('  const ${className}Consumer({super.key});');
//   buffer.writeln();
//   buffer.writeln('  @override');
//   buffer.writeln('  State<${className}Consumer> createState() => _${className}ConsumerState();');
//   buffer.writeln('}');
//   buffer.writeln();
//   buffer.writeln('class _${className}ConsumerState extends State<${className}Consumer> {');
//   buffer.writeln('  @override');
//   buffer.writeln('  Widget build(BuildContext context) {');
//   buffer.writeln('    return BlocConsumer<${className}Cubit, ${className}State>(');
//   buffer.writeln('      listener: (BuildContext context, ${className}State state) {');
//   buffer.writeln('        if (state is ${className}ErrorState) {');
//   buffer.writeln('          showToast(message: state.message);');
//   buffer.writeln('        }');
//   buffer.writeln('      },');
//   if(modelClassName != null){
//     buffer.writeln('      builder: (BuildContext context, ${className}State state) {');
//     buffer.writeln('        if (state is ${className}LoadingState) {');
//     buffer.writeln('          return const Center(');
//     buffer.writeln('            child: CircularProgressIndicator(),');
//     buffer.writeln('          );');
//     buffer.writeln('        }');
//     buffer.writeln('        if (state is ${className}SuccessState) {');
//     buffer.writeln('          if (state.value.isEmpty) {');
//     buffer.writeln('            return const NoResultsWidget();');
//     buffer.writeln('          }');
//     buffer.writeln('          return ListView.separated(');
//     buffer.writeln('            physics: const BouncingScrollPhysics(),');
//     buffer.writeln('            padding: EdgeInsets.symmetric(vertical: SizeConfig.vPadding),');
//     buffer.writeln('            itemCount: state.value.length,');
//     buffer.writeln('            itemBuilder: (BuildContext context, int index) {');
//     buffer.writeln('              return ${modelClassName}Item(item: state.value[index], index: index);');
//     buffer.writeln('            },');
//     buffer.writeln('            separatorBuilder: (BuildContext context, int index) {');
//     buffer.writeln('              return const AppSpacer(heightRatio: 1);');
//     buffer.writeln('            },');
//     buffer.writeln('          );');
//     buffer.writeln('        }');
//     buffer.writeln('        return const SizedBox();');
//     buffer.writeln('      },');
//   }else{
//     buffer.writeln('      builder: (BuildContext context, ${className}State state) {');
//     buffer.writeln('        if (state is ${className}LoadingState) {');
//     buffer.writeln('          return const Center(');
//     buffer.writeln('            child: CircularProgressIndicator(),');
//     buffer.writeln('          );');
//     buffer.writeln('        }');
//     buffer.writeln('        return const SizedBox();');
//     buffer.writeln('      },');
//   }
//   buffer.writeln('    );');
//   buffer.writeln('  }');
//   buffer.writeln('}');
//   buffer.writeln();
//   if(modelClassName != null){
//     buffer.writeln('class ${modelClassName}Item extends StatefulWidget {');
//     buffer.writeln('  final $modelClassName item;');
//     buffer.writeln('  final int index;');
//     buffer.writeln();
//     buffer.writeln('  const ${modelClassName}Item({');
//     buffer.writeln('    required this.item,');
//     buffer.writeln('    required this.index,');
//     buffer.writeln('    super.key,');
//     buffer.writeln('  });');
//     buffer.writeln();
//     buffer.writeln('  @override');
//     buffer.writeln('  State<${modelClassName}Item> createState() => _${modelClassName}ItemState();');
//     buffer.writeln('}');
//     buffer.writeln();
//     buffer.writeln('class _${modelClassName}ItemState extends State<${modelClassName}Item> {');
//     buffer.writeln('  @override');
//     buffer.writeln('  Widget build(BuildContext context) {');
//     buffer.writeln('    return GestureDetector(');
//     buffer.writeln('      onTap: () {');
//     buffer.writeln('        //TODO: Write your code here');
//     buffer.writeln('      },');
//     buffer.writeln('      child: Container(');
//     buffer.writeln('        padding: EdgeInsets.symmetric(');
//     buffer.writeln('          horizontal: SizeConfig.hPadding,');
//     buffer.writeln('          vertical: SizeConfig.vPadding,');
//     buffer.writeln('        ),');
//     buffer.writeln('        decoration: BoxDecoration(');
//     buffer.writeln('          borderRadius: BorderRadius.circular(SizeConfig.radius),');
//     buffer.writeln('          boxShadow: [');
//     buffer.writeln('            BoxShadow(blurRadius: 6, color: AppColors.black.withOpacity(0.1)),');
//     buffer.writeln('          ],');
//     buffer.writeln('        ),');
//     buffer.writeln('        child: Column(');
//     buffer.writeln('          children: [');
//     buffer.writeln('            //TODO: Write Your widgets here');
//     buffer.writeln('          ],');
//     buffer.writeln('        ),');
//     buffer.writeln('      ),');
//     buffer.writeln('    );');
//     buffer.writeln('  }');
//     buffer.writeln('}');
//   }
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/presentation/widgets/${snakeName}_bloc_consumer.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
// }
