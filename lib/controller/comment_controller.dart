import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

class CommentController{

  // get all comments  of specific post
  static getAllComments({required String postId}){
    return FirebaseFirestore.instance.collection('comments').where('commentedOnPost',isEqualTo: postId).orderBy('timestamp',descending: true).snapshots();
  }

  static addComment(Comment comment,context) async {
    try{
      await FirebaseFirestore.instance.collection('comments').doc().set(
        comment.toJson()
      );
      return true;
    }catch(e){
     print("Error is ${e.toString()}");
     showSnackBar(
       context: context,
       seconds: 2,
       message: e.toString(),
     );
     return false;
    }
  }
  static bool isEmpty(TextEditingController controller){
    if(controller.text.isEmpty){
      return true;
    }
    return false;
  }
  static createComment(TextEditingController controller,postId){
    print("post id is ${postId}");
    Comment comment=Comment(
      text: controller.text,
      commentBy: FirebaseAuth.instance.currentUser!.email,
      timestamp: Timestamp.now(),
      commentedOnPost: postId
    );
    return comment;
  }
  static deleteComment(commentID) async {
    await FirebaseFirestore.instance.collection('comments').doc(commentID).delete();
  }

  static updateComment(Comment comment,context,docId) async {
    try{
      await FirebaseFirestore.instance.collection('comments').doc(docId).update(
          comment.toJson()
      );
      return true;
    }catch(e){
      print("Error is ${e.toString()}");
      showSnackBar(
        context: context,
        seconds: 2,
        message: e.toString(),
      );
      return false;
    }
  }
}