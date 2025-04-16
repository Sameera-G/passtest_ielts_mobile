import 'package:flutter/material.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui; // ✅ correct and safe

Widget buildPlatformAudioPlayer({
  required String audioUrl,
  required bool isLocal, // not used in web
}) {
  final viewId = 'audio-html-${audioUrl.hashCode}';

  ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final audio =
        html.AudioElement()
          ..src = audioUrl
          ..controls = true
          ..style.width = '100%'
          ..style.height = '60px';
    return audio;
  });

  return SizedBox(height: 60, child: HtmlElementView(viewType: viewId));
}
