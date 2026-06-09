import 'package:get/get.dart';
import 'langs/en.dart' as lang_en;
import 'langs/yo.dart' as lang_yo;
import 'langs/ha.dart' as lang_ha;
import 'langs/ig.dart' as lang_ig;

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': lang_en.en,
        'yo_NG': lang_yo.yo,
        'ha_NG': lang_ha.ha,
        'ig_NG': lang_ig.ig,
      };
}
