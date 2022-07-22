import 'package:lesson3/model/photo_memo.dart';

class Constant {
  static const devMode = true;
  static const photoFileFolder = 'photo_files';
  static const PhotoMemoCollection = 'photomemo_collection';
}

enum ArgKey {
  user, downloadURL, filename, photoMemoList, onePhotoMemo,
}