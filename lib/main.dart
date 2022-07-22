import 'package:flutter/material.dart';
import 'package:lesson3/viewscreen/addphotomemo_screen.dart';
import 'package:lesson3/viewscreen/change_password_screen.dart';
import 'package:lesson3/viewscreen/comment_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/edit_comment_screen.dart';
import 'package:lesson3/viewscreen/error_screen.dart';
import 'package:lesson3/viewscreen/favourite_screen.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lesson3/viewscreen/userhome_screen.dart';
import 'firebase_options.dart';
import 'model/constant.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const Lesson3App());
}
class Lesson3App extends StatelessWidget {

  const Lesson3App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.devMode,
      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (context) => const StartScreen(),
        CommentScreen.routeName: (context) =>  CommentScreen(),
        EditCommentScreen.routeName: (context) =>  EditCommentScreen(),
        ProfileScreen.routeName: (context) =>  ProfileScreen(),
        ChangePasswordScreen.routeName: (context) =>  ChangePasswordScreen(),





        FavouriteScreen.routeName: (context) => const FavouriteScreen(),


        UserHomeScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return UserHomeScreen(user: user, photoMemoList: photoMemoList,);

          }
        },
        AddPhotoMemoScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return AddPhotoMemoScreen(user: user, photoMemoList: photoMemoList,);

          }
        },
        DetailedViewScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for DetailedViewScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var PhotoMemo = argument[ArgKey.onePhotoMemo];
            return DetailedViewScreen(user: user, photoMemo: PhotoMemo,);

          }
          
        },
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        sharedWithScreen.routeName:(context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return sharedWithScreen(user: user, photoMemoList: photoMemoList,);

          }
        },
      },
    );
  }

}
