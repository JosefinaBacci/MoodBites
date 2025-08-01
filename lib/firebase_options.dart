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
    apiKey: 'AIzaSyDjxa9JSQ4wOT6HrpoTpAPMgvSw3V68MSw',
    appId: '1:231200160893:web:bbd8adf6aaa95a80900514',
    messagingSenderId: '231200160893',
    projectId: 'moodbites-516ba',
    authDomain: 'moodbites-516ba.firebaseapp.com',
    storageBucket: 'moodbites-516ba.firebasestorage.app',
    measurementId: 'G-HNR03JDZ72',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIjo7MT1iWc2pJollbiNI8o8a2ilv49CU',
    appId: '1:231200160893:android:95a92d0e42898466900514',
    messagingSenderId: '231200160893',
    projectId: 'moodbites-516ba',
    storageBucket: 'moodbites-516ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCw3nzECh-pz9TDJINdqG3KsUIkhmh63lI',
    appId: '1:231200160893:ios:61f506cdda0ae7a8900514',
    messagingSenderId: '231200160893',
    projectId: 'moodbites-516ba',
    storageBucket: 'moodbites-516ba.firebasestorage.app',
    iosBundleId: 'com.example.flutterMoodBites',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCw3nzECh-pz9TDJINdqG3KsUIkhmh63lI',
    appId: '1:231200160893:ios:61f506cdda0ae7a8900514',
    messagingSenderId: '231200160893',
    projectId: 'moodbites-516ba',
    storageBucket: 'moodbites-516ba.firebasestorage.app',
    iosBundleId: 'com.example.flutterMoodBites',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDjxa9JSQ4wOT6HrpoTpAPMgvSw3V68MSw',
    appId: '1:231200160893:web:8b22e2aa8de97094900514',
    messagingSenderId: '231200160893',
    projectId: 'moodbites-516ba',
    authDomain: 'moodbites-516ba.firebaseapp.com',
    storageBucket: 'moodbites-516ba.firebasestorage.app',
    measurementId: 'G-WW5H9RE2SG',
  );
}
