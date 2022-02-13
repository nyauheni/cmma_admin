import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/firedart.dart';

const String keyemail = "email";
const String keyfirstname = "firstname";
const String keylastname = "lastname";
const String keypartner = "partner";
const String keycost = "cost";
const String keyextracost = "extracost";
const String keymembership = "membership";
const String keybirthday = "birthday";
const String keybirthplace = "birthplace";
const String keycity = "city";
const String keyadress = "adress";
const String keystreet = "street";
const String keytelefon = "telefon";
const String keybankowner = "BankbankownerOwner";
const String keybank = "bank";
const String keyiban = "iban";

class UsersHeader {
  final String _collectionName;
  UsersHeader(this._collectionName);

  bool toAdd = false;
  bool toLoad = true;
  bool toClean = false;

  final List<dynamic> _header = [];

  Future<void> setHeader() async {
    if (toClean) {
      if (!kIsWeb) {
        Page<Document> page =
            await Firestore.instance.collection(_collectionName).get();
        for (var element in page) {
          Firestore.instance
              .collection(_collectionName)
              .document(element.id)
              .delete();
        }
      } else {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection(_collectionName).get();
        for (var element in querySnapshot.docs) {
          FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(element.id)
              .delete();
        }
      }
    }

    if (toLoad) {
      if (!kIsWeb) {
        Page<Document> page =
            await Firestore.instance.collection(_collectionName).get();
        for (var element in page) {
          _header.add(element);
        }
      } else {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection(_collectionName).get();
        for (var element in querySnapshot.docs) {
          _header.add(element);
        }
      }
    }

    if (_header.isEmpty) {
      _header.add({
        "Key": keyemail,
        "Title": "E-mail",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["E-mail"],
        "Edit": true,
      });
      _header.add({
        "Key": keyfirstname,
        "Title": "Vorname",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["Vorname"],
        "Edit": true,
      });
      _header.add({
        "Key": keylastname,
        "Title": "Name",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["Name"],
        "Edit": true,
      });
      _header.add({
        "Key": keypartner,
        "Title": "Elter/Partner",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keycost,
        "Title": "Beitrag",
        "Type": "list",
        "Sort": "num",
        "Defaults": ["250", "200", "130", "80", "30"],
        "Edit": true,
      });
      _header.add({
        "Key": keyextracost,
        "Title": "Beitrag zusatz",
        "Type": "text",
        "Sort": "num",
        "Defaults": ["0"],
        "Edit": true,
      });
      _header.add({
        "Key": keymembership,
        "Title": "Status",
        "Type": "list",
        "Sort": "lex",
        "Defaults": [
          "Erwachsener",
          "Rentner",
          "Student",
          "Gastspieler",
          "Passiv"
        ],
        "Edit": true,
      });
      _header.add({
        "Key": keybirthday,
        "Title": "Geboren am",
        "Type": "date",
        "Sort": "date",
        "Defaults": ["1900-01-01"],
        "Edit": true,
      });
      _header.add({
        "Key": keybirthplace,
        "Title": "Geboren in",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keycity,
        "Title": "Wohnort",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keyadress,
        "Title": "Adresse",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keystreet,
        "Title": "Straße",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keytelefon,
        "Title": "Telefon",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keybankowner,
        "Title": "Kontoinhaber",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keybank,
        "Title": "Bank",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _header.add({
        "Key": keyiban,
        "Title": "IBAN",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });

      if (toAdd) {
        for (int iHeader = 0; iHeader < _header.length; iHeader++) {
          (!kIsWeb)
              ? await Firestore.instance
                  .collection(_collectionName)
                  .add(_header[iHeader])
              : await FirebaseFirestore.instance
                  .collection(_collectionName)
                  .add(_header[iHeader]);
        }
      }
    }
  }

  int getCount() {
    return _header.length;
  }

  String getKey(int index) {
    return _header[index]["Key"].toString();
  }

  String getTitle(int index) {
    return _header[index]["Title"].toString();
  }

  String getType(int index) {
    return _header[index]["Type"].toString();
  }

  String getSort(int index) {
    return _header[index]["Sort"].toString();
  }

  List<String> getChoices(int index) {
    List<String> choices = [];
    for (var element in _header[index]["Defaults"]) {
      choices.add(element.toString());
    }
    return choices;
  }

  bool canEdit(int index) {
    return _header[index]["Edit"].toString().toLowerCase() == 'true';
  }

  List<int> mergeCol(List<String> row) {
    List<int> cols = List.generate(getCount(), (index) => -1);
    for (int kI = 0; kI < getCount(); kI++) {
      for (int kE = 0; kE < row.length; kE++) {
        if (getTitle(kI) == row[kE].toString()) {
          cols[kI] = kE;
          break;
        }
      }
    }
    return cols;
  }
}
