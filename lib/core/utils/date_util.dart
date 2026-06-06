class DateUtil {
  /// Formats a DateTime object to 'dd/MM/yy'
  static String format(DateTime date) {
    final String d = date.day.toString().padLeft(2, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String y = date.year.toString().substring(2); // Extracts last 2 digits of year
    
    return '$d/$m/$y';
  }

  /// Formats a database ISO8601 string to 'dd/MM/yy'
  static String formatIso(String isoString) {
    final DateTime parsedDate = DateTime.parse(isoString);
    return format(parsedDate);
  }
}