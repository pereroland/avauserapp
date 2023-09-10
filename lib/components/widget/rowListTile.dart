import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container walletRow({var keyName,required Icon icon, VoidCallback? onTap}) {
  return Container(
    child: InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 5.0),
        child: Row(
          children: [
            Expanded(
                flex: 9,
                child: Text(
                  keyName,
                  style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.bold),
                )),
            Expanded(flex: 1, child: icon),
          ],
        ),
      ),
      onTap: onTap,
    ),
  );
}
