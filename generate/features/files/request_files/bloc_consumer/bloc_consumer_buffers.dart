import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class BlocConsumerRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    if (isDataModel) {
      buffer.writeln(
        "import 'package:flutter_screenutil/flutter_screenutil.dart';",
      );
    }
    buffer.writeln();
    if (isDataModel) {
      buffer.writeln(
        "import '../../../../core/widgets/no_results_widget.dart';",
      );
    }
    buffer.writeln("import '../../../../core/widgets/app_snack_bar.dart';");
    if (isDataModel) {
      buffer.writeln(
        "import '../../domain/entities/${requestNameSnakeCase}_response.dart';",
      );
    }
    buffer.writeln(
      "import '../controller/$requestNameSnakeCase/${requestNameSnakeCase}_cubit.dart';",
    );
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    String modelClassName = request.modelClassNames.classCase;
    bool isDataModel = request.response['data'] != null;
    bool isDataList = isDataModel && request.response['data'] is List<dynamic>;

    buffer.writeln(
      'class ${responseClassName}Consumer extends StatefulWidget {',
    );
    buffer.writeln('  const ${responseClassName}Consumer({super.key});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  State<${responseClassName}Consumer> createState() => _${responseClassName}ConsumerState();',
    );
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'class _${responseClassName}ConsumerState extends State<${responseClassName}Consumer> {',
    );
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln(
      '    return BlocConsumer<${responseClassName}Cubit, ${responseClassName}State>(',
    );
    buffer.writeln(
      '      listener: (BuildContext context, ${responseClassName}State state) {',
    );
    buffer.writeln('        if (state is ${responseClassName}ErrorState) {');
    buffer.writeln('          showAppSnackBar(');
    buffer.writeln('            context: context,');
    buffer.writeln('            type: .error,');
    buffer.writeln('            message: state.message,');
    buffer.writeln('          );');
    buffer.writeln('        }');
    buffer.writeln('      },');
    if (isDataModel) {
      buffer.writeln(
        '      builder: (BuildContext context, ${responseClassName}State state) {',
      );
      buffer.writeln(
        '        if (state is ${responseClassName}LoadingState) {',
      );
      buffer.writeln('          return const Center(');
      buffer.writeln('            child: CircularProgressIndicator(),');
      buffer.writeln('          );');
      buffer.writeln('        }');
      buffer.writeln(
        '        if (state is ${responseClassName}SuccessState) {',
      );
      if (isDataList) {
        buffer.writeln('          if (state.value.isEmpty) {');
        buffer.writeln('            return const NoResultsWidget();');
        buffer.writeln('          }');
        buffer.writeln('          return ListView.separated(');
        buffer.writeln('            physics: const BouncingScrollPhysics(),');
        buffer.writeln('            padding: .symmetric(vertical: 16.h),');
        buffer.writeln('            itemCount: state.value.length,');
        buffer.writeln(
          '            itemBuilder: (BuildContext context, int index) {',
        );
        buffer.writeln(
          '              return ${modelClassName}Item(item: state.value[index], index: index);',
        );
        buffer.writeln('            },');
        buffer.writeln(
          '            separatorBuilder: (BuildContext context, int index) {',
        );
        buffer.writeln('              return SizedBox(height: 16.h);');
        buffer.writeln('            },');
        buffer.writeln('          );');
      } else {
        buffer.writeln('          //TODO: Write your success state builder ');
      }
      buffer.writeln('        }');
      buffer.writeln('        return const SizedBox();');
      buffer.writeln('      },');
    } else {
      buffer.writeln(
        '      builder: (BuildContext context, ${responseClassName}State state) {',
      );
      buffer.writeln(
        '        if (state is ${responseClassName}LoadingState) {',
      );
      buffer.writeln('          return const Center(');
      buffer.writeln('            child: CircularProgressIndicator(),');
      buffer.writeln('          );');
      buffer.writeln('        }');
      buffer.writeln('        return const SizedBox();');
      buffer.writeln('      },');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
    if (isDataList) {
      buffer.writeln('class ${modelClassName}Item extends StatefulWidget {');
      buffer.writeln('  final $modelClassName item;');
      buffer.writeln('  final int index;');
      buffer.writeln();
      buffer.writeln('  const ${modelClassName}Item({');
      buffer.writeln('    required this.item,');
      buffer.writeln('    required this.index,');
      buffer.writeln('    super.key,');
      buffer.writeln('  });');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln(
        '  State<${modelClassName}Item> createState() => _${modelClassName}ItemState();',
      );
      buffer.writeln('}');
      buffer.writeln();
      buffer.writeln(
        'class _${modelClassName}ItemState extends State<${modelClassName}Item> {',
      );
      buffer.writeln('  @override');
      buffer.writeln('  Widget build(BuildContext context) {');
      buffer.writeln('    return GestureDetector(');
      buffer.writeln('      onTap: () {');
      buffer.writeln('        //TODO: Write your code here');
      buffer.writeln('      },');
      buffer.writeln('      child: Container(');
      buffer.writeln(
        '        padding: .symmetric(horizontal: 16.w, vertical: 16.h),',
      );
      buffer.writeln('        decoration: BoxDecoration(');
      buffer.writeln('          borderRadius: .circular(16.r),');
      buffer.writeln('        ),');
      buffer.writeln('        child: Column(');
      buffer.writeln('          children: [');
      buffer.writeln('            //TODO: Write Your widgets here');
      buffer.writeln('          ],');
      buffer.writeln('        ),');
      buffer.writeln('      ),');
      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln('}');
    }
    return buffer;
  }
}
