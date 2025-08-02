import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestSmsPermission() async {
  final status = await Permission.sms.request();
  if (status.isGranted) {
    if (kDebugMode) {
      print('SMS permission granted');
    }
  } else {
    if (kDebugMode) {
      print('SMS permission denied');
    }
  }
}
