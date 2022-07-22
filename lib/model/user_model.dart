import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class UserModel {
  String? userId;
  String? name;
  String? email;
  String? imgUrl;

  UserModel({this.userId, this.name, this.email, this.imgUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId']??"";
    name = json['name']??"";
    email = json['email']??"";
    imgUrl = json['imgUrl']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['imgUrl'] = this.imgUrl;
    return data;
  }

  // upload images to storage and let links
  static Future<String?> uploadImageToFirestore(File img) async{
    String imgUrl='';
    try{
      var ref=storage.ref().child('profile/${FirebaseAuth.instance.currentUser!.uid}/${basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value){
          print("Image url $value");
          imgUrl=value;
        });
      });
      return imgUrl;
    }catch(e){
      print("Error while uploading images $e");
      return "null";
    }
  }

 static FirebaseStorage storage=FirebaseStorage.instance;

  static Future<bool> deleteFromStorage(url) async {
    try{
      await storage.refFromURL(url).delete();
      print("deleted successfully");
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      DocumentSnapshot documentReference=await FirebaseFirestore.instance.collection('users').doc(userModel.userId).get();
      if(documentReference.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userModel.userId).update({
          "name":userModel.name,
          "imgUrl":userModel.imgUrl
        }
        );
      }else{
        await FirebaseFirestore.instance.collection('users').doc(userModel.userId).set(userModel.toJson());
      }
      return true;
    }catch(e){
      print("Error is ${e.toString()}");
      return false;
    }
  }
  static Future<UserModel> getUserInfo() async {
    try {
      DocumentSnapshot documentSnapshot=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      if(documentSnapshot.exists){
        var result=documentSnapshot.data() as Map<String,dynamic>;
        return UserModel.fromJson(result);
      }
      return UserModel(name: "",email: FirebaseAuth.instance.currentUser!.email,imgUrl: "");
    }catch(e){
      print("Error is ${e.toString()}");
      return UserModel(name: "",email: FirebaseAuth.instance.currentUser!.email,imgUrl: "");
    }
  }

}
