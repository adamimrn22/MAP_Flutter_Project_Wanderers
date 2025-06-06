// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCVaZhTQ49C-__ioY1SC6T-6crnKMSlk5k',
    appId: '1:418868245008:web:8e96b168bfa175545b1095',
    messagingSenderId: '418868245008',
    projectId: 'mycrochetbag-47372',
    authDomain: 'mycrochetbag-47372.firebaseapp.com',
    storageBucket: 'mycrochetbag-47372.firebasestorage.app',
    measurementId: 'G-XSL4L1ZWD0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCebo-z47lE8BaCzfiLiCC2kVTd8r0YJSA',
    appId: '1:418868245008:android:5fb04cd71f08e84e5b1095',
    messagingSenderId: '418868245008',
    projectId: 'mycrochetbag-47372',
    storageBucket: 'mycrochetbag-47372.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzsdZJ_exRZR43BPKwPjS2SkLeglKIk_8',
    appId: '1:418868245008:ios:b3d176607a2ff2fd5b1095',
    messagingSenderId: '418868245008',
    projectId: 'mycrochetbag-47372',
    storageBucket: 'mycrochetbag-47372.firebasestorage.app',
    iosBundleId: 'com.example.mycrochetbag',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBzsdZJ_exRZR43BPKwPjS2SkLeglKIk_8',
    appId: '1:418868245008:ios:b3d176607a2ff2fd5b1095',
    messagingSenderId: '418868245008',
    projectId: 'mycrochetbag-47372',
    storageBucket: 'mycrochetbag-47372.firebasestorage.app',
    iosBundleId: 'com.example.mycrochetbag',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVaZhTQ49C-__ioY1SC6T-6crnKMSlk5k',
    appId: '1:418868245008:web:b872e38ee83df1155b1095',
    messagingSenderId: '418868245008',
    projectId: 'mycrochetbag-47372',
    authDomain: 'mycrochetbag-47372.firebaseapp.com',
    storageBucket: 'mycrochetbag-47372.firebasestorage.app',
    measurementId: 'G-32MFM03HQE',
  );

}