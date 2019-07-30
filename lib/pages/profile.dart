import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

import '../models/user.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  String postViewOrientation = 'grid';
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchProfilePost();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followerRef
        .document(widget?.profileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followerRef
        .document(widget?.profileId)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot isFollower = await followerRef
        .document(widget?.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();

    setState(() {
      isFollowing = isFollower.exists;
    });
  }

  fetchProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .document(widget?.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
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
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  Container buildButton({String label, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            label,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isFollowing ? Colors.black : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditProfile(currentUserId: currentUserId);
    }));
  }

  handleUnFollowUser() {
    setState(() {
      isFollowing = false;
    });
    // follower
    followerRef
        .document(widget?.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) doc.reference.delete();
    });
    // following collection

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget?.profileId)
        .get()
        .then((doc) {
      if (doc.exists) doc.reference.delete();
    });
    // add notification

    activityFeedRef
        .document(widget?.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) doc.reference.delete();
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // follower
    followerRef
        .document(widget?.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // following collection

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget?.profileId)
        .setData({});

    // add notification

    activityFeedRef
        .document(widget?.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget?.profileId,
      'username': currentUser?.username,
      'userId': currentUser?.id,
      'userProfileImag': currentUser.photoUrl,
      'timestamp': timestamp
    });
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(label: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      return buildButton(label: 'unFollow', function: handleUnFollowUser);
    } else if (!isFollowing) {
      return buildButton(label: 'Follow', function: handleFollowUser);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: userRef.document(currentUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user?.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              buildCountColumn('posts', postCount),
                              buildCountColumn('follwers', followerCount),
                              buildCountColumn('following', followingCount),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[buildProfileButton()],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user?.username,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user?.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user?.bio,
                  ),
                ),
              ],
            ),
          );
        });
  }

  buildEmptyState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'No Posts',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  buidProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildEmptyState();
    } else if (postViewOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
            child: PostTile(post),
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postViewOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostViewOreintation(String type) {
    setState(() {
      this.postViewOrientation = type;
    });
  }

  buildTogglePostView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postViewOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setPostViewOreintation('grid'),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postViewOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setPostViewOreintation('list'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: 'Profile'),
        body: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildTogglePostView(),
            Divider(
              height: 0.0,
            ),
            buidProfilePosts(),
          ],
        ));
  }
}
