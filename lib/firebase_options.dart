import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web no está configurado.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBr-ZXuCy3iMYi_WQTQSQYC77z6vesWu9I',
    appId: '1:289958893223:android:6622cda7cd351567a52d82',
    messagingSenderId: '289958893223',
    projectId: 'vivia-499723',
    storageBucket: 'vivia-499723.firebasestorage.app',
  );
}
