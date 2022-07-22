import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? docId;
  String? text;
  String? commentBy;
  Timestamp? timestamp;
  String? commentedOnPost;

  Comment(
      {this.docId,
        this.text,
        this.commentBy,
        this.timestamp,
        this.commentedOnPost});

  Comment.fromJson(DocumentSnapshot documentSnapshot) {
    var json=documentSnapshot.data() as Map<String,dynamic>;
    docId = documentSnapshot.id;
    text = json['text']??"N/A";
    commentBy = json['commentBy']??"N/A";
    timestamp = json['timestamp']??Timestamp.now();
    commentedOnPost = json['commentedOnPost']??"N/A";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['commentBy'] = this.commentBy;
    data['timestamp'] = this.timestamp;
    data['commentedOnPost'] = this.commentedOnPost;
    return data;
  }
}
