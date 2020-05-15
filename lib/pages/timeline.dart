import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import '../widgets/progress.dart';
import 'home.dart';

// final usersRef = Firestore.instance.collection('users');
final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  const Timeline({Key key, this.currentUser}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  // List<dynamic> users = [];
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    // getUsers();
    // getUsersById();
    // createUser();
    // updateUser();
    // deleteUser();
    getTimeline();
    getFollowing();
    super.initState();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
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

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else
      return ListView(
        children: posts,
      );
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy("timestamp", descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach(
          (doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);
            // remove auth user from recommended list

            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResult userResult = UserResult(
                user: user,
              );
              userResults.add(userResult);
            }
          },
        );
        return Container(
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Users To Follow',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: userResults,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
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
