import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({Key key, this.postId, this.postOwnerId, this.postMediaUrl})
      : super(key: key);

  @override
  CommentsState createState() => CommentsState(
        postMediaUrl: postMediaUrl,
        postId: postId,
        postOwnerId: postOwnerId,
      );
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});
  TextEditingController commentController = TextEditingController();

  StreamBuilder buildComments(context) {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarPhotoUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;

    if (isNotPostOwner) {
      activityFeedRef.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'comment': commentController.text,
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': timestamp,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(context),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Write a Comment...',
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarPhotoUrl;
  final String comment;
  final Timestamp timestamp;

  Comment(
      {this.username,
      this.userId,
      this.avatarPhotoUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      avatarPhotoUrl: doc['avatarPhotoUrl'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            comment,
            // style: TextStyle(color: Colors.blue),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarPhotoUrl),
          ),
          subtitle: Text(
            timeago.format(
              timestamp.toDate(),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
