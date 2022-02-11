import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void export(String csvFile, String csvText, BuildContext context) async {
  bool? overwrite = true;
  String? fileName;
  String? result = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: csvFile,
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result != null) {
    fileName = (csvFile = result) + '.csv';
  }
  if (fileName != null) {
    if (File(fileName).existsSync()) {
      overwrite = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(fileName! + ' already exists. Replace?'),
              actions: <Widget>[
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                ),
                TextButton(
                  child: const Text("No"),
                  onPressed: () async {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          });
    }
    if (overwrite!) {
      File(fileName).writeAsString(csvText);
    }
  } else {
    // User canceled the picker
  }
}

Future<String?> import(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Please select an input file:',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result != null) {
    return File(result.files.single.path!).readAsString();

// final file = File(result.files.single.path!);
//   Stream<String> lines = file.openRead()
//     .transform(utf8.decoder)       // Decode bytes to UTF-8.
//     .transform(const LineSplitter());    // Convert stream to individual lines.
//   try {
//     await for (var line in lines) {
//       print('$line: ${line.length} characters');
//     }
//     print('File is now closed.');
//   } catch (e) {
//     print('Error: $e');
//   }
//   List<String> list = await lines.toList();
//   return list.join();

  } else {
    return null;
  }
}
