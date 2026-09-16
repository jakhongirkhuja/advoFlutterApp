String formatPhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final uzbekDigits = digits.startsWith('998') ? digits.substring(3) : digits;

  if (uzbekDigits.length == 9) {
    return '+998 (${uzbekDigits.substring(0, 2)}) ${uzbekDigits.substring(2, 5)} ${uzbekDigits.substring(5, 7)} ${uzbekDigits.substring(7, 9)}';
  }

  return phone;
}
String formatPrice(dynamic price) {
  final priceStr = price.toString().replaceAll(RegExp(r'\D'), '');
  if (priceStr.isEmpty) return '0';

  return priceStr.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]} ',
  );
}