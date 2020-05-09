import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import '../widgets/progress.dart';

// final usersRef = Firestore.instance.collection('users');
final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    // getUsers();
    // getUsersById();
    // createUser();
    // updateUser();
    // deleteUser();
    super.initState();
  }

  // createUser() async {
  //   await usersRef.document("dseaeaz").setData({
  //     'username': 'Shekhar',
  //     'postsCount': 0,
  //     'isAdmin': false,
  //   });
  // }

  // updateUser() async {
  //   final doc = await usersRef.document("dseaeaz").get();
  //   if (doc.exists)
  //     doc.reference.updateData({
  //       'username': 'Sahil',
  //       'postsCount': 0,
  //       'isAdmin': false,
  //     });
  // }

  // deleteUser() async {
  //   final DocumentSnapshot doc = await usersRef.document("dseaeaz").get();
  //   if (doc.exists) doc.reference.delete();
  // }

  // getUsersById() async {
  //   final String id = 'ndEJE4shvolzf0r7kIUG';
  //   DocumentSnapshot doc = await usersRef.document(id).get();
  //   // .then((DocumentSnapshot doc) {
  //   //   print(doc.data);
  //   //   print(doc.documentID);
  //   //   print(doc.exists);
  //   // }
  //   // );
  //   print(doc.data);
  //   print(doc.documentID);
  //   print(doc.exists);
  // }

  // getUsers() async {
  //   final QuerySnapshot snapshot = await usersRef
  //       // .where("username", isEqualTo: "Gaurav")
  //       // .where("isAdmin", isEqualTo: true)
  //       // .where("postsCount", isGreaterThan: 0)
  //       // .limit(1)
  //       // .orderBy("postsCount", descending: false)
  //       .getDocuments();
  //   //     .then((QuerySnapshot snapshot) {
  //   //   snapshot.documents.forEach((DocumentSnapshot doc) {
  //   //     // print(doc.data);
  //   //     // print(doc.documentID);
  //   //     // print(doc.exists);
  //   //   });
  //   // });
  //   setState(() {
  //     users = snapshot.documents;
  //   });
  // }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Text('Timeline'),
      //  Container(
      //   child: ListView(
      //     children: users.map((user) => Text(user['username'])).toList(),
      //   ),
      // ),
      //     StreamBuilder<QuerySnapshot>(
      //   stream: usersRef.snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return circularProgress();
      //     }
      //     final List<Text> children = snapshot.data.documents
      //         .map((doc) => Text(doc['username']))
      //         .toList();
      //     return Container(
      //       child: ListView(
      //         children: children,
      //       ),
      //     );
      //   },
      // ),
    );
  }
}