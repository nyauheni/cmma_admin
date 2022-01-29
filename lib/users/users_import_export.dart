import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

import 'import_export_desktop.dart'
    if (dart.library.html) 'import_export_web.dart' as download;

class UsersImportExport {
  static void export(
      String csvUsers, List<List<dynamic>> rows, BuildContext context) {
    String csvText =
        const ListToCsvConverter().convert(rows, fieldDelimiter: ';');
    download.export(csvUsers, csvText, context);
  }

  static Future<List<List<dynamic>>> import(
      String csvUsers, BuildContext context) async {
    List<List<dynamic>> rows = [];
    String? csvText = await download.import(context);
    if (csvText != null) {
      rows = const CsvToListConverter()
          .convert(csvText, fieldDelimiter: ';', shouldParseNumbers: false);
    }
    return rows;
  }
}
