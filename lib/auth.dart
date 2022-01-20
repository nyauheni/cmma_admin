// import 'package:cmmaa/database.dart';
// import 'package:firebase_core/firebase_core.dart';

// late final FirebaseAuth auth; //Firestore.FirebaseAuth.instance;
// const String usercollection = "Users";

// Future<String> signIn(String email, String password) async {
//   if (email.isEmpty | password.isEmpty) {
//     return "Email und Passwort dürfen nicht leer sein";
//   }
//   try {
//     await auth.signIn(email, password);
//     return "Willkommen zurück";
//   } on Exception catch (e) {
//     if (e.toString() == 'invalid-email') {
//       return 'Email ist falsch';
//     } else if (e.toString() == 'user-not-found') {
//       return 'Kein Nutzer mit dieser Email gefunden';
//     } else if (e.toString() == 'wrong-password') {
//       return 'Passwort ist falsch';
//     }
//   }
//   return "Fehler aufgetreten";
// }

// // returns the UID of the User's FirebaseAuth and the User's DocumentID
// Future<String?> signUp(String email, String password) async {
//   try {
//     return (await auth.signUp(email, password)).id;
//   } on Exception catch (e) {
//     if (e.toString() == 'weak-password') {
//       print('The password provided is too weak.');
//     } else if (e.toString() == 'email-already-in-use') {
//       print('The account already exists for that email.');
//     }
//   } catch (e) {
//     print(e);
//   }
//   print("signUp uid is null");
//   return null;
// }

// Future<String> sendEmailToResetPassword(String email) async {
//   if (email.isEmpty) {
//     return "Email darf nicht leer sein";
//   }
//   try {
//     await auth.requestEmailVerification();
//     return "Passwort wurde gesendet.";
//   } on Exception catch (e, _) {
//     if (e.toString().contains("invalid-email")) {
//       return "Diese Email ist falsch";
//     }
//     if (e.toString().contains("user-not-found")) {
//       return "Es wurde kein registrierter Nutzer gefunden";
//     }
//   }
//   return "";
// }

// // returns true if success
// Future<bool> createUser(
//     String email,
//     String password,
//     String firstName,
//     String lastName,
//     String partner,
//     int cost,
//     int extraCost,
//     String membership,
//     String birthday,
//     String birthplace,
//     String city,
//     String adress,
//     String telefon,
//     String bankOwner,
//     String bank,
//     String iban) async {
//   try {
//     String? uid = await signUp(email, password);
//     if (uid == null) {
//       return false;
//     }
//     await Firestore.instance.collection(usercollection).document(uid).set({
//       keyemail: email,
//       keyfirstname: firstName,
//       keylastname: lastName,
//       keypartner: partner,
//       keycost: cost,
//       keyextracost: extraCost,
//       keymembership: membership,
//       keybirthday: birthday,
//       keybirthplace: birthplace,
//       keycity: city,
//       keyadress: adress,
//       keytelefon: telefon,
//       keybankowner: bankOwner,
//       keybank: bank,
//       keyiban: iban
//     });
//     return true;
//   } catch (e) {
//     print(e.toString());
//     return false;
//   }
// }

// Future<bool> checkIfUserExists(String email) async {
//   // needs some work maybe
//   return (await Firestore.instance
//           .collection(usercollection)
//           .where(keyemail, isEqualTo: email)
//           .get())
//       .isNotEmpty;
// }
