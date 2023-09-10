// import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:local_auth/local_auth.dart';

// BiometricStorageFile authStorage;
// BiometricStorageFile storage;
// BiometricStorageFile customPrompt;
// BiometricStorageFile noConfirmation;
final String baseName = 'ecity_user';

Future<bool> checkAuthenticate() async {
  final response = await LocalAuthentication().isDeviceSupported();
  return response;
}

Future<bool> authenticated() async {
  LocalAuthentication auth = LocalAuthentication();
  try {
    bool authenticated = false;
    authenticated = await auth.authenticate(
        localizedReason: "Scan your finger to authenticate",
        options:
            AuthenticationOptions(useErrorDialogs: true, stickyAuth: true));
    return authenticated;
  } on PlatformException catch (e) {
    return false;
  }
}

Future<bool> checkForm() async {
  final authenticate = await checkAuthenticate();
  if (authenticate) {
    return true;
  } else if (!authenticate) {
    return false;
  } else {
    return false;
  }

/*
    _logger.info('initiailzed $baseName');
*/
}
