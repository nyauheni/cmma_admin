import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmma_admin/users/users_header.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cmma_admin/users/users_import_export.dart';

class UsersDatabase {
  final String _collectionName;
  UsersDatabase(this._collectionName);

  List<dynamic> _users = [];

  int getCount() {
    return _users.length;
  }

  String getID(int index) {
    return _users[index].id.toString();
  }

  String getField(int index, String field) {
    return _users[index][field].toString();
  }

  Stream<Object?> getStream() {
    Stream<Object?> stream = (!kIsWeb)
        ? Firestore.instance.collection(_collectionName).stream
        : FirebaseFirestore.instance.collection(_collectionName).snapshots();
    return stream;
  }

  void setSnapshot(AsyncSnapshot<Object?> snapshot) {
    _users = (!kIsWeb)
        ? snapshot.data as List<dynamic>
        : (snapshot.data as QuerySnapshot).docs;
  }

  void delete(String id) {
    (!kIsWeb)
        ? Firestore.instance.collection(_collectionName).document(id).delete()
        : FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id)
            .delete();
  }

  void add(Map<String, String>? map) async {
    (!kIsWeb)
        ? await Firestore.instance.collection(_collectionName).add(map!)
        : await FirebaseFirestore.instance
            .collection(_collectionName)
            .add(map!);
  }

  void update(String id, Map<String, String>? map) async {
    (!kIsWeb)
        ? await Firestore.instance
            .collection(_collectionName)
            .document(id)
            .update(map!)
        : await FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id)
            .update(map!);
  }

  void sort(int sortOrder, String sortKey, String sortType) {
    _users.sort((a, b) {
      String aa =
          (sortOrder == 1) ? a[sortKey].toString() : b[sortKey].toString();
      String bb =
          (sortOrder == 1) ? b[sortKey].toString() : a[sortKey].toString();
      if (sortType == "lex") {
        return aa.compareTo(bb);
      } else if (sortType == "num") {
        return double.parse(aa).compareTo(double.parse(bb));
      } else if (sortType == "date") {
        return DateTime.parse(aa).compareTo(DateTime.parse(bb));
      } else {
        return 0;
      }
    });
  }

  void filter(String field, String filter) {
    _users = _users
        .where((doc) => doc[field].toString().startsWith(filter))
        .toList();
  }

  void export(String csvUsers, UsersHeader usersHeader, BuildContext context) {
    List<List<dynamic>> rows = [];
    List<dynamic> row = [];
    for (int iHeader = 0; iHeader < usersHeader.getCount(); iHeader++) {
      row.add(usersHeader.getTitle(iHeader));
    }
    rows.add(row);
    for (int index = 0; index < _users.length; index++) {
      List<dynamic> row = [];
      for (int iHeader = 0; iHeader < usersHeader.getCount(); iHeader++) {
        row.add(_users[index][usersHeader.getKey(iHeader)].toString());
      }
      rows.add(row);
    }
    UsersImportExport.export(csvUsers, rows, context);
  }

  void import(
      String csvUsers, UsersHeader usersHeader, BuildContext context) async {
    List<List<dynamic>> csvList =
        await UsersImportExport.import(csvUsers, context);
    if (csvList.isNotEmpty) {
      List<int> cols = List.generate(usersHeader.getCount(), (index) => -1);
      for (int kI = 0; kI < usersHeader.getCount(); kI++) {
        for (int kE = 0; kE < csvList[0].length; kE++) {
          if (usersHeader.getTitle(kI) == csvList[0][kE].toString()) {
            cols[kI] = kE;
            break;
          }
        }
      }
      List<int> rows = [];
      for (int iE = 1; iE < csvList.length; iE++) {
        late bool isMatch;
        outer:
        for (int iI = 0; iI < _users.length; iI++) {
          isMatch = true;
          for (int kI = 0; kI < usersHeader.getCount(); kI++) {
            if (cols[kI] >= 0) {
              if (_users[iI][usersHeader.getKey(kI)].toString() !=
                  csvList[iE][cols[kI]].toString()) {
                isMatch = false;
                break;
              }
            }
          }
          if (isMatch) break outer;
        }
        if (!isMatch) {
          rows.add(iE);
        }
      }
      for (int iE = 0; iE < rows.length; iE++) {
        Map<String, dynamic> map = {};
        for (int kI = 0; kI < usersHeader.getCount(); kI++) {
          if (cols[kI] >= 0) {
            map.addAll({
              usersHeader.getKey(kI): csvList[rows[iE]][cols[kI]].toString()
            });
          } else {
            map.addAll({usersHeader.getKey(kI): ""});
          }
        }
        (!kIsWeb)
            ? await Firestore.instance.collection("Users").add(map)
            : await FirebaseFirestore.instance.collection('Users').add(map);
      }
    }
  }
}
