

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/view_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';
import 'package:lesson3/viewscreen/views_screen.dart';

import '../controller/comment_controller.dart';
import '../controller/firestore_controller.dart';
import 'comment_screen.dart';

class sharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList;
  final User user;

  const sharedWithScreen(
      {required this.user, required this.photoMemoList, Key? key})
      : super(key: key);


  @override
  _sharedWithScreenState createState() => _sharedWithScreenState();
}

class _sharedWithScreenState extends State<sharedWithScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With: ${user.email}'),
      ),
      body: SingleChildScrollView(
        child: photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo shared with me',
                style: Theme.of(context).textTheme.headline6,
              )
            : Column(
                children: [
                  for (var photoMemo in photoMemoList)
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: WebImage(
                                url: photoMemo.photoURL,
                                context: context,
                                height: MediaQuery.of(context).size.height * 0.3,
                              ),
                            ),
                            Text(
                              photoMemo.title,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(photoMemo.memo),
                            Text('Created By: ${photoMemo.createdBy}'),
                            Text('Created at: ${photoMemo.timestamp}'),
                            Text('Shared With: ${photoMemo.shareWith}'),
                            Constant.devMode
                                ? Text('Image Labels: ${photoMemo.imageLabels}')
                                : const SizedBox(
                                    height: 1.0,
                                  ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                //dislike functionality

                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      if(photoMemo.dislikedBy.contains(FirebaseAuth.instance.currentUser!.uid)){

                                        photoMemo.dislikedBy.remove(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.removeFromDisliked(docId: photoMemo.docId!);

                                      }else{
                                        photoMemo.dislikedBy.add(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.addToDisliked(docId: photoMemo.docId!);


                                        photoMemo.likedBy.remove(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.removeFromLike(docId: photoMemo.docId!);

                                      }
                                    });
                                  },
                                  icon:photoMemo.dislikedBy.contains(FirebaseAuth.instance.currentUser!.uid)?Icon(Icons.thumb_down,color: Colors.blue,):
                                  Icon(Icons.thumb_down,color: Colors.grey,),
                                ),


                                // like functionality

                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      if(photoMemo.likedBy.contains(FirebaseAuth.instance.currentUser!.uid)){
                                        photoMemo.likedBy.remove(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.removeFromLike(docId: photoMemo.docId!);
                                      }else{
                                        photoMemo.likedBy.add(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.addToLiked(docId: photoMemo.docId!);

                                        photoMemo.dislikedBy.remove(FirebaseAuth.instance.currentUser!.uid);
                                        FirestoreController.removeFromDisliked(docId: photoMemo.docId!);

                                      }
                                    });
                                  },
                                  icon:photoMemo.likedBy.contains(FirebaseAuth.instance.currentUser!.uid)?Icon(Icons.thumb_up,color: Colors.blue,):
                                  Icon(Icons.thumb_up,color: Colors.grey,),
                                ),

                                IconButton(onPressed: (){
                                  setState(() {
                                    if(photoMemo.favouritesBy.contains(FirebaseAuth.instance.currentUser!.uid)){
                                      photoMemo.favouritesBy.remove(FirebaseAuth.instance.currentUser!.uid);
                                      FirestoreController.removeFromFavourite(docId: photoMemo.docId!);
                                    }else{
                                      photoMemo.favouritesBy.add(FirebaseAuth.instance.currentUser!.uid);
                                      FirestoreController.addToFavourite(docId: photoMemo.docId!);
                                    }
                                  });
                                  print("Added");
                                }, icon:photoMemo.favouritesBy.contains(FirebaseAuth.instance.currentUser!.uid)?Icon(Icons.favorite,color: Colors.red,):
                                Icon(Icons.favorite_border,color: Colors.black,)),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  CommentScreen(
                                        postDocId:photoMemo.docId,
                                      ),),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Badge(
                                      badgeContent: StreamBuilder<QuerySnapshot>(
                                          stream: CommentController.getAllComments(postId:photoMemo.docId!),
                                          builder: (context, snapshot) {
                                            if(!snapshot.hasData){
                                              return Text('0');
                                            }if(snapshot.data!.size==0){
                                              return Text('0');
                                            }
                                            return Text("${snapshot.data!.size}");
                                          }
                                      ),
                                      shape: BadgeShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Icon(Icons.comment_bank_outlined,color: Colors.black,),
                                    ),
                                  ),
                                ),
                                // const Icon(Icons.arrow_right),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text("${photoMemo.likedBy.length} People liked this post"),
                            ),

                            InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (builder){
                                      return ViewsScreen(postId:photoMemo.docId!,);
                                    }
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 40,
                                  width:MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.5),
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))
                                  ),
                                  child: Center(child: StreamBuilder<QuerySnapshot>(
                                      stream: ViewController.getViews(photoMemo.docId!),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.data!.size == 0) {
                                          return Center(
                                            child: Text('No Views'),
                                          );
                                        }
                                        return Text('${snapshot.data!.size} Views',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic,fontSize: 22),);
                                      }
                                  )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
  var user;
  var photoMemoList;

  @override
  void initState() {
     user=widget.user;
     photoMemoList=widget.photoMemoList;
  }
}
