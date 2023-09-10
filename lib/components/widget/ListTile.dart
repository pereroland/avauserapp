import 'package:flutter/material.dart';

Container listTile(context,{var keyText, var valueText}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    child: Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              keyText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            )),
        Expanded(
            flex: 1,
            child: Text(
              valueText,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20.0),
            )),
      ],
    ),
  );
}
