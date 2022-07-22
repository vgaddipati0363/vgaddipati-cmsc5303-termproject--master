import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

class AuthController {
  static Future<User?> signin({required String email, required String password}) async {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  static Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }


  Future<bool> changePassword(context,String newPassword) async {
    final user =   FirebaseAuth.instance.currentUser;
    await user!.updatePassword(newPassword).then((_){
      return true;
    }).catchError((error){
      showSnackBar(context: context,message:error.toString());
      return false;
    });
    return true;
  }


}