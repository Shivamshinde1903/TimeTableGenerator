import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  runApp(MyApp());
}

void addData() {
  FirebaseFirestore.instance.collection("users").add({
    "first": "Ada",
    "last": "Lovelace",
    "born": 1815
  })
      .then((value) => print("Data added successfully. Document ID: ${value.id}"))
      .catchError((error) => print("Failed to add data: $error"));
}

// void createDatabaseAndAddData() {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   // Create a new collection called "users"
//   CollectionReference users = firestore.collection('users');
//
//   // Add a new document with a generated ID
//   users
//       .add({
//     "first": "Ada",
//     "last": "Lovelace",
//     "born": 1815
//   })
//       .then((DocumentReference document) {
//     print('Document added with ID: ${document.id}');
//   })
//       .catchError((error) {
//     print('Failed to add document: $error');
//   });
// }
Future<void> fetchDataByName(String firstName) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('first', isEqualTo: firstName)
        .get();

    querySnapshot.docs.forEach((DocumentSnapshot document) {
      print('First Name: ${document.data()['first']}');
      print('Last Name: ${document.data()['last']}');
      print('Born: ${document.data()['born']}');
      print('-----');
    });
  } catch (error) {
    print('Failed to fetch data: $error');
  }
}


