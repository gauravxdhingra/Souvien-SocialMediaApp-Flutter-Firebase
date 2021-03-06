import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'search.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');

final DateTime timestamp = DateTime.now();
User currentUser;

final StorageReference storageRef = FirebaseStorage.instance.ref();

class _HomeState extends State<Home> {
  bool isAuth = false;
  int pageIndex = 0;
  PageController pageController;
  bool userAvailable = false;

  @override
  void initState() {
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) {
        print('Error signing in: $err');
      },
    );
    googleSignIn
        .signInSilently(
      suppressErrors: false,
    )
        .then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('SilentSignInError $err');
    });
    super.initState();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      // print('$account');
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // check if user exists in users collection in database(acc to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if (!doc.exists) {
      // if the user doesn't exist => create account page
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp
      });
      // make user their own follower to include own posts in timeline

      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});
      doc = await usersRef.document(user.id).get();
    }
    // get username from create account, use it to make new users collection
    currentUser = User.fromDocument(doc);
    // print(currentUser);
    setState(() {
      userAvailable = true;
    });
    print(currentUser.username);
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          // Container(
          //   height: 50,
          //   width: 200,
          //   child: Center(
          //       child: GestureDetector(
          //     child: Text('Logout'),
          //     onTap: logout(),
          //   )),
          // ),
          ActivityFeed(),
          Upload(
            currentUser: currentUser,
          ),
          Search(),
          Profile(
            profileId: currentUser.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        // physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
    // RaisedButton(
    //   onPressed: logout,
    //   child: Text('Logout'),
    // );
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Souvien',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (isAuth && userAvailable) ? buildAuthScreen() : buildUnAuthScreen();
  }
}
