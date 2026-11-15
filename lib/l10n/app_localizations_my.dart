// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'ဂျီဒိုနပ်စ်';

  @override
  String get homeTab => 'ပင်မ';

  @override
  String get onboardingTitle => 'နေ့တိုင်း စားလိုက်ရင် ပျော်စရာ';

  @override
  String get getStarted => 'စတင်ရအောင်';

  @override
  String get logIn => 'အကောင့်ဝင်မယ်';

  @override
  String get alreadyHaveAccount => 'အကောင့် ရှိပြီးသား ဖြစ်လား?';

  @override
  String get continueLabel => 'ဆက်လုပ်မယ်';

  @override
  String get phoneTitle => 'သင့်ဖုန်းနံပါတ် ဘယ်လောက်လဲ?';

  @override
  String get phoneHint => 'ဖုန်းနံပါတ်';

  @override
  String get phoneInvalid =>
      '+95 နောက်မှာ ၉ ဖြင့် စပြီး ဂဏန်း ၇ မှ ၉ လုံး ထည့်ပါ';

  @override
  String get verifyTitle => 'သင့်နံပါတ်ကို အတည်ပြုပါ';

  @override
  String verifyHint(Object phone) {
    return '$phone သို့ ပို့ထားသော ဂဏန်း ၆ လုံးကို ထည့်ပါ';
  }

  @override
  String get resend => 'ပြန်ပို့မယ်';

  @override
  String resendIn(Object time) {
    return '$time အတွင်း ပြန်ပို့မယ်';
  }

  @override
  String get otpInvalid => 'ကုဒ် မမှန်ပါ။ ထပ်စမ်းကြည့်ပါ။';

  @override
  String get otpLocked =>
      'အလွန်အကျွံ မှားခဲ့ပါတယ်။ ကုဒ်အသစ် ရယူရန် ပြန်ပို့ကို နှိပ်ပါ။';

  @override
  String get firstNameLabel => 'အမည် ပထမစကားလုံး';

  @override
  String get lastNameLabel => 'အမည် ဒုတိယစကားလုံး';

  @override
  String get nameRequired => 'အမည် ပထမစကားလုံး လိုအပ်ပါတယ်';

  @override
  String get nameInvalidChars => 'စာလုံးများနှင့် ကွက်လပ်သာ ဖြစ်ရမည်';

  @override
  String get nameTooLong => 'စာလုံး ၅၀ သို့မဟုတ် ထက်နည်းအောင် သုံးပါ';

  @override
  String get dobTitle => 'မွေးသက္ကရာဇ် ဘယ်နေ့လဲ?';

  @override
  String get selectDate => 'ရက်စွဲ ရွေးပါ';

  @override
  String get dobInvalid => 'မှန်ကန်သော ရက်စွဲ ထည့်ပါ';

  @override
  String get dobFuture => 'အနာဂတ်ရက်စွဲ မဖြစ်နိုင်ပါ';

  @override
  String dobTooYoung(Object age) {
    return 'အသက် $age နှစ် ပြည့်မှ ဖြစ်မည်';
  }

  @override
  String get welcomeTitle => 'ဂျီဒိုနပ်စ် ကမ္ဘာထဲ ကြိုဆိုပါတယ်';

  @override
  String get letsExplore => 'ရှာဖွေကြည့်ရအောင်';

  @override
  String get seasonalSpecials => 'ရာသီအလိုက် အထူးများ';

  @override
  String get popular => 'လူကြိုက်များ';

  @override
  String get orderAgain => 'ထပ်မှာမယ်';

  @override
  String nearbyShopsTitle(Object count) {
    return 'သင့်အနီးတွင် ဂျီဒိုနပ်ဆိုင် $count ဆိုင် ရှိပါတယ်';
  }

  @override
  String get exploreNow => 'ယခု ကြည့်မယ်';

  @override
  String get orderOnline => 'အွန်လိုင်း မှာမယ်';

  @override
  String get whatsThis => 'ဒါက ဘာလဲ?';

  @override
  String get addToCart => 'စျေးခြင်းတောင်းထဲ ထည့်မယ်';

  @override
  String get total => 'စုစုပေါင်း';

  @override
  String addedToCart(Object count) {
    return '$count ခု ထည့်ပြီးပါပြီ';
  }

  @override
  String get quantity => 'အရေအတွက်';

  @override
  String get rewardsTitle => 'ဆုလက်ဆောင်များ';

  @override
  String get eatMoreEarnMore => 'စားလေ ရလေ';

  @override
  String get giftTab => 'လက်ဆောင်';

  @override
  String pointsToNextTier(Object points, Object tier) {
    return '$tier သို့ ရောက်ရန် $points မှတ်';
  }

  @override
  String get challengeComplete => 'ပြီးပါပြီ';

  @override
  String get earn => 'ရယူမယ်';

  @override
  String get settings => 'ဆက်တင်';

  @override
  String get orders => 'မှာယူမှုများ';

  @override
  String get cartTab => 'ခြင်းတောင်း';

  @override
  String get notifications => 'အသိပေးချက်များ';

  @override
  String get logOut => 'အကောင့်မှ ထွက်မယ်';

  @override
  String get offline => 'အင်တာနက် မရှိပါ';

  @override
  String get retry => 'ထပ်ကြိုးစားမယ်';

  @override
  String get errorGeneric => 'တစ်ခုခု မှားနေပါတယ်';

  @override
  String get emptyGeneric => 'ဘာမှ မရှိသေးပါ';

  @override
  String get notFound => 'မတွေ့ပါ';

  @override
  String get socialLoginComingSoon => 'လူမှုကွန်ရက် ဝင်ရောက်မှု မကြာမီ ရရှိမည်';

  @override
  String get legalComingSoon => 'ဤလင့်ခ်သည် သရုပ်ပြအတွက်သာ ဖြစ်သည်';

  @override
  String get loggedOutMessage => 'အကောင့်မှ ထွက်ပြီးပါပြီ';
}
