import 'package:cloud_firestore/cloud_firestore.dart';

class ViewModel {
  String? viewBy;
  Timestamp? timestamp;

  ViewModel({this.viewBy, this.timestamp});

  ViewModel.fromJson(Map<String, dynamic> json) {
    viewBy = json['viewBy'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['viewBy'] = this.viewBy;
    data['timestamp'] = Timestamp.now();
    return data;
  }
}
