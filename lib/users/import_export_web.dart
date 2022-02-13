import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
      csvText += '\n';

      for (int index = 0; index < usersDatabase.getCount(); index++) {
        if (!callback(progressCurrent += progressStep)) break;
        for (int iHeader = 0; iHeader < usersHeader.getCount(); iHeader++) {
          csvText +=
              usersDatabase.getField(index, usersHeader.getKey(iHeader)) + ';';
        }
        csvText += '\n';
      }

      html.AnchorElement()
        ..href =
            '${Uri.dataFromString(csvText, mimeType: 'text/plain', encoding: utf8)}'
        ..download = collectionName + '.csv'
        ..style.display = 'none'
        ..click();
    }
  } catch (e) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            //title: const Text('error writing file'),
            content: const Text('error writing file'),
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
    var fileBytes = result.files.first.bytes!;

    // List<String> members = [
    //   for (int i = 0; i < fileLength; i++) String.fromCharCode(fileBytes[i])
    // ];
    // String? r = members.join('');

    late List<int> cols;
    int fileLength = fileBytes.length;
    double progressStep = 1 / fileLength;
    double progressCurrent = 0;

    try {
      // for (double x = 0; x < 1; x += 0.01) {
      //   await Future.delayed(const Duration(milliseconds: 100));
      //   if (!callback(x)) {
      //     break;
      //   }
      // }
      String line = '';
      int iLine = 0;
      for (int i = 0; i < fileLength; i++) {
        String s = String.fromCharCode(fileBytes[i]);
        if (s == '\n') {
          List<String> row = line.split(';');

          if (iLine == 0) {
            cols = usersHeader.mergeCol(row);
            iLine++;
          } else {
            usersDatabase.mergeRow(row, cols, usersHeader);
          }

          progressCurrent += progressStep * (line.length + 1);
          if (!callback(progressCurrent)) break;
          line = '';
        } else {
          line = line + s;
        }
      }
    } catch (e) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              //title: const Text('error reading file'),
              content: const Text('error reading file'),
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
