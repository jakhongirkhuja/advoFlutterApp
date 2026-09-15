String formatPhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final uzbekDigits = digits.startsWith('998') ? digits.substring(3) : digits;

  if (uzbekDigits.length == 9) {
    return '+998 (${uzbekDigits.substring(0, 2)}) ${uzbekDigits.substring(2, 5)} ${uzbekDigits.substring(5, 7)} ${uzbekDigits.substring(7, 9)}';
  }

  return phone;
}
