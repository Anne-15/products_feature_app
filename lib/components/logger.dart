import 'package:logger/logger.dart';

class LoggerService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Shows method calls
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );
}