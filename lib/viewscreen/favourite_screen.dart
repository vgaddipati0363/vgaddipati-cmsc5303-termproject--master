import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

import '../controller/firestore_controller.dart';


class FavouriteScreen extends StatefulWidget {
  static const routeName = '/favouriteScreen';
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  var _stream;
  @override
  void initState() {
    setState(() {
      _stream=FirestoreController().getFavourites();
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Favourites'),
        centerTitle: true,
      ),
      body: _stream==null?Center(child: CircularProgressIndicator()):StreamBuilder<QuerySnapshot>(
       stream:_stream,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child:CircularProgressIndicator(),);
          }
          if(snapshot.data!.size==0){
            return Center(child: Text('No Favourite yet',style: TextStyle(fontStyle: FontStyle.italic),),);
          }

          List<PhotoMemo> photoMemoList=[];
          var allDocs=snapshot.data!.docs;
          for(var doc in allDocs){
            photoMemoList.add(PhotoMemo.fromFirestoreDoc(doc: doc.data() as Map<String,dynamic>, docId: doc.id)!);
          }
          return ListView.builder(
            itemCount: photoMemoList.length,
            itemBuilder: (context,index) {
              PhotoMemo photoMemo=photoMemoList[index];
              return Card(
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
                    ],
                  ),
                ),
              );
            }
          );
        }
      ),
    ));
  }
}
