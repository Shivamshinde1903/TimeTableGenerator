import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void addData(Map<String, dynamic> data) {
  FirebaseFirestore.instance
      .collection("users")
      .doc(data['uid'])
      .set(data)
      .then((value) => print("Data added successfully. Document ID  "))
      .catchError((error) => print("Failed to add data: $error"));
}

void updateData(Map<String, dynamic> data, String docId) {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: uid)
      .get()
      .then((querySnapshot) {
    for (var docSnapshot in querySnapshot.docs) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(docSnapshot.data()['uid'])
          .update(data)
          .then((value) => print("Data updated successfully."))
          .catchError((error) => print("Failed to update data: $error"));
    }
  }).catchError((error) => print("Failed to update data: $error"));
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
Future<List> fetchData() async {
  try {
    List professors = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    querySnapshot.docs.forEach((DocumentSnapshot document) {
      professors.add(document.data());
    });
    return professors;
  } catch (error) {
    print(error);
    return [];
  }
}
