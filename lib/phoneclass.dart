
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  UserModel? setusermodel(User? user) {
    if (user != null) {
      print(user);
      setData(user);
      return UserModel(uid: user.uid, email: user.email);
    } else {
      print("something is wrong");
      return null;
    }
    // UserModel _usermodel = UserModel(uid:user.uid ,email: user.email);
    // return user != null ? UserModel(uid: user.uid, email: user.email) : null;
  }

  void setData(User user) {
    FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": user.email,
      "phonenumber": user.phoneNumber,
      "profile_picture": user.photoURL,
      "name": user.displayName,
    });
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Fetch sign-in methods for the email address
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      // In case list is not empty
      if (list.isNotEmpty) {
        // Return true because the
        // user using the email address
        return true;
      } else {
        // Return false because email adress is not in use
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map((User? user) => setusermodel(user));
  }

  Future signIn({String? email, String? password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.toString(), password: password.toString());
      User? user = result.user;
      return setusermodel(user);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future signUp({String? email, String? password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.toString(), password: password.toString());
      User? user = result.user;
      print(user);

      setusermodel(user);

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> verifyPhone(String countryCode, String mobile) async {
    var mobileToSend = mobile;

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+917010862331",
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            // this.verificationId = verId;
          },
          codeSent: (String verId, [int? forceCodeResend]) {
            this.verificationId = verId;
          },
          timeout: const Duration(
            seconds: 120,
          ),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (FirebaseAuthException exceptio) {
            print(exceptio);
            throw exceptio;
          });
    } catch (e) {
      throw e;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final UserCredential result =
          await _auth.signInWithCredential(credential);
      User? user = result.user;
      setusermodel(user);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  showError(error) {
    throw error.toString();
  }

  
  Future signout() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print(e);
      return null;
    }
  }

}