import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBYDdXpINjqbmXVh4FMMjyaOS47fGXRoRg',
    appId: '1:464007767275:web:891ffe365fd164b02a0aae',
    messagingSenderId: '464007767275',
    projectId: 'sosedi-app-1aa55',
    authDomain: 'sosedi-app-1aa55.firebaseapp.com',
    storageBucket: 'sosedi-app-1aa55.firebasestorage.app',
    measurementId: 'G-EDWKB5XXCS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYDdXpINjqbmXVh4FMMjyaOS47fGXRoRg',
    appId: '1:464007767275:android:891ffe365fd164b02a0aae',
    messagingSenderId: '464007767275',
    projectId: 'sosedi-app-1aa55',
    storageBucket: 'sosedi-app-1aa55.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYDdXpINjqbmXVh4FMMjyaOS47fGXRoRg',
    appId: '1:464007767275:ios:891ffe365fd164b02a0aae',
    messagingSenderId: '464007767275',
    projectId: 'sosedi-app-1aa55',
    storageBucket: 'sosedi-app-1aa55.firebasestorage.app',
    iosBundleId: 'com.sosedi.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYDdXpINjqbmXVh4FMMjyaOS47fGXRoRg',
    appId: '1:464007767275:macos:891ffe365fd164b02a0aae',
    messagingSenderId: '464007767275',
    projectId: 'sosedi-app-1aa55',
    storageBucket: 'sosedi-app-1aa55.firebasestorage.app',
    iosBundleId: 'com.sosedi.app',
  );
}
