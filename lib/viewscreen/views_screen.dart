import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/view_controller.dart';
import 'package:lesson3/model/view_model.dart';
import 'package:lesson3/util/date_formatting.dart';

import '../controller/firestore_controller.dart';

class ViewsScreen extends StatelessWidget {
  String postId;

  ViewsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.0,
      color: Colors.transparent, //could change this to Color(0xFF737373),
      //so you don't have to change MaterialApp canvasColor
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0))),
          child: StreamBuilder<QuerySnapshot>(
            stream: ViewController.getViews(postId),
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
              var allDocs = snapshot.data!.docs;
              List<ViewModel> views = [];
              for (var doc in allDocs) {
                views.add(
                    ViewModel.fromJson(doc.data() as Map<String, dynamic>));
              }
              return ListView.builder(
                  itemCount: views.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 5),
                      child: Card(
                        elevation: 8,
                        child: ListTile(
                          title: Text("${views[index].viewBy}"),
                          trailing: Text(
                              "${DateFormatting.formatCommentDate(views[index].timestamp!.toDate())}"),
                        ),
                      ),
                    );
                  });
            },
          )),
    );
  }
}
