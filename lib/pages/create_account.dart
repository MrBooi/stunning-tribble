import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String username;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final snackBar = SnackBar(
        content: Text('Welcome $username!'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Set up your Profile'),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onSaved: (value) => username = value,
                        autovalidate: true,
                        validator: (value) {
                          if (value.trim().length < 3 || value.isEmpty) {
                            return 'username is to short';
                          } else if (value.trim().length > 12) {
                            return 'username is to long';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Must be at least 3 Characters"),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
