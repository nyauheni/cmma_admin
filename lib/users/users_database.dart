import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/firedart.dart';
import 'package:cmma_admin/users/users_header.dart';

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

  void mergeRow(
      List<String> row, List<int> cols, UsersHeader usersHeader) async {
    late bool isMatch;
    outer:
    for (int iI = 0; iI < getCount(); iI++) {
      isMatch = true;
      for (int kI = 0; kI < usersHeader.getCount(); kI++) {
        if (cols[kI] >= 0) {
          if (getField(iI, usersHeader.getKey(kI)) !=
              row[cols[kI]].toString()) {
            isMatch = false;
            break;
          }
        }
      }
      if (isMatch) {
        break outer;
      }
    }
    if (!isMatch) {
      Map<String, dynamic> map = {};
      for (int kI = 0; kI < usersHeader.getCount(); kI++) {
        if (cols[kI] >= 0) {
          map.addAll({usersHeader.getKey(kI): row[cols[kI]].toString()});
        } else {
          map.addAll({usersHeader.getKey(kI): ""});
        }
      }
      (!kIsWeb)
          ? await Firestore.instance.collection(_collectionName).add(map)
          : await FirebaseFirestore.instance
              .collection(_collectionName)
              .add(map);
    }
  }
}
