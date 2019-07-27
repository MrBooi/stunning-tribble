import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      hangleSigin(account);
    }, onError: (err) {
      print('Error: $err');
    });
    // ReAuthenticate user when app is open
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      hangleSigin(account);
    }).catchError((err) {
      print('Error: $err');
    });
  }

  hangleSigin(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
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
    final GoogleSignInAccount user = googleSignIn.currentUser;
    final DocumentSnapshot doc = await usersRef.document(user?.id).get();
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount()),
      );

      usersRef.document(user?.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user?.photoUrl,
        'email': user?.email,
        'displayName': user?.displayName,
        'bio': '',
        'timestamp': timestamp
      });
    }
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  login() {
    // open google modal
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(microseconds: 300), curve: Curves.easeInOut);
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // Timeline(),
          RaisedButton(
            child: Text('LogOut'),
            onPressed: logOut,
          ),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile()
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
    // return RaisedButton(
    //   child: Text('LogOut'),
    //   onPressed: logOut,
    // );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Crossy Social App',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 80, color: Colors.white),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover),
                ),
              ),
            )
          ],
        ),
      ),
    );
    // Text('UnAuthenticated');
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}