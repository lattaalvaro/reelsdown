import 'dart:io';
import 'package:image/image.dart';

void main() {
  final res = Directory('android/app/src/main/res');
  if (!res.existsSync()) {
    stderr.writeln('Android res folder not found');
    exit(2);
  }
  final files = res
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('ic_launcher.png') || f.path.endsWith('ic_launcher_round.png'))
      .toList();
  if (files.isEmpty) {
    stdout.writeln('No ic_launcher files found');
    return;
  }
  for (final f in files) {
    try {
      final img = decodeImage(f.readAsBytesSync());
      if (img == null) {
        stdout.writeln('${f.path}: could not decode');
        continue;
      }
      stdout.writeln('${f.path}: ${img.width}x${img.height}');
    } catch (e) {
      stdout.writeln('${f.path}: error $e');
    }
  }
}
