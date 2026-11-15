// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get homeTab => 'Home';

  @override
  String get onboardingTitle => 'Round food for every mood';

  @override
  String get getStarted => 'Let\'s get started';

  @override
  String get logIn => 'Log in';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get continueLabel => 'Continue';

  @override
  String get phoneTitle => 'What\'s your phone number?';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get phoneInvalid => 'Enter 9 followed by 7 to 9 digits after +95';

  @override
  String get verifyTitle => 'Verify your number';

  @override
  String verifyHint(Object phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get resend => 'Resend';

  @override
  String resendIn(Object time) {
    return 'Resend in $time';
  }

  @override
  String get otpInvalid => 'That code doesn\'t look right. Try 123456.';

  @override
  String get otpLocked => 'Too many wrong tries. Tap Resend to get a new code.';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get nameRequired => 'First name is required';

  @override
  String get nameInvalidChars => 'Letters and spaces only, no digits';

  @override
  String get nameTooLong => 'Use 50 characters or fewer';

  @override
  String get dobTitle => 'When were you born?';

  @override
  String get selectDate => 'Select date';

  @override
  String get dobInvalid => 'Enter a real date';

  @override
  String get dobFuture => 'Date can\'t be in the future';

  @override
  String dobTooYoung(Object age) {
    return 'You must be at least $age years old';
  }

  @override
  String get welcomeTitle => 'Welcome to the world of J\'donuts';

  @override
  String get letsExplore => 'Let\'s explore';

  @override
  String get seasonalSpecials => 'Seasonal specials';

  @override
  String get popular => 'Popular';

  @override
  String get orderAgain => 'Order again';

  @override
  String nearbyShopsTitle(Object count) {
    return 'There are $count J\'Donut shops near you';
  }

  @override
  String get exploreNow => 'Explore now';

  @override
  String get orderOnline => 'Order online';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get total => 'Total';

  @override
  String addedToCart(Object count) {
    return '$count added to cart';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get eatMoreEarnMore => 'Eat more earn more';

  @override
  String get giftTab => 'Gift';

  @override
  String pointsToNextTier(Object points, Object tier) {
    return '$points points to $tier';
  }

  @override
  String get challengeComplete => 'Done';

  @override
  String get earn => 'Earn';

  @override
  String get settings => 'Settings';

  @override
  String get orders => 'Orders';

  @override
  String get cartTab => 'Cart';

  @override
  String get notifications => 'Notifications';

  @override
  String get logOut => 'Log out';

  @override
  String get offline => 'You\'re offline';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get emptyGeneric => 'Nothing here yet';

  @override
  String get notFound => 'Not found';

  @override
  String get socialLoginComingSoon => 'Social sign-in is coming soon';

  @override
  String get legalComingSoon => 'This link is not part of the demo';

  @override
  String get loggedOutMessage => 'You\'ve been logged out';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get systemTheme => 'System';

  @override
  String get english => 'English';

  @override
  String get myanmar => 'Myanmar';

  @override
  String get max => 'Max';

  @override
  String get register => 'Register';

  @override
  String get phoneNotRegistered => 'Phone number not registered';

  @override
  String get points => 'points';

  @override
  String get newBadge => 'NEW';

  @override
  String get nameTitle => 'What should we call you?';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get mmk => 'MMK';

  @override
  String memberProgress(Object points, Object tier, Object toNext) {
    return '$points pts · $toNext to $tier';
  }

  @override
  String discountOff(Object percent) {
    return '$percent% off';
  }

  @override
  String productCode(Object code) {
    return 'Code $code';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String challengeTapped(Object label) {
    return '$label tapped';
  }
}
