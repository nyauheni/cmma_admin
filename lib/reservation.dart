import 'package:flutter/material.dart';

class Platz {
  final int id;
  final String name;
  final String email;
  final String phone;

  const Platz({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.phone = '',
  });
}

List<Platz> platzList = [];

class Reservation extends StatefulWidget {
  Reservation(count, {Key? key}) : super(key: key) {
    platzList.clear();
    for (int i = 0; i < count; i++) {
      platzList.add(Platz(
          id: i, name: i.toString(), email: i.toString(), phone: i.toString()));
    }
  }

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: List<TableRow>.generate(
        platzList.length,
        (index) {
          final person = platzList[index];
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                              title: const Text("Options"),
                              children: [
                                TextButton(
                                    onPressed: () {},
                                    child: const Text("Remove this Row")),
                              ],
                            ));
                  },
                  child:
                      Text(person.id.toString(), textAlign: TextAlign.center),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(person.name, textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(person.email, textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(person.phone, textAlign: TextAlign.center),
              ),
            ],
          );
        },
        growable: false,
      ),
    );
  }
}
