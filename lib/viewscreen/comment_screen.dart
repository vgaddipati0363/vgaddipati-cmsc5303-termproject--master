import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

import '../controller/comment_controller.dart';
import '../widgets/custom_widgets.dart';

class CommentScreen extends StatefulWidget {
  static const routeName = '/commentScreen';
  String? postDocId;

  CommentScreen({Key? key, this.postDocId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final txtInput = TextEditingController();
  var _stream;

  @override
  void initState() {
    setState(() {
      _stream= CommentController.getAllComments(postId: widget.postDocId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("doc is ${widget.postDocId}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Comments'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream:_stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.size == 0) {
                    return Center(
                      child: Text(
                        'No Comment yet',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  }
                  List<Comment> commentsList = [];
                  var allDocs = snapshot.data!.docs;
                  for (var doc in allDocs) {
                    commentsList.add(Comment.fromJson(doc));
                  }

                  return ListView.builder(
                    itemCount: commentsList.length,
                    itemBuilder: (context, index) {
                      Comment comment = commentsList[index];
                      return commentWidget(
                          context: context,
                         comment:comment);
                    },
                  );
                }),
          ),
          textField(
            context: context,
            controller: txtInput,
            hint: "Type comment here ....",
            suffix: IconButton(
                onPressed: () {
                  messageSend();
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                )),
          )
        ],
      ),
    );
  }
  messageSend() async {
    if(CommentController.isEmpty(txtInput)){
      showSnackBar(
        context: context,
        seconds: 2,
        message: 'Please write comment.....',
      );
    }else{
      Comment comment=CommentController.createComment(txtInput, widget.postDocId);
      setState(() {
        txtInput.text='';
      });
      await CommentController.addComment(comment,context);

    }
  }
}
