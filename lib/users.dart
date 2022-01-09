import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:firedart/firedart.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cmmaa/database.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  static String title = 'Users';

  @override
  UsersState createState() => UsersState();
}

class UsersState extends State<Users> {
  final HDTRefreshController _hdtRefreshController = HDTRefreshController();
  final List<FieldHeader> headers = Header.getHeaders();

  Stream<List<Document>>? stream;

  List<Document> users = [];
  List<Map<String, dynamic>> editedUsers = [];
  List<String> selectedUsers = [];

  Map<String, bool> headerToFilter = {};
  Map<String, String> filterToFilter = {};
  bool isWithFilter = false;

  String sortField = '';
  bool isAscending = true;

  String selectedUsersCSV = "SelectedUsers";

  @override
  void initState() {
    stream = Firestore.instance.collection("Users").stream;

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
            child: streamBuilder(),
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
                      if (selectedUsers.isNotEmpty) {
                        for (String id in selectedUsers) {
                          await Firestore.instance
                              .collection('Users')
                              .document(id)
                              .delete();
                        }
                        selectedUsers.clear();
                        editedUsers.clear();
                      }
                      setState(() {});
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                    child: const Text('ADD USER'),
                    onPressed: () async {
                      Map<String, dynamic> map = {};
                      if (selectedUsers.isNotEmpty) {
                        map = editedUsers[
                            selectedUsers.indexOf(selectedUsers.last)];
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
                      await Firestore.instance.collection('Users').add(map);
                      setState(() {});
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                    child: const Text('EXPORT CSV'),
                    onPressed: () async {
                      String? result = await FilePicker.platform.saveFile(
                        dialogTitle: 'Please select an output file:',
                        fileName: selectedUsersCSV,
                        type: FileType.custom,
                        allowedExtensions: ['csv'],
                      );

                      if (result != null) {
                        bool? overwrite = true;
                        String fileName = (selectedUsersCSV = result) + '.csv';
                        if (File(fileName).existsSync()) {
                          overwrite = await showDialog<bool>(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                      fileName + ' already exists. Replace?'),
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
                          File(fileName).writeAsString(
                              const ListToCsvConverter()
                                  .convert(rows, fieldDelimiter: ';'));
                        }
                      } else {
                        // User canceled the picker
                      }
                      setState(() {});
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  StreamBuilder streamBuilder() {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          users = snapshot.data;
          if (isWithFilter) {
            for (FieldHeader header in headers) {
              if (headerToFilter.cast()[header.headerKey]) {
                users = users
                    .where((doc) => doc.map[header.headerKey]
                        .toString()
                        .startsWith(
                            filterToFilter[header.headerKey].toString()))
                    .toList();
              }
            }
          }
          return dataBody(users);
        }
        if (snapshot.hasError) return const Text('Something went wrong!');
        return const CircularProgressIndicator();
      },
    );
  }

  HorizontalDataTable dataBody(List<Document> data) {
    return HorizontalDataTable(
      leftHandSideColumnWidth: headers[0].width + 70,
      rightHandSideColumnWidth: Header.totalWidth(headers),
      isFixedHeader: true,
      headerWidgets: _getTitleWidget(),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: _generateRightHandSideColumnRow,
      itemCount: users.length,
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
                              (header.headerKey == sortField
                                  ? (isAscending ? ' ↓' : ' ↑')
                                  : ''),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      width: header.width,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    ),
                    onPressed: () {
                      sortField = header.headerKey;
                      isAscending = !isAscending;
                      if (isAscending) {
                        users.sort(
                            (a, b) => a[sortField].compareTo(b[sortField]));
                      } else {
                        users.sort(
                            (a, b) => b[sortField].compareTo(a[sortField]));
                      }
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
                  visible: selectedUsers.isNotEmpty &&
                      selectedUsers.contains(users[index].id),
                  child: Tooltip(
                      message: "Save",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.save,
                                color: Colors.green, size: 20),
                            onPressed: () async {
                              if (selectedUsers.isNotEmpty &&
                                  selectedUsers.contains(users[index].id)) {
                                Map<String, dynamic> map = editedUsers[
                                    selectedUsers.indexOf(users[index].id)];
                                await Firestore.instance
                                    .collection('Users')
                                    .document(users[index].id)
                                    .update(map);
                                selectedUsers.remove(users[index].id);
                                editedUsers.remove(map);
                              }
                              setState(() {});
                            },
                          )))),
              Visibility(
                  visible: selectedUsers.isNotEmpty &&
                      selectedUsers.contains(users[index].id),
                  child: Tooltip(
                      message: "Cancel",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.cancel,
                                color: Colors.red, size: 20),
                            onPressed: () async {
                              if (selectedUsers.isNotEmpty &&
                                  selectedUsers.contains(users[index].id)) {
                                Map<String, dynamic> map = editedUsers[
                                    selectedUsers.indexOf(users[index].id)];
                                selectedUsers.remove(users[index].id);
                                editedUsers.remove(map);
                              }
                              setState(() {});
                            },
                          )))),
              Visibility(
                  visible: selectedUsers.isEmpty ||
                      !selectedUsers.contains(users[index].id),
                  child: Tooltip(
                      message: "Edit",
                      child: SizedBox(
                          width: 25.0,
                          child: TextButton(
                            child: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () async {
                              if (selectedUsers.isEmpty ||
                                  !selectedUsers.contains(users[index].id)) {
                                List<String> listHeader = headers
                                    .map((header) => header.headerKey)
                                    .toList();
                                Map<String, dynamic> map = {
                                  for (var e in users[index]
                                      .map
                                      .keys
                                      .where((k) => listHeader.contains(k)))
                                    e: users[index].map[e]
                                };
                                editedUsers.add(map);
                                selectedUsers.add(users[index].id);
                              }
                              setState(() {});
                            },
                          ))))
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
      value:
          (selectedUsers.isNotEmpty && selectedUsers.contains(users[index].id))
              ? editedUsers[selectedUsers.indexOf(users[index].id)]
                      [header.headerKey]
                  .toString()
              : users[index][header.headerKey].toString(),
      isDense: true,
      onChanged: (value) {
        if (header.editable && selectedUsers.contains(users[index].id)) {
          String user = users[index].id;
          editedUsers[selectedUsers.indexOf(user)][header.headerKey] = value;
          setState(() {});
        }
      },
      items: header.editable && selectedUsers.contains(users[index].id)
          ? header.headerChoices.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text((value)),
              );
            }).toList()
          : [
              DropdownMenuItem<String>(
                value: users[index][header.headerKey].toString(),
                child: Text((users[index][header.headerKey].toString())),
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
        text: (selectedUsers.isNotEmpty &&
                selectedUsers.contains(users[index].id))
            ? editedUsers[selectedUsers.indexOf(users[index].id)]
                    [header.headerKey]
                .toString()
            : users[index][header.headerKey].toString(),
      ),
      onChanged: (value) {
        editedUsers[selectedUsers.indexOf(users[index].id)][header.headerKey] =
            value;
      },
      enabled: header.editable && selectedUsers.contains(users[index].id),
      style: TextStyle(
          decoration: header.editable && selectedUsers.contains(users[index].id)
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
                DateTime.parse(users[index][header.headerKey].toString());

            FocusScope.of(context).requestFocus(FocusNode());

            DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));

            if (newDate != null && newDate != currentDate) {
              editedUsers[selectedUsers.indexOf(users[index].id)]
                  [header.headerKey] = newDate.toString().substring(0, 10);
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
