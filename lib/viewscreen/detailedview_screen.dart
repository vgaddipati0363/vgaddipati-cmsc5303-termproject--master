import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/ml_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;
  final PhotoMemo photoMemo;

  const DetailedViewScreen({
    required this.user,
    required this.photoMemo,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

  int radioGroupValue=0;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    setState(() {
      radioGroupValue=widget.photoMemo.mlAppliedBy=="text"?1:0;
      con.radioGroupValue=widget.photoMemo.mlAppliedBy=="text"?1:0;
    });
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: const Icon(Icons.check))
              : IconButton(onPressed: con.edit, icon: const Icon(Icons.edit)),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: con.photo == null
                          ? WebImage(
                              url: con.tempMemo.photoURL,
                              context: context,
                            )
                          : Image.file(con.photo!),
                    ),
                    editMode
                        ? Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Container(
                              color: Colors.blue[200],
                              child: PopupMenuButton(
                                onSelected: con.getPhoto,
                                itemBuilder: (context) => [
                                  for (var source in PhotoSource.values)
                                    PopupMenuItem(
                                      value: source,
                                      child: Text(source.name),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 1.0,
                          ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: con.progressMessage == null
                          ? const SizedBox(
                              height: 1.0,
                            )
                          : Container(
                              color: Colors.blue[200],
                              child: Text(
                                con.progressMessage!,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
                initialValue: con.tempMemo.title,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Memo',
                ),
                initialValue: con.tempMemo.memo,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Shared With: emailist',
                ),
                initialValue: con.tempMemo.shareWith.join(''),
                keyboardType: TextInputType.emailAddress,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              Constant.devMode ? Text('Image Labels by ML\n${con.tempMemo.imageLabels}')
               : const SizedBox(height: 1.0,),
              RadioListTile(
                  title: Text("Get labels from image"),
                  value:0, groupValue: radioGroupValue, onChanged:(val){
                setState(() {
                  radioGroupValue=val as int;
                  con.radioGroupValue=radioGroupValue;

                });
              }) ,
              RadioListTile(
                  title: Text("Get text from image"),
                  value:1, groupValue: radioGroupValue, onChanged:(val){
                setState(() {
                  radioGroupValue=val as int;
                  con.radioGroupValue=radioGroupValue;

                });
              })
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  late PhotoMemo tempMemo;
  File? photo;
  String? progressMessage;
  int? radioGroupValue;
  _Controller(this.state) {
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    startCircularProgress(state.context);

    try {
      Map<String, dynamic> update = {};
      if (photo != null) {
        Map result = await CloudStorageController.uploadPhotoFile(
          photo: photo!,
          filename: tempMemo.photoFilename,
          uid: state.widget.user.uid,
          listener: (int progress) {
            state.render(() {
              progressMessage = progress == 100 ? null : 'uploading: $progress %';
            });
          },
        );
        tempMemo.photoURL = result[ArgKey.downloadURL];
        update[DocKeyPhotoMemo.photoURL.name] = tempMemo.photoURL;
        var labelsGot;
        if(radioGroupValue==0){
          print("*********** getting image labels *****************");
          labelsGot=await GoogleMLController.getImageLabels(photo: photo!);
        }else{
          print("*********** getting image text *****************");
          labelsGot=await GoogleMLController.getTextLables(photo: photo!);
        }
        tempMemo.imageLabels =labelsGot;
        update[DocKeyPhotoMemo.imageLabels.name] = tempMemo.imageLabels;
        update[DocKeyPhotoMemo.mlAppliedBy.name] = radioGroupValue==0?"label":"text";


      }

      // update Firestore doc
      if (tempMemo.title != state.widget.photoMemo.title) {
        update[DocKeyPhotoMemo.title.name] = tempMemo.title;
      }
      if (tempMemo.memo != state.widget.photoMemo.memo) {
        update[DocKeyPhotoMemo.memo.name] = tempMemo.memo;
      }
      if (!listEquals(tempMemo.shareWith, state.widget.photoMemo.shareWith)) {
        update[DocKeyPhotoMemo.sharedWith.name] = tempMemo.shareWith;
      }

      if (update.isNotEmpty) {
        // change has been made
        tempMemo.timestamp = DateTime.now();
        update[DocKeyPhotoMemo.timestamp.name] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(docId: tempMemo.docId!, update: update);

        // update the original
        state.widget.photoMemo.copyFrom(tempMemo);
      }
      print("done updated");
      stopCircularProgress(state.context);

      state.render(() => state.editMode = false);
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('======== failed to update: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'failed to update: $e');
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      state.render(() => photo = File(image.path));
    } catch (e) {
      if (Constant.devMode) print('====== failed to get a pic: $e');
      showSnackBar(
          context: state.context, message: 'failed to get a picture: $e');
    }
  }

  void saveTitle(String? value) {
    if (value != null) {
      tempMemo.title = value;
    }
  }

  void saveMemo(String? value) {
    if (value != null) {
      tempMemo.memo = value;
    }
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      var emailList =
          value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
      tempMemo.shareWith = emailList;
    } else {
      tempMemo.shareWith = [];
    }
  }
}
