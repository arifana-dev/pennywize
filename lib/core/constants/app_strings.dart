class AppStrings {
  AppStrings._();

  static const String appName = 'Penny';
  static const String tagline = "Your money's best friend 💕";

  static const String greetingHei = 'Hei! 👋';

  static const String emptyExpenses =
      'Belum ada pengeluaran hari ini! Hidup hemat banget 🎉';

  static const String scanningReceipt = 'Penny lagi baca struknya... 🔍';

  static const String pennyUnder50k = 'Penny bangga sama kamu hari ini! 🥰';
  static const String pennyMid = 'Lumayan nih pengeluarannya, tapi oke 😊';
  static const String pennyOver200k = 'Psst... udah banyak loh hari ini 👀';

  static const List<String> widgetMiniMessages = [
    'Jangan lupa catat ya! 💕',
    'Hemat itu seksi loh 😉',
    'Tetap semangat ngatur duit! ✨',
    'Penny percaya kamu bisa! 🌟',
    'Dompet tipis, hati tebal 💪',
    'Yuk dicatat hari ini! 📒',
    'Sayangi dompetmu 💖',
  ];

  static String widgetMessageOfDay(DateTime date) {
    final i = date.day % widgetMiniMessages.length;
    return widgetMiniMessages[i];
  }
}
