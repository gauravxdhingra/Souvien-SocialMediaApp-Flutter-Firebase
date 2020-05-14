// import 'dart:html';
import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.desc,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      desc: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) return 0;

    int count = 0;

    // if key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count++;
      }
    });

    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        desc: this.desc,
        mediaUrl: this.mediaUrl,
        likesCount: getLikeCount(this.likes),
        likes: this.likes,
      );
}

class _PostState extends State<Post> {
  final String currentuserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  int likesCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  String username1;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.desc,
    this.mediaUrl,
    this.likesCount,
    this.likes,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        User user = User.fromDocument(snapshot.data);
        username1 = user.username;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => print('Show Profile'),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('Deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentuserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to post owner's activity feed only if comment made by other users (to avoid own like notification)

    bool isNotPostOwner = currentuserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentuserId] == true;
    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentuserId': false});

      removeLikeFromActivityFeed();

      setState(() {
        likesCount--;
        isLiked = false;
        likes[currentuserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentuserId': true});
      addLikeToActivityFeed();

      setState(() {
        likesCount++;
        isLiked = true;
        likes[currentuserId] = true;
        showHeart = true;
      });
      Timer(
          Duration(
            milliseconds: 500,
          ), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Image.network(mediaUrl),
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  tween: Tween(
                    begin: 0.8,
                    end: 1.2,
                  ),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text(''),
          // showHeart
          // ? Icon(
          //     Icons.favorite,
          //     size: 80,
          //     color: Colors.red,
          //   )
          //     : Text(''),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 40,
                left: 20,
              ),
            ),
            GestureDetector(
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
              onTap: handleLikePost,
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 20,
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue[900],
              ),
              onTap: () => showComments(
                context,
                postId: postId,
                onwerId: ownerId,
                mediaUrl: mediaUrl,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likesCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(desc),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentuserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(
  BuildContext context, {
  String postId,
  String onwerId,
  String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: onwerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
