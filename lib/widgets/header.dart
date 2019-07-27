import 'package:flutter/material.dart';

header(context, {bool isAppTitle = false, String titleText}) {
  return AppBar(
    //  leading: isAppTitle ? Container() : Icon(Icons.arrow_back),
    title: Text(
      isAppTitle ? 'Crossy Social App' : titleText,
      style: TextStyle(
          color: Colors.white,
          fontFamily: isAppTitle ? 'Signatra' : '',
          fontSize: isAppTitle ? 50.0 : 22.0),
    ),
    centerTitle: isAppTitle ? true : false,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
