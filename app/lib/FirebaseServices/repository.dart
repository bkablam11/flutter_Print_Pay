import 'package:app/View/Notes/notes_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services.dart';

class AuthResult {
  final bool success;
  final String? message;
  const AuthResult({required this.success, this.message});
}

class Repository extends FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseServices _services = FirebaseServices();

  // Authentication methods
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "User not found");
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: e.message);
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await userCredential.user?.updateDisplayName(fullName);
        await userCredential.user?.reload();
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "Failed to create user");
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Notes Database operations
  Future<List<NotesModel>> getNotes() async {
    try {
      final List<Map<String, dynamic>> notesData = await _services.get(
        path: 'notes',
      );
      return notesData.map((data) => NotesModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addNote(NotesModel note) async {
    try {
      return await _services.add(path: 'notes', data: note.toMap());
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> updateNote(NotesModel note) async {
    try {
      final isUpdated = await _services.update(
        path: 'notes',
        data: note.toMap(),
        docId: note.id!,
      );

      if (isUpdated) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote(String docId) async {
    try {
      final bool isDelete = await _services.delete(path: 'notes', docId: docId);
      return isDelete;
    } catch (e) {
      return false;
    }
  }

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
