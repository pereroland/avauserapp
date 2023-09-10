import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> clanListLoad(context) async {
  Map myclanList = jsonDecode(await getApiDataRequest(myclanListUrl, context));
  String status = myclanList['status'];
  String message = myclanList['message'];
  if (status == success_status) {
    return myclanList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return myclanList;
  } else if (status == expire_token_status) {
    jsonDecode(await apiRefreshRequest(context));
    clanListLoad(context);
  } else {
    showToast(message);
    return myclanList;
  }
}
