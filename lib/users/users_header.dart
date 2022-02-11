import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';

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

  final List<dynamic> _headerList = [];
  bool toAdd = false;
  bool toLoad = true;
  bool toClean = false;

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
          _headerList.add(element);
        }
      } else {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection(_collectionName).get();
        for (var element in querySnapshot.docs) {
          _headerList.add(element);
        }
      }
    }

    if (_headerList.isEmpty)
    {
      _headerList.add({
        "Key": keyemail,
        "Title": "E-mail",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["E-mail"],
        "Edit": true,
      });
      _headerList.add({
        "Key": keyfirstname,
        "Title": "Vorname",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["Vorname"],
        "Edit": true,
      });
      _headerList.add({
        "Key": keylastname,
        "Title": "Name",
        "Type": "text",
        "Sort": "lex",
        "Defaults": ["Name"],
        "Edit": true,
      });
      _headerList.add({
        "Key": keypartner,
        "Title": "Elter/Partner",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keycost,
        "Title": "Beitrag",
        "Type": "list",
        "Sort": "num",
        "Defaults": ["250", "200", "130", "80", "30"],
        "Edit": true,
      });
      _headerList.add({
        "Key": keyextracost,
        "Title": "Beitrag zusatz",
        "Type": "text",
        "Sort": "num",
        "Defaults": ["0"],
        "Edit": true,
      });
      _headerList.add({
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
      _headerList.add({
        "Key": keybirthday,
        "Title": "Geboren am",
        "Type": "date",
        "Sort": "date",
        "Defaults": ["1900-01-01"],
        "Edit": true,
      });
      _headerList.add({
        "Key": keybirthplace,
        "Title": "Geboren in",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keycity,
        "Title": "Wohnort",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keyadress,
        "Title": "Adresse",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keystreet,
        "Title": "Straße",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keytelefon,
        "Title": "Telefon",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keybankowner,
        "Title": "Kontoinhaber",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keybank,
        "Title": "Bank",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });
      _headerList.add({
        "Key": keyiban,
        "Title": "IBAN",
        "Type": "text",
        "Sort": "lex",
        "Defaults": [""],
        "Edit": true,
      });

      if (toAdd) {
        for (int iHeader = 0; iHeader < _headerList.length; iHeader++) {
          (!kIsWeb)
              ? await Firestore.instance
                  .collection(_collectionName)
                  .add(_headerList[iHeader])
              : await FirebaseFirestore.instance
                  .collection(_collectionName)
                  .add(_headerList[iHeader]);
        }
      }
    }
  }

  int getCount() {
    return _headerList.length;
  }

  String getKey(int index) {
    return _headerList[index]["Key"].toString();
  }

  String getTitle(int index) {
    return _headerList[index]["Title"].toString();
  }

  String getType(int index) {
    return _headerList[index]["Type"].toString();
  }

  String getSort(int index) {
    return _headerList[index]["Sort"].toString();
  }

  List<String> getChoices(int index) {
    List<String> choices=[];
    for (var element in _headerList[index]["Defaults"]) {
      choices.add(element.toString());
    }
    return choices;
  }

  bool canEdit(int index) {
    return _headerList[index]["Edit"].toString().toLowerCase()=='true';
  }
}
