import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import 'package:io/io.dart';

import 'data/strings.dart';
import 'io/io.dart';
import 'utils/utils.dart';

class FTSCommandRunner extends CommandRunner<int> {
  FTSCommandRunner()
      : super(
          CliConfig.cliName,
          'cli to make your app\'s l10n easy',
        ) {
    addCommand(FetchCommand(startFetch));
    addCommand(RunCommand(startRun));
    addCommand(UpgradeCommand(checkUpdate));
    argParser.addFlag(
      'version',
      help: 'current version',
      negatable: false,
    );
  }
  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final _args = parse(args);
      final cmd = _args.command?.name;
      final res = await runCommand(_args) ?? ExitCode.success.code;
      if (cmd != 'upgrade') {
        await checkUpdate(false);
      }
      return res;
    } catch (e) {
      error(e);
    }
    return ExitCode.usage.code;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      trace(green(CliConfig.version));
      return ExitCode.success.code;
    }

    return super.runCommand(topLevelResults);
  }

  Future<void> startRun() async {
    /// save json
    var map = buildLocalYamlMap();
    var canoMap = buildCanoMap(map);
    buildVarsInMap(canoMap);

    /// master language?
    // saveLocaleAsset(config.masterLocale, canoMap);
    await sheet.imtired(canoMap);

    trace('wait a sec to get the data translated');
    await Future.delayed(Duration(seconds: 1));

    final localesMap = await sheet.getData();
    localesMap[config.masterLocale] = canoMap;
    putVarsInMap(localesMap);

    /// create tkey file
    if (config.validTKeyFile) {
      createTKeyFileFromMap(map, save: true, includeToString: true);
    }
    createLocalesFiles(localesMap);
    formatDartFiles();
    exit(1);
  }

  Future<void> startFetch() async {
    trace('Creating local canonical json');
    var map = buildLocalYamlMap();
    var canoMap = buildCanoMap(map);
    trace('Fetching data from Google sheets...');
    final localesMap = await sheet.getData();
    localesMap[config.masterLocale] = canoMap;
    putVarsInMap(localesMap);

    if (config.validTKeyFile) {
      createTKeyFileFromMap(map, save: true, includeToString: true);
    }
    createLocalesFiles(localesMap);
    formatDartFiles();
    exit(1);
  }
}