import 'dart:io';
import 'package:path_provider/path_provider.dart';

String get platformPathSeparator => Platform.pathSeparator;
bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

List<String> _desktopEnvironmentPaths() {
  final sep = Platform.pathSeparator;
  final paths = <String>[];
  try {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    paths.add('$exeDir${sep}ENVIRONMENT.txt');
  } catch (_) {}
  paths.add('ENVIRONMENT.txt');
  paths.add('${Directory.current.path}${sep}ENVIRONMENT.txt');
  return paths;
}

String? readEnvironmentFileSync() {
  if (!isDesktop) {
    return null;
  }
  final possiblePaths = _desktopEnvironmentPaths();
  for (final filePath in possiblePaths) {
    final envFile = File(filePath);
    if (envFile.existsSync()) {
      final content = envFile.readAsStringSync().trim();
      if (content == 'Production' || content == 'Development') {
        return content;
      }
    }
  }
  return null;
}

Future<String?> readEnvironmentFile() async {
  final possiblePaths = <String>[
    if (isDesktop) ..._desktopEnvironmentPaths(),
    if (!isDesktop) ...[
      'ENVIRONMENT.txt',
      Directory.current.path + Platform.pathSeparator + 'ENVIRONMENT.txt',
    ],
  ];
  if (Platform.isAndroid || Platform.isIOS) {
    final docsDir = await getApplicationDocumentsDirectory();
    possiblePaths.add(docsDir.path + Platform.pathSeparator + 'ENVIRONMENT.txt');
  }
  for (final filePath in possiblePaths) {
    final envFile = File(filePath);
    if (await envFile.exists()) {
      final content = (await envFile.readAsString()).trim();
      if (content == 'Production' || content == 'Development') {
        return content;
      }
    }
  }
  return null;
}
