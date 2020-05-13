import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

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

  buildComments() {
    return Text('Comments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
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
              onPressed: () => print('add comment'),
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
  @override
  Widget build(BuildContext context) {
    return Text('Comment');
  }
}
