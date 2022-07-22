import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';


class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/changePasswordScreen';

  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final txtPassword=TextEditingController();
  final txtConfirmPassword=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        elevation:0,
      ),
      body: Column(
        children: [
          TextFormField(
            controller: txtPassword,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
            autocorrect: false,
            obscureText: true,
          ),
          TextFormField(
            controller: txtConfirmPassword,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
            ),
            autocorrect: false,
            obscureText: true,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          ElevatedButton(
            onPressed: (){
              changePassword();
            },
            child: Text(
              'Change Password',
              style: TextStyle(color: Colors.white),
            ),
          ),

        ],
      ),
    ));
  }

  String? password,confirmPassword;


  void getValues(){
    password=txtPassword.text;
    confirmPassword=txtConfirmPassword.text;
  }

  bool passwordMatches(){
    if(password==confirmPassword){
      return true;
    }else{
      return false;
    }
  }

  bool isEmpty(){
    if(password!.isEmpty||confirmPassword!.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  Future<void> changePassword() async {
    getValues();
    if(isEmpty()){
      showSnackBar(context: context, message: "Please Enter Passwords");
    }else{
      if(passwordMatches()){
        if(password!.length>5){
        startCircularProgress(context);
         bool result=await AuthController().changePassword(context,password!);
         stopCircularProgress(context);
         if(result) {
           showSnackBar(context: context, message: "Password Changed Successfully");
         }
        }else{
          showSnackBar(context: context, message: "Password should be atleast 6 characters long");
        }
      }else{
        showSnackBar(context: context, message: "Password Doesn't matches");
      }
    }
  }
}

