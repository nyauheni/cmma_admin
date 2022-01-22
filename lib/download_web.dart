import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';

void download(String csvFile, String csvText, BuildContext context) {
  html.AnchorElement()
    ..href =
        '${Uri.dataFromString(csvText, mimeType: 'text/plain', encoding: utf8)}'
    ..download = csvFile + '.csv'
    ..style.display = 'none'
    ..click();
}
