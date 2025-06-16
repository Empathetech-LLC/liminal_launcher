// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LangEn extends Lang {
  LangEn([String locale = 'en']) : super(locale);

  @override
  String get hsCounterLabel => 'You have pushed the button this many times:';
}

/// The translations for English, as used in the United States (`en_US`).
class LangEnUs extends LangEn {
  LangEnUs() : super('en_US');

  @override
  String get hsCounterLabel => 'You have pushed the button this many times:';
}
