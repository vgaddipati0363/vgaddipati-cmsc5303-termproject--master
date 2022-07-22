import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/view_model.dart';

class ViewController{
  static getViews(String postId){
    print("getting views for postid ${postId}");
    return  FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection).doc(postId).collection('views').orderBy('timestamp',descending: true).snapshots();
  }
  static addView(String postId) async {
    ViewModel viewModel=ViewModel(
      viewBy:FirebaseAuth.instance.currentUser!.email
    );
    DocumentSnapshot documentSnapshot=await FirebaseFirestore.instance.collection(Constant.PhotoMemoCollection).doc(postId).collection('views').doc(FirebaseAuth.instance.currentUser!.uid).get();
    if(documentSnapshot.exists){
      print("Already seen");
    }else{
      FirebaseFirestore.instance.collection(Constant.PhotoMemoCollection).doc(postId).collection('views').doc(FirebaseAuth.instance.currentUser!.uid).set(viewModel.toJson());
    }
  }

}