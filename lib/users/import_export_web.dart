import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void export(String csvFile, String csvText, BuildContext context) {
  html.AnchorElement()
    ..href =
        '${Uri.dataFromString(csvText, mimeType: 'text/plain', encoding: utf8)}'
    ..download = csvFile + '.csv'
    ..style.display = 'none'
    ..click();
}

Future<String?> import(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Please select an input file:',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    var fileBytes = result.files.first.bytes;
    //var fileName = result.files.first.name;

    // upload file
    //await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes);
    List<String> members = [for(int i = 0; i < fileBytes!.length; i++) String.fromCharCode(fileBytes[i])];
    String? r = members.join('');
    return r;
    //return File(result.files.single.path!).readAsString();
  } else {
    return null;
  }
}
