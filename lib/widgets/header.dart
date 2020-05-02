import 'package:flutter/material.dart';

header(BuildContext context) {
  return AppBar(
    title: Text(
      'Souvien',
      style: TextStyle(
        color: Colors.white,
        fontFamily: "Signatra",
        fontSize: 50,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
