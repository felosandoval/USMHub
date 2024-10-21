import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;

  Future<User?> signInWithGoogle(BuildContext context, Function callback) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      _showMessage(context, 'Por favor, para calificar, seleccione su cuenta');
      return null;
    }

    // Verificación del dominio de correo
    if (!RegExp(r'^.*@sansano\.usm\.cl$').hasMatch(googleUser.email)) {
      _showMessage(context, 'Solo se permiten correos Institucionales');
      await GoogleSignIn().signOut(); // Desconectar Google Sign-In si no es válido
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    callback(); // Llama al callback para actualizar el estado
    return userCredential.user;
  }

  Future<void> signOutWithGoogle() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
