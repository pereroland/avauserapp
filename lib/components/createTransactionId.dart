import 'package:flutter/cupertino.dart';

String selectDatePick(BuildContext context, type) {
  var datetime = DateTime.now().millisecondsSinceEpoch;
  var totlaData = type + "_" + datetime.toString();
  return totlaData;
}
