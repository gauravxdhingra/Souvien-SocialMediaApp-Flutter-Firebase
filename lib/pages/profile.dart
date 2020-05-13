import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final profileId;

  const Profile({Key key, this.profileId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;

  String postOrientation = "grid";
  bool isLoading = false;
  int postsCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .getDocuments();

    setState(() {
      isLoading = false;
      postsCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  buildProfileButton() {
    // return Text('Profile Button');
    // viewing own profile => edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner)
      return buildButton(text: 'Edit Profile', function: editProfile);
  }

  Container buildButton({String text, Function function}) {
    return Container(
      width: 250,
      height: 27,
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: currentUserId),
      ),
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return circularProgress();
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('Posts', postsCount),
                            buildCountColumn('Followers', 0),
                            buildCountColumn('Following', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: 12,
                ),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: 4,
                ),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: 2,
                ),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePost() {
    if (isLoading) return circularProgress();
    // return Column(
    //   children: posts,
    // );
    if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(
            child: PostTile(
          post: post,
        )));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    if (postOrientation == 'list')
      return Column(
        children: posts,
      );
  }

  setPostsOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed: () => setPostsOrientation('grid'),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () => setPostsOrientation('list'),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0,
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}
