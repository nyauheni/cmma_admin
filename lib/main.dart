import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cmma_admin/reservation.dart';
import 'package:cmma_admin/users.dart';

void main() async {
  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyBm54--sB48BMZmmxWf9lymsEyofP8sms4',
      appId: '1:543903890015:web:1277c5062c276f8ab4f9ea',
      messagingSenderId: '543903890015',
      projectId: 'cmma-1e6df',
    ));
  }

  runApp(MaterialApp(
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (currentIndex == 0)
            ? const Text("Platzreservierung")
            : Text(Users.title),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.help))],
      ),
      body: (currentIndex == 0) ? Reservation(10) : const Users(),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() => currentIndex = index);
          },
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Reservierung"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_box), label: "Users"),
          ]),
    );
  }
}
