import 'dart:io';
import 'package:image/image.dart';

void main(List<String> args) async {
  final percent = (args.isNotEmpty) ? int.tryParse(args[0]) ?? 110 : 110;
  final inputPath = 'assets/images/logofull.png';
  final target = 1024;

  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('File not found: $inputPath');
    exit(2);
  }

  final bytes = await file.readAsBytes();
  final img = decodeImage(bytes);
  if (img == null) {
    stderr.writeln('Could not decode image');
    exit(3);
  }

  // Detect bounding box of non-transparent pixels
  int minX = img.width, minY = img.height, maxX = 0, maxY = 0;
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      final px = img.getPixel(x, y);
      final a = getAlpha(px);
      if (a > 10) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  Image cropped = img;
  if (minX <= maxX && minY <= maxY) {
    final w = maxX - minX + 1;
    final h = maxY - minY + 1;
    cropped = copyCrop(img, minX, minY, w, h);
  }

  // First fit to target if larger than target, otherwise keep size
  final fitScale = (target / cropped.width).clamp(0, double.infinity);
  final fitScaleH = (target / cropped.height).clamp(0, double.infinity);
  final baseScale = (fitScale < fitScaleH) ? fitScale : fitScaleH;
  final baseW = (cropped.width * baseScale).round();
  final baseH = (cropped.height * baseScale).round();

  // Apply percent zoom relative to the base fit size
  final zoom = percent / 100.0;
  final newW = (baseW * zoom).round();
  final newH = (baseH * zoom).round();

  final resized = copyResize(cropped, width: newW, height: newH, interpolation: Interpolation.cubic);

  Image finalImage;
  if (newW <= target && newH <= target) {
    // center on white background
    finalImage = Image(target, target);
    fill(finalImage, getColor(255, 255, 255));
    final dx = ((target - newW) / 2).round();
    final dy = ((target - newH) / 2).round();
    copyInto(finalImage, resized, dstX: dx, dstY: dy);
  } else {
    // crop resized to center target area
    final sx = ((newW - target) / 2).round();
    final sy = ((newH - target) / 2).round();
    finalImage = copyCrop(resized, sx < 0 ? 0 : sx, sy < 0 ? 0 : sy, target, target);
  }

  final png = encodePng(finalImage, level: 6);
  await File(inputPath).writeAsBytes(png);
  stdout.writeln('Applied zoom ${percent}% and overwrote $inputPath (result 1024x1024)');
}
