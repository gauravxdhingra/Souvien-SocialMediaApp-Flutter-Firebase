import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search For Users',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  clearSearch() {
    searchController.clear();
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
            // Text(
            //   'Find Users',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontStyle: FontStyle.italic,
            //     fontWeight: FontWeight.w600,
            //     fontSize: 60,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // List<Text> searchResults = [];
        // snapshot.data.documents.forEach((doc) {
        //   User user = User.fromDocument(doc);
        //   searchResults.add(Text(user.username));
        // });
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user: user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.5),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
