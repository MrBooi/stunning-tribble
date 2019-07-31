import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> postList;
  List<String> followingList = [];
  @override
  void initState() {
    super.initState();
    getuserTimeline();
    getFollowingUsers();
  }

  getFollowingUsers() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser?.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  getuserTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser?.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> postList =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.postList = postList;
    });
  }

  createUser() async {
    await userRef.add({});
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          userRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser?.id == user?.id;
          final bool isFollowingUser = followingList.contains(user?.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
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
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Users To Follow',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0),
                    )
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

  buildUserTimeline() {
    if (postList == null) {
      return circularProgress();
    }
    if (postList.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: postList);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true, titleText: 'Timelile'),
        body: RefreshIndicator(
          onRefresh: () => getuserTimeline(),
          child: buildUserTimeline(),
        ));
  }
}
