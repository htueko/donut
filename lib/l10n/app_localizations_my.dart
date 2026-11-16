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
  String get loggedOutMessage => 'အကောင့်မှ ထွက်ပြီးပါပြီ';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get theme => 'အပြင်အဆင်';

  @override
  String get darkTheme => 'မှောင်သော';

  @override
  String get lightTheme => 'အလင်း';

  @override
  String get systemTheme => 'စနစ်';

  @override
  String get english => 'အင်္ဂလိပ်';

  @override
  String get myanmar => 'မြန်မာ';

  @override
  String get max => 'အများဆုံး';

  @override
  String get register => 'မှတ်ပုံတင်မည်';

  @override
  String get phoneNotRegistered => 'ဖုန်းနံပါတ် မမှတ်ပုံတင်ရသေးပါ';

  @override
  String get points => 'မှတ်';

  @override
  String get newBadge => 'အသစ်';

  @override
  String get nameTitle => 'သင့်ကို ဘယ်လိုခေါ်ရမလဲ?';

  @override
  String get tierBronze => 'ကြေးဝါ';

  @override
  String get tierSilver => 'ငွေ';

  @override
  String get tierGold => 'ရွှေ';

  @override
  String get tierPlatinum => 'ပလက်တီနမ်';

  @override
  String get mmk => 'ကျပ်';

  @override
  String memberProgress(Object points, Object tier, Object toNext) {
    return '$points မှတ် · $tier သို့ $toNext';
  }

  @override
  String discountOff(Object percent) {
    return '$percent% လျှော့စျေး';
  }

  @override
  String productCode(Object code) {
    return 'ကုဒ် $code';
  }

  @override
  String get termsOfUse => 'အသုံးပြုမှု စည်းမျဉ်းများ';

  @override
  String get privacyPolicy => 'ကိုယ်ရေးအချက်အလက် မူဝါဒ';

  @override
  String get legalUpdated => 'နောက်ဆုံးပြင်ဆင်ခဲ့သည် ၁၅ နိုဝင်ဘာ ၂၀၂၆';

  @override
  String get termsIntro =>
      'ဤစည်းမျဉ်းများသည် J\'Donuts သရုပ်ပြအက်ပ်အတွက် နမူနာစာသားများသာ ဖြစ်ပြီး ဥပဒေအကြံပြုချက် မဟုတ်ပါ။';

  @override
  String get termsSection1Title => 'အက်ပ်ကို အသုံးပြုခြင်း';

  @override
  String get termsSection1Body =>
      'J\'Donuts သည် သရုပ်ပြဆိုင်သာ ဖြစ်သည်။ မီနူးကြည့်ခြင်း၊ မှာယူခြင်းနှင့် မှတ်များ စုဆောင်းခြင်း ပြုလုပ်နိုင်သည်။ အမှန်တကယ် ဝယ်ယူရန် မသုံးပါနှင့်။';

  @override
  String get termsSection2Title => 'မှာယူမှုနှင့် ငွေပေးချေမှု';

  @override
  String get termsSection2Body =>
      'စျေးနှုန်းများကို မြန်မာကျပ်ဖြင့် ပြသထားခြင်း ဖြစ်သည်။ ငွေအမှန် မကောက်ခံပါ။ မည်သည့်ဆိုင်သို့မဆို မှာယူမှု မပို့ပါ။';

  @override
  String get termsSection3Title => 'စည်းမျဉ်းများ ပြောင်းလဲခြင်း';

  @override
  String get termsSection3Body =>
      'အက်ပ် ပြောင်းလဲသည့်အခါ ဤစာမျက်နှာကို မွမ်းမံနိုင်သည်။ ထိပ်ရှိ နောက်ဆုံးပြင်ဆင်သည့်ရက်က မည်သည့်အချိန်တွင် ပြင်ခဲ့သည်ကို ပြသည်။';

  @override
  String get privacyIntro =>
      'ဤစာမျက်နှာသည် J\'Donuts သရုပ်ပြအက်ပ်အတွက် နမူနာသာ ဖြစ်ပြီး ဤစက်ပစ္စည်းပေါ်ရှိ ဒေတာကို မည်သို့ ကိုင်တွယ်သည်ကို ဖော်ပြသည်။';

  @override
  String get privacySection1Title => 'သိမ်းဆည်းသည့် အချက်အလက်များ';

  @override
  String get privacySection1Body =>
      'သင့်အမည်၊ မွေးသက္ကရာဇ် ဖုန်းနံပါတ်တို့ကို ဤစက်ပစ္စည်းတွင်သာ သိမ်းထားပြီး သင့်ဆက်ရှင်ကို မှတ်မိရန် ဖြစ်သည်။ ကက်တလောက်ကို အက်ပ်နှင့်အတူ ထည့်သွင်းထားသည်။';

  @override
  String get privacySection2Title => 'မစုဆောင်းသည့် အချက်အလက်များ';

  @override
  String get privacySection2Body =>
      'ခွဲခြမ်းစိတ်ဖြာမှု၊ ကြော်ငြာ အထောက်အထား သို့မဟုတ် တည်နေရာ ဒေတာများ မစုဆောင်းပါ။ အင်တာနက် မရှိလည်း အက်ပ် အလုပ်လုပ်နိုင်သည်။';

  @override
  String get privacySection3Title => 'သင့်ရွေးချယ်မှုများ';

  @override
  String get privacySection3Body =>
      'ဆက်ရှင်ကို ရှင်းလင်းရန် ဆက်တင်မှ Log out ကို နှိပ်ပါ သို့မဟုတ် အက်ပ်ကို ဖယ်ရှားလိုက်ပါက ဒေတာအားလုံး ဖျက်ပါမည်။';

  @override
  String challengeTapped(Object label) {
    return '$label ကို နှိပ်ပြီး';
  }
}
