import 'dart:io';
import 'package:image/image.dart';

void main() async {
  final inputPath = 'assets/images/logofull.png';
  final outPath = inputPath; // overwrite

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

  // Resize to fit within 1024x1024 keeping aspect ratio
  const target = 1024;
  final scale = (target / cropped.width).clamp(0, double.infinity);
  final scaleH = (target / cropped.height).clamp(0, double.infinity);
  final useScale = (scale < scaleH) ? scale : scaleH;
  final newW = (cropped.width * useScale).round();
  final newH = (cropped.height * useScale).round();
  final resized = copyResize(cropped, width: newW, height: newH, interpolation: Interpolation.cubic);

  // Create final square canvas and place centered with white background
  final outImage = Image(target, target);
  // white background
  fill(outImage, getColor(255, 255, 255));

  final dx = ((target - resized.width) / 2).round();
  final dy = ((target - resized.height) / 2).round();
  copyInto(outImage, resized, dstX: dx, dstY: dy);

  final png = encodePng(outImage, level: 6);
  await File(outPath).writeAsBytes(png);
  stdout.writeln('Processed and overwrote $outPath (trim+resize to ${target}x${target})');
}
