import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import 'import_export_desktop.dart'
    if (dart.library.html) 'import_export_web.dart' as download;

import 'package:cmma_admin/users/users_database.dart';
import 'package:cmma_admin/users/users_header.dart';

//setxkbmap -option 'numpad:microsoft'

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  static String collectionName = 'Users';

  @override
  UsersState createState() => UsersState();
}

class UsersState extends State<Users> {
  final HDTRefreshController _hdtRefreshController = HDTRefreshController();

  final UsersHeader _usersHeader = UsersHeader("UsersHeader");
  final UsersDatabase _usersDatabase = UsersDatabase(Users.collectionName);

  Map<String, Map<String, String>> editedUsers = {};
  List<String> selectedUsers = [];

  List<bool> headerToFilter = [];
  List<String> filterToFilter = [];

  String sortKey = '';
  String sortType = '';
  int sortOrder = 0;

  List<double> headerTextWidth = [];
  List<double> fieldWidth = [];

  static const FontWeight charHeaderWeight = FontWeight.bold;
  static const FontWeight charWeight = FontWeight.normal;
  static const FontStyle charHeaderStyle = FontStyle.italic;
  static const FontStyle charStyle = FontStyle.normal;
  static const Color charHeaderColor = Colors.red;
  static const Color charColor = Colors.black;
  static const String charHeaderFamily = '';
  static const String charFamily = '';

  static const double minCharWidth = 8;
  static const double maxCharWidth = 64;

  double charWidth = (maxCharWidth - minCharWidth) / 2;
  double paddingLeft = 0;
  double titleHeight = 0;
  double rowHeight = 0;
  double scrolBarThickness = 0;
  double controlButtonEdgeInsets = 20;

  double progressImportExport = 0;
  bool abortImportExport = false;

  @override
  void initState() {
    super.initState();
    rescale();

    _usersHeader.setHeader().then((result) {
      headerToFilter = List.filled(_usersHeader.getCount(), false);
      filterToFilter = List.filled(_usersHeader.getCount(), '');
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

//#region Header Interface

  int _getHeaderCount() => _usersHeader.getCount();
  String _getHeaderKey(int index) => _usersHeader.getKey(index);
  String _getHeaderTitle(int index) => _usersHeader.getTitle(index);
  String _getHeaderType(int index) => _usersHeader.getType(index);
  String _getHeaderSort(int index) => _usersHeader.getSort(index);
  List<String> _getHeaderChoices(int index) => _usersHeader.getChoices(index);
  bool _canHeaderEdit(int index) => _usersHeader.canEdit(index);

//#endregion

//#region Users Interface

  int _getUsersCount() => _usersDatabase.getCount();
  String _getUserID(int index) => _usersDatabase.getID(index);
  String _getUserField(int index, String field) =>
      _usersDatabase.getField(index, field);
  Stream<Object?> _getUsersStream() => _usersDatabase.getStream();
  void _setUsersSnapshot(AsyncSnapshot<Object?> snapshot) =>
      _usersDatabase.setSnapshot(snapshot);
  void _deleteUser(String id) => _usersDatabase.delete(id);
  void _addUser(Map<String, String>? map) => _usersDatabase.add(map);
  void _updateUser(String id, Map<String, String>? map) =>
      _usersDatabase.update(id, map);
  void _sortUsers(int sortOrder, String sortKey, String sortType) =>
      _usersDatabase.sort(sortOrder, sortKey, sortType);
  void _filterUsers(String field, String filter) =>
      _usersDatabase.filter(field, filter);

//#endregion

//#region Users Interface

  bool isInEdit(int iUser) => iUser == _getUsersCount()
      ? true
      : editedUsers.isNotEmpty && editedUsers.keys.contains(_getUserID(iUser));

  bool isToEdit(int iUser) => editedUsers.keys.isEmpty;

  String getUserID(int iUser) =>
      iUser == _getUsersCount() ? "NewUser" : _getUserID(iUser);

  Map<String, String>? getEditedUserMap(int iUser) =>
      editedUsers[getUserID(iUser)];
  Map<String, String> getUserMap(int iUser) {
    return {
      for (int iHeader = 0; iHeader < _getHeaderCount(); iHeader++)
        _getHeaderKey(iHeader): getUserMapField(iUser, iHeader)
    };
  }

  Map<String, String> getDefaultMap() {
    return {
      for (int iHeader = 0; iHeader < _getHeaderCount(); iHeader++)
        _getHeaderKey(iHeader): _getHeaderChoices(iHeader)[0]
    };
  }

  String getUserMapField(int iUser, int iHeader) =>
      (editedUsers.isNotEmpty && editedUsers.keys.contains(getUserID(iUser)))
          ? getEditedUserMap(iUser)![_getHeaderKey(iHeader)].toString()
          : _getUserField(iUser, _getHeaderKey(iHeader)).toString();
  void setUserMapField(int iUser, int iHeader, String value) =>
      getEditedUserMap(iUser)![_getHeaderKey(iHeader)] = value;

  void addUser(int iUser) => _addUser(getEditedUserMap(iUser));
  void updateUser(int iUser) =>
      _updateUser(getUserID(iUser), getEditedUserMap(iUser));

  void sortUsers() {
    if (sortOrder != 0) {
      _sortUsers(sortOrder, sortKey, sortType);
    }
  }

  void filterUsers() {
    if (headerToFilter.contains(true)) {
      for (var i = 0; i < headerToFilter.length; i++) {
        if (headerToFilter[i]) {
          _filterUsers(_getHeaderKey(i), filterToFilter[i]);
        }
      }
    }
  }

  Size calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      // textScaleFactor: WidgetsBinding.instance!.platformDispatcher.textScaleFactor,
    )..layout();
    return textPainter.size;
  }

  void rescale() {
    paddingLeft = charWidth;
    titleHeight = charWidth * 3;
    rowHeight = charWidth * 2;
    scrolBarThickness = charWidth / 2;
  }

//#endregion

  @override
  Widget build(BuildContext context) {
    if (headerToFilter.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
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
              stream: _getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _setUsersSnapshot(snapshot);

                  sortUsers();
                  filterUsers();

                  headerTextWidth = List.filled(_getHeaderCount(), 0);
                  fieldWidth = List.filled(_getHeaderCount(), 0);
                  for (int iHeader = 0;
                      iHeader < _getHeaderCount();
                      iHeader++) {
                    headerTextWidth[iHeader] = calcTextSize(
                      _getHeaderTitle(iHeader),
                      _getHeaderTextStyle(iHeader),
                    ).width;
                    fieldWidth[iHeader] = headerTextWidth[iHeader] +
                        charWidth +
                        charWidth +
                        charWidth;
                  }
                  for (int iHeader = 0;
                      iHeader < _getHeaderCount();
                      iHeader++) {
                    if (_getHeaderType(iHeader) == "list") {
                      for (var iHeaderChoice in _getHeaderChoices(iHeader)) {
                        double width = calcTextSize(
                                iHeaderChoice, _getFieldTextStyle(iHeader))
                            .width;
                        width += charWidth; // + charWidth; // + charWidth;
                        if (width > fieldWidth[iHeader]) {
                          fieldWidth[iHeader] = width;
                        }
                      }
                    } else {
                      for (int iUser = 0; iUser < _getUsersCount(); iUser++) {
                        double width = calcTextSize(
                                getUserMapField(iUser, iHeader),
                                _getFieldTextStyle(iHeader))
                            .width;
                        if (width > fieldWidth[iHeader]) {
                          fieldWidth[iHeader] = width;
                        }
                      }
                    }
                  }
                  fieldWidth[0] += charWidth + charWidth + charWidth;
                  fieldWidth = fieldWidth.map((e) => e + paddingLeft).toList();

                  return dataBody();
                }
                if (snapshot.hasError) {
                  return const Text('Something went wrong!');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(controlButtonEdgeInsets),
                child: OutlinedButton(
                    child: const Text('Delete Selected'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty || progressImportExport > 0) {
                        return null;
                      } else {
                        for (String id in selectedUsers) {
                          _deleteUser(id);
                        }
                        selectedUsers.clear();
                        setState(() {});
                      }
                    }),
              ),
              Padding(
                padding: EdgeInsets.all(controlButtonEdgeInsets),
                child: OutlinedButton(
                    child: const Text('Add User'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty || progressImportExport > 0) {
                        return null;
                      } else {
                        Map<String, String> map = {};
                        if (selectedUsers.isEmpty) {
                          editedUsers.addAll({"NewUser": getDefaultMap()});
                        } else {
                          for (int iUser = 0;
                              iUser < _getUsersCount();
                              iUser++) {
                            if (selectedUsers.contains(getUserID(iUser))) {
                              editedUsers
                                  .addAll({"NewUser": getUserMap(iUser)});
                              break;
                            }
                          }
                        }
                        setState(() {});
                      }
                    }),
              ),
              Padding(
                padding: EdgeInsets.all(controlButtonEdgeInsets),
                child: OutlinedButton(
                    child: progressImportExport > 0
                        ? const Text('Cancel I/O')
                        : const Text('Export CSV'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty) {
                        return null;
                      } else {
                        if (progressImportExport > 0) {
                          abortImportExport = true;
                        } else {
                          download.export(Users.collectionName, _usersHeader,
                              _usersDatabase, callbackImportExport, context);
                        }
                        setState(() {});
                      }
                    }),
              ),
              Padding(
                padding: EdgeInsets.all(controlButtonEdgeInsets),
                child: OutlinedButton(
                    child: progressImportExport > 0
                        ? const Text('Cancel I/O')
                        : const Text('Import CSV'),
                    onPressed: () async {
                      if (editedUsers.isNotEmpty) {
                        return null;
                      } else {
                        if (progressImportExport > 0) {
                          abortImportExport = true;
                        } else {
                          download.import(Users.collectionName, _usersHeader,
                              _usersDatabase, callbackImportExport, context);
                        }
                        setState(() {});
                      }
                    }),
              ),
              Slider(
                  value: charWidth,
                  min: minCharWidth,
                  max: maxCharWidth,
                  divisions: (maxCharWidth - minCharWidth).round(),
                  label: charWidth.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      charWidth = value;
                      rescale();
                    });
                  }),
            ],
          ),
          Visibility(
              visible: progressImportExport > 0,
              child: SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: progressImportExport,
                  ))),
        ],
      ),
    );
  }

  HorizontalDataTable dataBody() {
    return HorizontalDataTable(
      leftHandSideColumnWidth: fieldWidth[0],
      rightHandSideColumnWidth:
          fieldWidth.skip(1).reduce((value, element) => value + element),
      isFixedHeader: true,
      headerWidgets: _getTitleWidget(),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: _generateRightHandSideColumnRow,
      itemCount:
          (_getUsersCount() + (editedUsers.keys.contains("NewUser") ? 1 : 0)),
      rowSeparatorWidget: const Divider(
        color: Colors.black54,
        height: 1.0,
        thickness: 0.0,
      ),
      leftHandSideColBackgroundColor: const Color(0xFFFFFFFF),
      rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
      verticalScrollbarStyle: ScrollbarStyle(
        thumbColor: Colors.grey,
        isAlwaysShown: true,
        thickness: scrolBarThickness,
        radius: Radius.circular(scrolBarThickness / 2),
      ),
      horizontalScrollbarStyle: ScrollbarStyle(
        thumbColor: Colors.grey,
        isAlwaysShown: true,
        thickness: scrolBarThickness,
        radius: Radius.circular(scrolBarThickness / 2),
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
    return List<Widget>.generate(
        _getHeaderCount(),
        (iHeader) => Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  width: fieldWidth[iHeader],
                  height: titleHeight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      child: Text(
                        _getHeaderTitle(iHeader),
                        style: _getHeaderTextStyle(iHeader),
                      ),
                      alignment: Alignment.centerLeft,
                      width: paddingLeft +
                          headerTextWidth[iHeader] +
                          charWidth / 2,
                      padding: EdgeInsets.fromLTRB(paddingLeft, 0, 0, 0),
                    ),
                    Tooltip(
                        message: "Sort",
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: Size(charWidth, titleHeight),
                            fixedSize: Size(charWidth, titleHeight),
                          ),
                          child: Transform.scale(
                              scale: 1.0,
                              child: Icon(
                                  _getHeaderKey(iHeader) == sortKey &&
                                          sortOrder != 0
                                      ? (sortOrder == 1
                                          ? Icons.south
                                          : Icons.north)
                                      : Icons.sort,
                                  color: Colors.black,
                                  size: charWidth)),
                          onPressed: () {
                            sortOrder += 1;
                            if (sortOrder == 2) sortOrder = -1;
                            sortKey = sortOrder == 0
                                ? sortKey = ''
                                : _getHeaderKey(iHeader);
                            sortType = _getHeaderSort(iHeader);
                            setState(() {});
                          },
                        )),
                    Tooltip(
                        message: "Filter",
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: Size(charWidth, titleHeight),
                            fixedSize: Size(charWidth, titleHeight),
                          ),
                          child: Transform.scale(
                              scale: 1.0,
                              child: Icon(
                                  headerToFilter[iHeader]
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_outlined,
                                  color: Colors.black,
                                  size: charWidth)),
                          onPressed: () {
                            headerToFilter[iHeader] = !headerToFilter[iHeader];
                            setState(() {});
                          },
                        )),
                  ])),
              Visibility(
                visible: headerToFilter.contains(true),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                        width: fieldWidth[iHeader],
                        height: rowHeight,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(
                            paddingLeft, rowHeight / 5, 0, rowHeight / 5),
                        child: TextFormField(
                          controller: TextController(
                            text: filterToFilter[iHeader],
                          ),
                          onChanged: (value) {
                            filterToFilter[iHeader] = value;
                            setState(() {});
                          },
                          style: _getFieldTextStyle(iHeader),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              border: headerToFilter[iHeader]
                                  ? const OutlineInputBorder()
                                  : InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 3),
                              isDense: true),
                        ))),
              )
            ]));
  }

  Widget _generateFirstColumnRow(BuildContext context, int iUser) {
    return SizedBox(
        width: fieldWidth[0],
        height: rowHeight,
        child: Row(
          children: <Widget>[
            Container(
              child: _generateTextFormField(context, iUser, 0),
              width: fieldWidth[0] - charWidth - charWidth - charWidth / 2,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(paddingLeft, 0, 0, 0),
            ),
            Visibility(
                visible: isInEdit(iUser),
                child: Tooltip(
                    message: "Save",
                    child: SizedBox(
                        width: charWidth,
                        child: TextButton(
                          child: Icon(Icons.save,
                              color: Colors.green, size: charWidth),
                          style: TextButton.styleFrom(
                            minimumSize: Size(charWidth, rowHeight),
                            fixedSize: Size(charWidth, rowHeight),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () async {
                            if (isInEdit(iUser)) {
                              if (editedUsers.keys.contains("NewUser")) {
                                addUser(iUser);
                                editedUsers.remove("NewUser");
                              } else {
                                updateUser(iUser);
                                editedUsers.remove(getUserID(iUser));
                              }
                            }
                            setState(() {});
                          },
                        )))),
            Visibility(
                visible: isInEdit(iUser),
                child: Tooltip(
                    message: "Cancel",
                    child: SizedBox(
                        width: charWidth,
                        child: TextButton(
                          child: Icon(Icons.cancel,
                              color: Colors.red, size: charWidth),
                          style: TextButton.styleFrom(
                            minimumSize: Size(charWidth, rowHeight),
                            fixedSize: Size(charWidth, rowHeight),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () async {
                            if (isInEdit(iUser)) {
                              editedUsers.remove(getUserID(iUser));
                            }
                            setState(() {});
                          },
                        )))),
            Visibility(
                visible: !isInEdit(iUser), //isToEdit(iUser),
                child: Tooltip(
                    message: "Edit",
                    child: SizedBox(
                        width: charWidth,
                        child: TextButton(
                          child: Icon(Icons.edit,
                              color: (!isToEdit(iUser))
                                  ? Colors.grey
                                  : Colors.blue,
                              size: charWidth),
                          style: TextButton.styleFrom(
                            minimumSize: Size(charWidth, rowHeight),
                            fixedSize: Size(charWidth, rowHeight),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () async {
                            if (isInEdit(iUser) || progressImportExport > 0)
                              return null;
                            if (isToEdit(iUser)) {
                              editedUsers.addAll(
                                  {getUserID(iUser): getUserMap(iUser)});
                            }
                            setState(() {});
                          },
                        )))),
            Visibility(
                visible: !isInEdit(iUser), //isToEdit(iUser),
                child: Tooltip(
                    message: "Select",
                    child: SizedBox(
                        width: charWidth,
                        child: TextButton(
                          child: Icon(
                              selectedUsers.isNotEmpty &&
                                      selectedUsers.contains(getUserID(iUser))
                                  ? Icons.add_circle
                                  : Icons.add_circle_outline,
                              color: (!isToEdit(iUser))
                                  ? Colors.grey
                                  : Colors.blue,
                              size: charWidth),
                          style: TextButton.styleFrom(
                            minimumSize: Size(charWidth, rowHeight),
                            fixedSize: Size(charWidth, rowHeight),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () async {
                            if (isInEdit(iUser) || progressImportExport > 0)
                              return null;
                            if (isToEdit(iUser)) {
                              if (selectedUsers.contains(getUserID(iUser))) {
                                selectedUsers.remove(getUserID(iUser));
                              } else {
                                selectedUsers.add(getUserID(iUser));
                              }
                            }
                            setState(() {});
                          },
                        )))),
          ],
        ));
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int iUser) {
    return Row(
      children: List<Widget>.generate(
          _getHeaderCount() - 1,
          (iHeader) => Container(
                child: _getHeaderType(iHeader + 1) == "list"
                    ? _generateDropdown(context, iUser, iHeader + 1)
                    : _generateTextFormField(context, iUser, iHeader + 1),
                width: fieldWidth[iHeader + 1],
                height: rowHeight,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(paddingLeft, 0, 0, 0),
              )),
    );
  }

  Widget _generateDropdown(BuildContext context, int iUser, int iHeader) {
    if (_canHeaderEdit(iHeader) &&
        editedUsers.keys.contains(getUserID(iUser))) {
      return SizedBox(
          height: rowHeight,
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
            value: getUserMapField(iUser, iHeader),
            isDense: true,
            iconSize: charWidth,
            onChanged: (value) {
              if (_canHeaderEdit(iHeader) &&
                  editedUsers.keys.contains(getUserID(iUser))) {
                setUserMapField(iUser, iHeader, value!);
                setState(() {});
              }
            },
            // selectedItemBuilder: (BuildContext context) {
            //   return _getHeaderChoices(iHeader).map((String value) {
            //     return Container(
            //         alignment: Alignment.centerRight,
            //         child: Text(value, style: style: _getFieldTextStyle(iHeader)));
            //   }).toList();
            // },
            items: _getHeaderChoices(iHeader).map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: _getFieldTextStyle(iHeader)),
              );
            }).toList(),
          )));
    } else {
      return _generateTextFormField(context, iUser, iHeader);
    }
  }

  Widget _generateTextFormField(BuildContext context, int iUser, int iHeader) {
    return TextFormField(
      //  initialValue:
      //      getUserMapField(iUser, iHeader),
      controller: TextEditingController(
        text: getUserMapField(iUser, iHeader),
      ),
      onChanged: (value) {
        setUserMapField(iUser, iHeader, value);
      },
      enabled: _canHeaderEdit(iHeader) &&
          editedUsers.keys.contains(getUserID(iUser)),
      style:
          _canHeaderEdit(iHeader) && editedUsers.keys.contains(getUserID(iUser))
              ? _getEditedFieldTextStyle(iHeader)
              : _getFieldTextStyle(iHeader),
      decoration:
          const InputDecoration(border: InputBorder.none, isDense: true),
      //textAlignVertical: TextAlignVertical.center,
      // inputFormatters: [
      //   recordField.bEditable && recordField.bNumeric
      //       ? FilteringTextInputFormatter.digitsOnly
      //       : FilteringTextInputFormatter.singleLineFormatter
      // ],
      // validator: (value) {
      //   if (value!.isEmpty) {
      //     return 'Enter last Name';
      //   }
      //   return null;
      // },
      onTap: () async {
        if (_canHeaderEdit(iHeader)) {
          if (_getHeaderType(iHeader) == "date") {
            DateTime? currentDate =
                DateTime.parse(getUserMapField(iUser, iHeader));

            FocusScope.of(context).requestFocus(FocusNode());

            DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));

            if (newDate != null && newDate != currentDate) {
              setUserMapField(
                  iUser, iHeader, newDate.toString().substring(0, 10));
            }
          }
        }
      },
    );
  }

  TextStyle _getHeaderTextStyle(int iHeader) {
    return TextStyle(
        decoration: TextDecoration.none,
        color: charHeaderColor,
        fontStyle: charHeaderStyle,
        fontWeight: charHeaderWeight,
        fontSize: charWidth,
        fontFamily: charHeaderFamily);
  }

  TextStyle _getFieldTextStyle(int iHeader) {
    return TextStyle(
        decoration: TextDecoration.none,
        color: charColor,
        fontStyle: charStyle,
        fontWeight: charWeight,
        fontSize: charWidth,
        fontFamily: charFamily);
  }

  TextStyle _getEditedFieldTextStyle(int iHeader) {
    return TextStyle(
        decoration: TextDecoration.underline,
        color: charColor,
        fontStyle: charStyle,
        fontWeight: charWeight,
        fontSize: charWidth,
        fontFamily: charFamily);
  }

  bool callbackImportExport(double progressValue) {
    if (abortImportExport) {
      abortImportExport = false;
      return false;
    } else {
      progressImportExport = progressValue;
      setState(() {});
      return true;
    }
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
