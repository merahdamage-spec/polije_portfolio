import 'package:flutter/foundation.dart';

/// Alamat folder API PHP (XAMPP -> htdocs/polije_api).
///  - Chrome / Windows        : http://localhost/polije_api
///  - Emulator Android        : http://10.0.2.2/polije_api
///  - HP Android asli (1 WiFi): http://IP_LAPTOP/polije_api  (cek dengan `ipconfig`)
String get kBaseUrl {
  if (kIsWeb) return 'http://localhost/polije_api';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2/polije_api';
  }
  return 'http://localhost/polije_api';
}
