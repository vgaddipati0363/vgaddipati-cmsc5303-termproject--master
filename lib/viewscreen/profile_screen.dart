
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/ml_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/model/user_model.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

import '../widgets/custom_widgets.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreen();
  }
}

class _ProfileScreen extends State<ProfileScreen> {
  File? _image;

  final txtName = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPhone = TextEditingController();
  final txtAddress = TextEditingController();
  final txtPaypalEmail = TextEditingController();

  String? imgUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   getInfo();
  }

  bool isLoading=true;

  getInfo() async {
    _userModel=await UserModel.getUserInfo();
      isLoading=false;
      setValues();
  }

  @override
  Widget build(BuildContext context) {
    print("file selected is ${_image}");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        title: Text("Edit Profile"),
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: <Widget>[

                    //profile
                    SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                    Stack(
                      children: [
                        _image==null&&imgUrl==null?CircleAvatar(
                            backgroundColor:Colors.blue,
                            radius: 50,
                            child: Icon(Icons.person,size: 45,color:Colors.white,)
                        ):_image!=null?CircleAvatar(
                          radius: 50.0,
                          backgroundImage:FileImage(_image!),
                          backgroundColor: Colors.transparent,
                        ):customProfileAvatar(imgUrl!),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:Colors.blue,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt_outlined,color:Colors.white),
                              onPressed: (){
                                _showPicker(context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),


                    // form

                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      controller: txtName,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      autocorrect: true,
                      controller: txtEmail,
                      enabled: false,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                    ElevatedButton(
                      onPressed: (){
                        updateAction();
                      },
                      child: Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  _imgFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromGallery() async {
    XFile? image = await  ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = File(image!.path);
    });
  }


  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child:  Wrap(
                children: <Widget>[
                  ListTile(
                      leading:  Icon(Icons.photo_library),
                      title:  Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading:  Icon(Icons.photo_camera),
                    title:  Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


  String? name,email;

  void getValues(){
    name=txtName.text;
    email=txtEmail.text;

  }

  bool isEmpty(){
    if(name!.isEmpty||email!.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  UserModel? _userModel;
  void setValues(){
    setState(() {
      txtEmail.text=_userModel!.email!;
      txtName.text=_userModel!.name!;
      imgUrl=_userModel!.imgUrl;
    });
  }

  void updateAction() async{
    try{
      getValues();
      if(isEmpty()){
        showSnackBar(context: context, message: 'Please enter name');
      }
      else{
        startCircularProgress(context);
        if(_image!=null){

          // delete previous image from storage
           UserModel.deleteFromStorage(imgUrl);

          // upload image to fire storage
          imgUrl=await UserModel.uploadImageToFirestore(_image!);
          _image=null;
          print("User Image uploaded Image is ${imgUrl}");
        }
        _userModel=UserModel(name: name,imgUrl: imgUrl,userId: FirebaseAuth.instance.currentUser!.uid,email: email);
       bool result= await UserModel.updateUser(_userModel!);
       stopCircularProgress(context);
        if(result){
          showSnackBar(context: context, message: 'Profile updated successfully');
          setValues();
        }
      }
    }catch(e){
      showSnackBar(context: context, message:e.toString());
    }
  }

}
