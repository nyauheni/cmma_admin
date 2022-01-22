import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:csv/csv.dart';
import 'package:cmma_admin/database.dart';

import 'download_desktop.dart' if (dart.library.html) 'download_web.dart'
    as download;

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  static String title = 'Users';

  @override
  UsersState createState() => UsersState();
}

class UsersState extends State<Users> {
  final HDTRefreshController _hdtRefreshController = HDTRefreshController();
  final List<FieldHeader> headers = Header.getHeaders();

  List<dynamic> users = [];
  Map<String, Map<String, dynamic>> editedUsers = {};
  List<String> selectedUsers = [];

  Map<String, bool> headerToFilter = {};
  Map<String, String> filterToFilter = {};
  bool isWithFilter = false;

  String sortKey = '';
  String sortType = '';
  int sortOrder = 0;

  String csvUsers = "Users";

  @override
  void initState() {
    for (FieldHeader header in headers) {
      {
        headerToFilter[header.headerKey] = false;
        filterToFilter[header.headerKey] = '';
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("Users").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  users = (snapshot.data as QuerySnapshot).docs;

                  if (sortOrder != 0) {
                    users.sort((a, b) {
                      String aa = (sortOrder == 1) ? a[sortKey] : b[sortKey];
                      String bb = (sortOrder == 1) ? b[sortKey] : a[sortKey];
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

                  if (isWithFilter) {
                    for (FieldHeader header in headers) {
                      if (headerToFilter.cast()[header.headerKey]) {
                        users = users
                            .where((doc) => doc[header.headerKey]
                                .toString()
                                .startsWith(filterToFilter[header.headerKey]
                                    .toString()))
                            .toList();
                      }
                    }
                  }

                  return dataBody();
                }
                if (snapshot.hasError) {
                  return const Text('Something went wrong!');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                    child: const Text('DELETE SELECTED'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty) {
                        return null;
                      } else {
                        if (selectedUsers.isNotEmpty) {
                          for (String id in selectedUsers) {
                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(id)
                                .delete();
                          }
                          selectedUsers.clear();
                        }
                        setState(() {});
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                    child: const Text('ADD USER'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty) {
                        return null;
                      } else {
                        Map<String, dynamic> map = {};
                        if (selectedUsers.isNotEmpty) {
                          for (int index = 0; index < users.length; index++) {
                            if (selectedUsers.contains(users[index].id)) {
                              map = {
                                for (var header in headers)
                                  header.headerKey: users[index]
                                      [header.headerKey]
                              };
                            }
                          }
                        } else {
                          for (var header in headers) {
                            if (header.headerType == "text") {
                              map[header.headerKey] = header.headerTitle;
                            } else if (header.headerType == "list") {
                              map[header.headerKey] = header.headerChoices[0];
                            } else if (header.headerType == "date") {
                              map[header.headerKey] = DateTime.now().toString();
                            }
                          }
                        }
                        editedUsers.addAll({"NewUser": map});
                        setState(() {});
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                    child: Text(kIsWeb ? 'DOWNLOAD CSV' : 'EXPORT CSV'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty) {
                        return null;
                      } else {
                        List<List<dynamic>> rows = [];
                        List<dynamic> row = [];
                        for (var header in headers) {
                          row.add(header.headerTitle);
                        }
                        rows.add(row);
                        for (int index = 0; index < users.length; index++) {
                          List<dynamic> row = [];
                          for (var header in headers) {
                            row.add(users[index][header.headerKey]);
                          }
                          rows.add(row);
                        }
                        String csvText = const ListToCsvConverter()
                            .convert(rows, fieldDelimiter: ';');

                        download.download(csvUsers, csvText, context);
                        // if (kIsWeb) {
                        //   download.download(csvUsers, csvText, context);
                        //   // html.AnchorElement()
                        //   //   ..href =
                        //   //       '${Uri.dataFromString(csvText, mimeType: 'text/plain', encoding: utf8)}'
                        //   //   ..download = csvUsers + '.csv'
                        //   //   ..style.display = 'none'
                        //   //   ..click();
                        // } else {
                        //   bool? overwrite = true;
                        //   String? fileName;
                        //   String? result = await FilePicker.platform.saveFile(
                        //     dialogTitle: 'Please select an output file:',
                        //     fileName: csvUsers,
                        //     type: FileType.custom,
                        //     allowedExtensions: ['csv'],
                        //   );
                        //   if (result != null) {
                        //     fileName = (csvUsers = result) + '.csv';
                        //   }
                        //   if (fileName != null) {
                        //     if (File(fileName).existsSync()) {
                        //       overwrite = await showDialog<bool>(
                        //           barrierDismissible: false,
                        //           context: context,
                        //           builder: (context) {
                        //             return AlertDialog(
                        //               title: Text(fileName! +
                        //                   ' already exists. Replace?'),
                        //               actions: <Widget>[
                        //                 TextButton(
                        //                   child: const Text("Yes"),
                        //                   onPressed: () async {
                        //                     Navigator.pop(context, true);
                        //                   },
                        //                 ),
                        //                 TextButton(
                        //                   child: const Text("No"),
                        //                   onPressed: () async {
                        //                     Navigator.pop(context, false);
                        //                   },
                        //                 ),
                        //               ],
                        //             );
                        //           });
                        //     }
                        //     if (overwrite!) {
                        //       File(fileName).writeAsString(csvText);
                        //     }
                        //   } else {
                        //     // User canceled the picker
                        //   }
                        //}
                        setState(() {});
                      }
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  HorizontalDataTable dataBody() {
    return HorizontalDataTable(
      leftHandSideColumnWidth: headers[0].width + 70,
      rightHandSideColumnWidth: Header.totalWidth(headers),
      isFixedHeader: true,
      headerWidgets: _getTitleWidget(),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: _generateRightHandSideColumnRow,
      itemCount:
          (users.length + (editedUsers.keys.contains("NewUser") ? 1 : 0)),
      rowSeparatorWidget: const Divider(
        color: Colors.black54,
        height: 1.0,
        thickness: 0.0,
      ),
      leftHandSideColBackgroundColor: const Color(0xFFFFFFFF),
      rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
      verticalScrollbarStyle: const ScrollbarStyle(
        thumbColor: Colors.grey,
        isAlwaysShown: true,
        thickness: 10.0,
        radius: Radius.circular(5.0),
      ),
      horizontalScrollbarStyle: const ScrollbarStyle(
        thumbColor: Colors.grey,
        isAlwaysShown: true,
        thickness: 10.0,
        radius: Radius.circular(5.0),
      ),
      enablePullToRefresh: true,
      refreshIndicator: const WaterDropHeader(),
      refreshIndicatorHeight: 60,
      onRefresh: () async {
        //Do sth
        await Future.delayed(const Duration(milliseconds: 500));
        _hdtRefreshController.refreshCompleted();
      },
      enablePullToLoadNewData: true,
      loadIndicator: const ClassicFooter(),
      onLoad: () async {
        //Do sth
        await Future.delayed(const Duration(milliseconds: 500));
        _hdtRefreshController.loadComplete();
      },
      htdRefreshController: _hdtRefreshController,
    );
  }

  List<Widget> _getTitleWidget() {
    return headers
        .map((header) =>
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Tooltip(
                  message: isWithFilter ? '' : "Press long to filter",
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      child: Text(
                          header.headerTitle +
                              (header.headerKey == sortKey && sortOrder != 0
                                  ? (sortOrder == 1 ? ' ↓' : ' ↑')
                                  : ''),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      width: header.width,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    ),
                    onPressed: () {
                      sortOrder += 1;
                      if (sortOrder == 2) sortOrder = -1;
                      sortKey =
                          sortOrder == 0 ? sortKey = '' : header.headerKey;
                      sortType = header.headerSort;
                      setState(() {});
                    },
                    onLongPress: () {
                      isWithFilter = !isWithFilter;
                      setState(() {});
                    },
                  )),
              Visibility(
                  visible: isWithFilter,
                  child: Row(children: <Widget>[
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            width: header.width - 50,
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                            child: TextFormField(
                              controller: TextController(
                                text: filterToFilter[header.headerKey],
                              ),
                              onChanged: (value) {
                                filterToFilter[header.headerKey] = value;
                                setState(() {});
                              },
                            ))),
                    Transform.scale(
                        scale: 0.7,
                        child: Checkbox(
                            activeColor: const Color.fromARGB(255, 0, 128, 0),
                            value: headerToFilter.cast()[header.headerKey],
                            onChanged: (value) {
                              headerToFilter.cast()[header.headerKey] = value;
                              setState(() {});
                            }))
                  ]))
            ]))
        .toList();
  }

  bool isInEdit(int index) => index == users.length
      ? true
      : editedUsers.isNotEmpty && editedUsers.keys.contains(users[index].id);

  bool isToEdit(int index) => editedUsers.keys.isEmpty;

  String getUserID(int index) =>
      index == users.length ? "NewUser" : users[index].id;

  Map<String, dynamic>? getUserMap(int index) => editedUsers[getUserID(index)];

  String getUserMapField(int index, String headerKey) =>
      (editedUsers.isNotEmpty && editedUsers.keys.contains(getUserID(index)))
          ? getUserMap(index)![headerKey].toString()
          : users[index][headerKey].toString();

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: _generateTextFormField(context, headers[0], index),
          width: headers[0].width,
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start, // this right here
            children: <Widget>[
              Visibility(
                  visible: isInEdit(index),
                  child: Tooltip(
                      message: "Save",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.save,
                                color: Colors.green, size: 20),
                            onPressed: () async {
                              if (isInEdit(index)) {
                                String id = getUserID(index);
                                Map<String, dynamic>? map = getUserMap(index);
                                if (editedUsers.keys.contains("NewUser")) {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .add(map!);
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(getUserID(index))
                                      .update(map!);
                                }
                                editedUsers.remove(id);
                              }
                              setState(() {});
                            },
                          )))),
              Visibility(
                  visible: isInEdit(index),
                  child: Tooltip(
                      message: "Cancel",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.cancel,
                                color: Colors.red, size: 20),
                            onPressed: () async {
                              if (isInEdit(index)) {
                                editedUsers.remove(getUserID(index));
                              }
                              setState(() {});
                            },
                          )))),
              Visibility(
                  visible: isToEdit(index),
                  child: Tooltip(
                      message: "Edit",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () async {
                              if (isToEdit(index)) {
                                Map<String, dynamic> map = {
                                  for (var header in headers)
                                    header.headerKey:
                                        getUserMapField(index, header.headerKey)
                                };
                                editedUsers.addAll({getUserID(index): map});
                              }
                              setState(() {});
                            },
                          )))),
              Visibility(
                  visible: isToEdit(index),
                  child: Tooltip(
                      message: "Select",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: Icon(
                                selectedUsers.isNotEmpty &&
                                        selectedUsers.contains(getUserID(index))
                                    ? Icons.add_circle
                                    : Icons.add_circle_outline,
                                color: Colors.grey,
                                size: 20),
                            onPressed: () async {
                              if (isToEdit(index)) {
                                if (selectedUsers.contains(getUserID(index))) {
                                  selectedUsers.remove(getUserID(index));
                                } else {
                                  selectedUsers.add(getUserID(index));
                                }
                              }
                              setState(() {});
                            },
                          )))),
            ]),
      ],
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: headers
          .skip(1)
          .map((header) => Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: header.headerType == "list"
                            ? _generateDropdown(context, header, index)
                            : _generateTextFormField(context, header, index))
                  ],
                ),
                width: header.width,
                height: 52,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              ))
          .toList(),
    );
  }

  Widget _generateDropdown(
      BuildContext context, FieldHeader header, int index) {
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
      value: getUserMapField(index, header.headerKey),
      isDense: true,
      onChanged: (value) {
        if (header.editable && editedUsers.keys.contains(getUserID(index))) {
          getUserMap(index)![header.headerKey] = value;
          setState(() {});
        }
      },
      items: header.editable && editedUsers.keys.contains(getUserID(index))
          ? header.headerChoices.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text((value)),
              );
            }).toList()
          : [
              DropdownMenuItem<String>(
                value: getUserMapField(index, header.headerKey),
                child: Text(getUserMapField(index, header.headerKey)),
              )
            ],
    ));
  }

  Widget _generateTextFormField(
      BuildContext context, FieldHeader header, int index) {
    return TextFormField(
      // initialValue:
      //     users[index][header.headerKey].toString(),
      controller: TextEditingController(
        text: getUserMapField(index, header.headerKey),
      ),
      onChanged: (value) {
        getUserMap(index)![header.headerKey] = value;
      },
      enabled: header.editable && editedUsers.keys.contains(getUserID(index)),
      style: TextStyle(
          decoration:
              header.editable && editedUsers.keys.contains(getUserID(index))
                  ? TextDecoration.underline
                  : TextDecoration.none),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      // inputFormatters: [
      //   recordField.bEditable && recordField.bNumeric
      //       ? FilteringTextInputFormatter.digitsOnly
      //       : FilteringTextInputFormatter
      //           .singleLineFormatter
      // ],
      // validator: (value) {
      //   if (value!.isEmpty) {
      //     return 'Enter last Name';
      //   }
      //   return null;
      // },
      onTap: () async {
        if (header.editable) {
          if (header.headerType == "date") {
            DateTime? currentDate =
                DateTime.parse(getUserMapField(index, header.headerKey));

            FocusScope.of(context).requestFocus(FocusNode());

            DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));

            if (newDate != null && newDate != currentDate) {
              getUserMap(index)![header.headerKey] =
                  newDate.toString().substring(0, 10);
            }
          }
        }
      },
    );
  }
}

class TextController extends TextEditingController {
  TextController({String? text}) {
    this.text = text!;
  }

  @override
  set text(String newText) {
    value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty);
  }
}
