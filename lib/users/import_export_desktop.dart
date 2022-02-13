import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cmma_admin/users/users_database.dart';
import 'package:cmma_admin/users/users_header.dart';

void export(
    String collectionName,
    UsersHeader usersHeader,
    UsersDatabase usersDatabase,
    Function callback,
    BuildContext context) async {
  bool? overwrite = true;
  String? fileName;
  String? result = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: collectionName,
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result != null) {
    fileName = (collectionName = result) + '.csv';
  }
  if (fileName != null) {
    if (File(fileName).existsSync()) {
      overwrite = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              //title: Text(fileName! + ' already exists. Replace?'),
              content: Text(fileName! + ' already exists. Replace?'),
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
      //File(fileName).writeAsString(csvText);
      IOSink out = File(fileName).openWrite();
      try {
        // for (double x = 0; x < 1; x += 0.01) {
        //   await Future.delayed(const Duration(milliseconds: 100));
        //   if (!callback(x)) {
        //     break;
        //   }
        // }

        double progressStep = 1 / (usersDatabase.getCount() + 1);
        double progressCurrent = 0;

        if (callback(progressCurrent += progressStep)) {
          String csvText = '';
          for (int iHeader = 0; iHeader < usersHeader.getCount(); iHeader++) {
            csvText += usersHeader.getTitle(iHeader) + ';';
          }
          out.write(csvText + '\n');

          for (int index = 0; index < usersDatabase.getCount(); index++) {
            if (!callback(progressCurrent += progressStep)) break;
            csvText = '';
            for (int iHeader = 0; iHeader < usersHeader.getCount(); iHeader++) {
              csvText +=
                  usersDatabase.getField(index, usersHeader.getKey(iHeader)) +
                      ';';
            }
            out.write(csvText + '\n');
          }
        }
      } catch (e) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                //title: Text('error writing file: ' + fileName!),
                content: Text('error writing file: ' + fileName!),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Ok"),
                    onPressed: () {},
                  ),
                ],
              );
            });
      }
      out.close();
      callback(0.0);
    }
  } else {
    // User canceled the picker
  }
}

void import(
    String collectionName,
    UsersHeader usersHeader,
    UsersDatabase usersDatabase,
    Function callback,
    BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Please select an input file:',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result != null) {
    //return File(result.files.single.path!).readAsString();

    String fileName = result.files.single.path!;
    final file = File(fileName);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter()); // Convert stream to individual lines.

    late List<int> cols;
    int fileLength = file.lengthSync();
    double progressStep = 1 / fileLength;
    double progressCurrent = 0;

    try {
      // for (double x = 0; x < 1; x += 0.01) {
      //   await Future.delayed(const Duration(milliseconds: 100));
      //   if (!callback(x)) {
      //     break;
      //   }
      // }

      if (callback(progressCurrent += progressStep)) {
        int iLine = 0;
        await for (var line in lines) {
          List<String> row = line.split(';');

          if (iLine == 0) {
            cols = usersHeader.mergeCol(row);
            iLine++;
          } else {
            usersDatabase.mergeRow(row, cols, usersHeader);

            progressCurrent += progressStep * (line.length + 1);
            if (!callback(progressCurrent)) break;
          }
        }
      }
    } catch (e) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              //title: Text('error reading file: ' + fileName),
              content: Text('error reading file: ' + fileName),
              actions: <Widget>[
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {},
                ),
              ],
            );
          });
    }
    callback(0.0);
  } else {
    return null;
  }
}
