import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/comment_controller.dart';
import 'package:lesson3/model/comment.dart';

class EditCommentScreen extends StatefulWidget {
  static const routeName = '/editCommentScreen';
  Comment? comment;
   EditCommentScreen({Key? key,this.comment}) : super(key: key);

  @override
  _EditCommentScreenState createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final txtInput=TextEditingController();

  @override
  void initState() {
    setState(() {
      txtInput.text=widget.comment!.text??"";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Comment'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              height:MediaQuery.of(context).size.height*0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.withOpacity(0.3),
                border: Border.all(color: Colors.black)
              ),
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: txtInput,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,

                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(onPressed: () async {
                    Comment newcomment=Comment(
                        text: txtInput.text,
                        commentBy: FirebaseAuth.instance.currentUser!.email,
                        timestamp: Timestamp.now(),
                        commentedOnPost: widget.comment!.commentedOnPost
                    );
                     CommentController.updateComment(newcomment, context, widget.comment!.docId);
                    Navigator.pop(context);
                  }, child:Text("UPDATE"))),
            )
          ],
        ),
      ),
    ));
  }
}
