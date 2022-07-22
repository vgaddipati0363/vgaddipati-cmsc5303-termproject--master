enum PhotoSource { camera, gallery }

enum DocKeyPhotoMemo {
  createdBy,
  title,
  memo,
  photoFilename,
  photoURL,
  timestamp,
  imageLabels,
  sharedWith,
  favouritesBy,
  likedBy,
  dislikedBy,
  mlAppliedBy,


}

class PhotoMemo {
  String? docId; // Firestore auto-generated id
  late String createdBy; // email = user id
  late String title;
  late String memo;
  late String photoFilename; //image/photo file at Cloud Storage
  late String photoURL;
  late String mlAppliedBy;
  // URL of image
  DateTime? timestamp;
  late List<dynamic> imageLabels; // ML generated image labels
  late List<dynamic> shareWith;
  late List<dynamic> favouritesBy;
  late List<dynamic> likedBy;
  late List<dynamic> dislikedBy;



  // list of emails

  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.mlAppliedBy = '',

    this.timestamp,

    List<dynamic>? imageLabels,
    List<dynamic>? sharedWith,
    List<dynamic>? favouritesBy,
    List<dynamic>? likedBy,
    List<dynamic>? dislikedBy,




  }) {
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.shareWith = sharedWith == null ? [] : [...sharedWith];
    this.favouritesBy = favouritesBy == null ? [] : [...favouritesBy];
    this.likedBy = likedBy == null ? [] : [...likedBy];
    this.dislikedBy = dislikedBy == null ? [] : [...dislikedBy];



  }

  PhotoMemo.clone(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    mlAppliedBy = p.mlAppliedBy;

    timestamp = p.timestamp;
    shareWith = [...p.shareWith];
    imageLabels = [...p.imageLabels];
    favouritesBy = [...p.favouritesBy];
    likedBy = [...p.likedBy];
    dislikedBy = [...p.dislikedBy];



  }

  // a.copyFrom(b) ==> a = b
  void copyFrom(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    mlAppliedBy = p.mlAppliedBy;

    timestamp = p.timestamp;
    shareWith.clear();
    shareWith.addAll(p.shareWith);
    imageLabels.clear();
    imageLabels.addAll(p.imageLabels);
    favouritesBy.clear();
    favouritesBy.add(p.favouritesBy);
    likedBy.clear();
    likedBy.add(p.likedBy);
    dislikedBy.clear();
    dislikedBy.add(p.dislikedBy);


  }

  // serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPhotoMemo.title.name: title,
      DocKeyPhotoMemo.createdBy.name: createdBy,
      DocKeyPhotoMemo.memo.name: memo,
      DocKeyPhotoMemo.photoFilename.name: photoFilename,
      DocKeyPhotoMemo.photoURL.name: photoURL,
      DocKeyPhotoMemo.mlAppliedBy.name: mlAppliedBy,

      DocKeyPhotoMemo.timestamp.name: timestamp,
      DocKeyPhotoMemo.sharedWith.name: shareWith,
      DocKeyPhotoMemo.imageLabels.name: imageLabels,
      DocKeyPhotoMemo.favouritesBy.name: favouritesBy,
      DocKeyPhotoMemo.likedBy.name: likedBy,
      DocKeyPhotoMemo.dislikedBy.name: dislikedBy,



    };
  }

  //deserialization
  static PhotoMemo? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoMemo(
      docId: docId,
      createdBy: doc[DocKeyPhotoMemo.createdBy.name] ??= 'N/A',
      title: doc[DocKeyPhotoMemo.title.name] ??= 'N/A',
      memo: doc[DocKeyPhotoMemo.memo.name] ??= 'N/A',
      photoFilename: doc[DocKeyPhotoMemo.photoFilename.name] ??= 'N/A',
      photoURL: doc[DocKeyPhotoMemo.photoURL.name] ??= 'N/A',
      mlAppliedBy: doc[DocKeyPhotoMemo.mlAppliedBy.name] ??= 'label',

      sharedWith: doc[DocKeyPhotoMemo.sharedWith.name] ??= 'N/A',
      imageLabels: doc[DocKeyPhotoMemo.imageLabels.name] ??= 'N/A',
      favouritesBy: doc[DocKeyPhotoMemo.favouritesBy.name] ??= [],
      likedBy: doc[DocKeyPhotoMemo.likedBy.name] ??= [],
      dislikedBy: doc[DocKeyPhotoMemo.dislikedBy.name] ??= [],



      timestamp: doc[DocKeyPhotoMemo.timestamp.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPhotoMemo.timestamp.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  static String? validateTitle(String? value) {}
    

  static String? validateMemo(String? value) {}
    

  static String? validateSharedWith(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    List<String> emailList = value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.')) {
        continue;

      } else {
        return 'Invalid email address found: comma, semicolon, space separted list';
      }
    }
  }
}
