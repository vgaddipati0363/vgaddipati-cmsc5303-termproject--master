import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/comment_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/util/alert.dart';
import 'package:lesson3/util/date_formatting.dart';
import 'package:lesson3/viewscreen/edit_comment_screen.dart';

textField(
    {TextEditingController? controller,
    String? hint,
    Widget? suffix,
    onType,
    context}) {
  return Padding(
    padding: const EdgeInsets.all(5),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          onChanged: onType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIconConstraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.06),
            contentPadding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
          ),
          scrollPadding: EdgeInsets.zero,
        ),
      ),
    ),
  );
}

Widget commentWidget({context,required Comment comment}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8,top: 5),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                      ),
                      Text(
                        " ${comment.commentBy}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: Text(comment.text??""),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          DateFormatting.formatCommentDate(comment.timestamp!.toDate())))
                ],
              ),
            ),
          ),
          Visibility(
            visible: comment.commentBy==FirebaseAuth.instance.currentUser!.email,
            child: Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  EditCommentScreen(
                      comment:comment,
                    ),),
                  );
                }, icon: Icon(Icons.edit,color: Colors.blue,)),
                IconButton(onPressed: (){
                  MyAlert.showAlertDialog(context,btnText: "DELETE",title: "DELETE COMMENT",subtitle: "Do you really want to delete this comment",btnAction: (){
                    CommentController.deleteComment(comment.docId);
                    Navigator.pop(context);
                  });
                }, icon: Icon(Icons.delete,color: Colors.red,))
              ],
            ),
          )
        ],
      ),
    ],
  );
}


Widget customProfileAvatar(String _url) {
  return Container(
    height: 100,
    width: 100,
    child: CachedNetworkImage(
      imageUrl: _url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) =>
      const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
      const Center(child: Icon(Icons.error)),
    ),
  );
}
