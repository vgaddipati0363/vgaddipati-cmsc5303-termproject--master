import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/view_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';

class FirestoreController {
  static Future<String> addPhotoMemo({required PhotoMemo photoMemo}) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .add(photoMemo.toFirestoreDoc());
    return ref.id; // doc id auto-generated.
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        ViewController.addView(p!.docId!);
        if (p != null) result.add(p);
      }
    }
    return result;
  }



  static Future<void> updatePhotoMemo({
    required String docId,
    required Map<String, dynamic> update,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update(update);
  }

    getFavourites()  {
    return  FirebaseFirestore.instance.collection(Constant.PhotoMemoCollection).where('favouritesBy',arrayContains: FirebaseAuth.instance.currentUser!.uid).orderBy('timestamp',descending: true).snapshots();
  }

  static Future<void> addToFavourite({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'favouritesBy':FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  static Future<void> removeFromFavourite({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'favouritesBy':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  static Future<void> addToLiked({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'likedBy':FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  static Future<void> removeFromLike({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'likedBy':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  static Future<void> addToDisliked({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'dislikedBy':FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  static Future<void> removeFromDisliked({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .doc(docId)
        .update({
      'dislikedBy':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  static Future<List<PhotoMemo>> searchImages({
    required String email,
    required List<String> searchLabel, // OR search
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .where(DocKeyPhotoMemo.imageLabels.name, arrayContainsAny: searchLabel)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      var p = PhotoMemo.fromFirestoreDoc(
        doc: doc.data() as Map<String, dynamic>,
        docId: doc.id,
      );
      if (p != null) result.add(p);

    }
    return result;
  }

  static Future<void> deleteDoc({
    required String docId,

  }) async {
    await FirebaseFirestore.instance.collection(Constant.PhotoMemoCollection)
            .doc(docId).delete();
  }

  static Future<List<PhotoMemo>> getPhotoMemoListSharedWithMe({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PhotoMemoCollection)
        .where(DocKeyPhotoMemo.sharedWith.name, arrayContains: email)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null){
          result.add(p);
          ViewController.addView(p.docId!);
        }
      }
    }
    return result;
  }

  }
