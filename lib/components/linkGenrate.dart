import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> linkGeneratePaymentShare() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var authtoken = prefs.getString('authtoken');
  var link =
      "https://alphaxtech.net/ecity/index.php/web/CinetPay_by_link/createSignature?user_id=$authtoken&merchant_id=0&payment_mode=phone&payment_for=7&reference_id=0&lang=${allTranslations.locale}";
  var titleTxt = allTranslations.text('youcanpaymebythislink');
  var title = "$titleTxt $link";
  var subject = allTranslations.text('PaymentLink');
  Share.share(title, subject: subject);
}
