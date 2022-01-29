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

class UsersHeaderField {
  String headerKey;
  String headerTitle;
  String headerType;
  String headerSort;
  List<String> headerDefaults;
  bool canEdit;

  UsersHeaderField(this.headerKey, this.headerTitle, this.headerType,
      this.headerSort, this.headerDefaults, this.canEdit);
}

class UsersHeader {
  final String _collectionName;
  UsersHeader(this._collectionName);

  final List<UsersHeaderField> _headerList = [];

  void setHeader() {
    _headerList.add(
        UsersHeaderField(keyemail, "E-mail", "text", "lex", ["E-mail"], true));
    _headerList.add(UsersHeaderField(
        keyfirstname, "Vorname", "text", "lex", ["Vorname"], true));
    _headerList.add(
        UsersHeaderField(keylastname, "Name", "text", "lex", ["Name"], true));
    _headerList.add(UsersHeaderField(
        keypartner, "Elter/Partner", "text", "lex", [""], true));
    _headerList.add(UsersHeaderField(keycost, "Beitrag", "list", "num",
        ["250", "200", "130", "80", "30"], true));
    _headerList.add(UsersHeaderField(
        keyextracost, "Beitrag zusatz", "text", "num", ["0"], true));
    _headerList.add(UsersHeaderField(keymembership, "Status", "list", "lex",
        ["Erwachsener", "Rentner", "Student", "Gastspieler", "Passiv"], true));
    _headerList.add(UsersHeaderField(
        keybirthday, "Geboren am", "date", "date", ["1900-01-01"], true));
    _headerList.add(UsersHeaderField(
        keybirthplace, "Geboren in", "text", "lex", [""], true));
    _headerList
        .add(UsersHeaderField(keycity, "Wohnort", "text", "lex", [""], true));
    _headerList
        .add(UsersHeaderField(keyadress, "Adresse", "text", "lex", [""], true));
    _headerList
        .add(UsersHeaderField(keystreet, "Straße", "text", "lex", [""], true));
    _headerList.add(
        UsersHeaderField(keytelefon, "Telefon", "text", "lex", [""], true));
    _headerList.add(UsersHeaderField(
        keybankowner, "Kontoinhaber", "text", "lex", [""], true));
    _headerList
        .add(UsersHeaderField(keybank, "Bank", "text", "lex", [""], true));
    _headerList
        .add(UsersHeaderField(keyiban, "IBAN", "text", "lex", [""], true));
  }

  int getCount() {
    return _headerList.length;
  }

  String getKey(int index) {
    return _headerList[index].headerKey;
  }

  String getTitle(int index) {
    return _headerList[index].headerTitle;
  }

  String getType(int index) {
    return _headerList[index].headerType;
  }

  String getSort(int index) {
    return _headerList[index].headerSort;
  }

  List<String> getChoices(int index) {
    return _headerList[index].headerDefaults;
  }

  bool canEdit(int index) {
    return _headerList[index].canEdit;
  }
}
