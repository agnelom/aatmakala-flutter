import 'dart:developer' as dev;

class Log {
  static void d(String msg) => dev.log(msg);
  static void e(String msg, [Object? error, StackTrace? st]) => dev.log(msg, error: error, stackTrace: st);
}