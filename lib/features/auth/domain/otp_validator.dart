abstract final class OtpValidator {
  static const int length = 6;
  static const String demoCode = '123456';

  static bool isComplete(String code) {
    return code.length == length && int.tryParse(code) != null;
  }

  static bool matches(String code) {
    return code == demoCode;
  }
}
