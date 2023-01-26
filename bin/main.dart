import 'dart:io';

import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';
import 'package:flutter_translation_sheet/src/runner.dart';
import 'package:flutter_translation_sheet/src/utils/errors.dart';

/// dart run [절대경로]/flutter_translation_sheet/bin/main.dart [fetch / fetchwith / getAll]

/// entry point of the program.
/// Delegates arguments to the CommandRunner.
Future<void> main(List<String> args) async {
  _checkEnviroment();
  try {
    exit(await FTSCommandRunner().run(args));
  } on GSheetsException catch (e) {
    gsheetError(e);
    rethrow;
  }
}

/// Initializes the execution enviroment for the script.
/// [CliConfig.isDev] is `true` when runs locally.
void _checkEnviroment() async {
  CliConfig.isDev = Platform.script.toString().endsWith('main.dart');
}
