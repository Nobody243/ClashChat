import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clashchat/widgets/app_logo.dart';

void main() {
  test('generate icon', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    final painter = AppLogoPainter(showBackground: true);
    painter.paint(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    
    File('assets/icon.png').writeAsBytesSync(pngBytes);
    print('Generated assets/icon.png');
  });
}
