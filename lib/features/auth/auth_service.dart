import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  // Constructor que escucha los cambios de autenticación
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Iniciar sesión con correo y contraseña
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      // Cargar el rol del usuario desde Firestore
      await _loadUserRole();
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _role = null;
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;

      try {
        // Obtener el documento del usuario desde Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(uid).get();

        // Verifica si el documento existe
        if (userDoc.exists) {
          // Acceder al campo "role"
          _role = userDoc['role'];
          notifyListeners();
        }
        // } else {
        //   print(
        //       "El documento del usuario no existe en Firestore. Creando uno nuevo.");

        //   // Crear el documento con un rol predeterminado si no existe
        //   await _firestore.collection('users').doc(uid).set({
        //     'email': _auth.currentUser!.email,
        //     'role': 'viewer', // Rol predeterminado
        //   });

        //   // Asignar el rol después de crearlo

        //   _role = 'viewer';
        //   notifyListeners();
        // }
      } catch (e) {
        print('Error al cargar el rol del usuario: $e');
        throw Exception('Error al cargar el rol del usuario');
      }
    }
  }

  // Maneja los cambios de estado de autenticación
  void _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (_user != null) {
      try {
        await _loadUserRole();
      } catch (e) {
        print('Error al cargar el rol después del cambio de estado: $e');
      }
    } else {
      _role = null;
    }
    notifyListeners();
  }
}
