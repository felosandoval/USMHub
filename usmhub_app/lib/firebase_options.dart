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
    apiKey: 'AIzaSyDZMIRnrc8L28dWvGzaaNe3nc-SuROo-xQ',
    appId: '1:915279761372:web:136833a34197e482c5c919',
    messagingSenderId: '915279761372',
    projectId: 'usmhub',
    authDomain: 'usmhub.firebaseapp.com',
    storageBucket: 'usmhub.appspot.com',
    measurementId: 'G-0J5YR0TZQ3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJnTysyyfpjdmXAndTNyJgxPn9Hm0mgTE',
    appId: '1:915279761372:android:3c0cc1b54a0f20a5c5c919',
    messagingSenderId: '915279761372',
    projectId: 'usmhub',
    storageBucket: 'usmhub.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtpGdqIRRlY5FUVwp1cvQy_38EC-ryqHI',
    appId: '1:915279761372:ios:3470b503475177fbc5c919',
    messagingSenderId: '915279761372',
    projectId: 'usmhub',
    storageBucket: 'usmhub.appspot.com',
    iosBundleId: 'com.example.usmhubApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAtpGdqIRRlY5FUVwp1cvQy_38EC-ryqHI',
    appId: '1:915279761372:ios:3470b503475177fbc5c919',
    messagingSenderId: '915279761372',
    projectId: 'usmhub',
    storageBucket: 'usmhub.appspot.com',
    iosBundleId: 'com.example.usmhubApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZMIRnrc8L28dWvGzaaNe3nc-SuROo-xQ',
    appId: '1:915279761372:web:121ba35c5de7e693c5c919',
    messagingSenderId: '915279761372',
    projectId: 'usmhub',
    authDomain: 'usmhub.firebaseapp.com',
    storageBucket: 'usmhub.appspot.com',
    measurementId: 'G-LXTT5SJFDN',
  );
}
