import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:000000000000:android:demo',
      messagingSenderId: '000000000000',
      projectId: 'saathi-demo',
      storageBucket: 'saathi-demo.appspot.com',
    );
  }
}
