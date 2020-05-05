import 'package:flutter/material.dart';

header(BuildContext context, {bool isAppTitle = false, String titletext}) {
  return AppBar(
    title: Text(
      isAppTitle ? 'Souvien' : titletext,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : '',
        fontSize: isAppTitle ? 50 : 22,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
