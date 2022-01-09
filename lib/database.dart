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

class FieldHeader {
  String headerKey;
  String headerTitle;
  String headerType;
  List<String> headerChoices;
  double width;
  bool editable;

  FieldHeader(this.headerKey, this.headerTitle, this.headerType,
      this.headerChoices, this.width, this.editable);
}

// Table Header
class Header {
  List<FieldHeader> headerList = [];

  void addFieldHeader(String headerKey, String headerTitle, String headerType,
      List<String> headerChoices, double width, bool editable) {
    headerList.add(FieldHeader(
        headerKey, headerTitle, headerType, headerChoices, width, editable));
  }

  static List<FieldHeader> getHeaders() {
    Header header = Header();

    header.addFieldHeader(keyemail, "E-mail", "text", [], 150, true);
    header.addFieldHeader(keyfirstname, "Vorname", "text", [], 150, true);
    header.addFieldHeader(keylastname, "Name", "text", [], 150, true);
    header.addFieldHeader(keypartner, "Elter/Partner", "text", [], 150, true);
    header.addFieldHeader(keycost, "Beitrag", "list",
        ["250", "200", "130", "80", "30"], 150, true);
    header.addFieldHeader(keyextracost, "Beitrag zusatz", "text", [], 150, true);
    header.addFieldHeader(
        keymembership,
        "Status",
        "list",
        ["Erwachsener", "Rentner", "Student", "Gastspieler", "Passiv"],
        150,
        true);
    header.addFieldHeader(keybirthday, "Geboren am", "date", [], 150, true);
    header.addFieldHeader(keybirthplace, "Geboren in", "text", [], 150, true);
    header.addFieldHeader(keycity, "Wohnort", "text", [], 150, true);
    header.addFieldHeader(keyadress, "Adresse", "text", [], 150, true);
    header.addFieldHeader(keystreet, "Straße", "text", [], 150, true);
    header.addFieldHeader(keytelefon, "Telefon", "text", [], 150, true);
    header.addFieldHeader(keybankowner, "Kontoinhaber", "text", [], 150, true);
    header.addFieldHeader(keybank, "Bank", "text", [], 150, true);
    header.addFieldHeader(keyiban, "IBAN", "text", [], 150, true);

//var sum = header.headerList.fol..reduce((value, element) => value.width+element.width);
    return header.headerList;
  }

  static double totalWidth(List<FieldHeader> headers) {
    List<double> widths =
        headers.skip(1).map((header) => header.width).toList();
    return widths.reduce((value, element) => value + element);
  }
}
// Table Header */
