import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

launchURL(link_url) async {
  if (Platform.isAndroid) {
    await launch(link_url);
  } else if (Platform.isIOS) {
    await launch(link_url);
  } else {
    throw 'Could not launch $link_url';
  }
}
