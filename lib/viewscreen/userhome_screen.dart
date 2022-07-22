import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/comment_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/view_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/model/user_model.dart';
import 'package:lesson3/viewscreen/addphotomemo_screen.dart';
import 'package:lesson3/viewscreen/change_password_screen.dart';
import 'package:lesson3/viewscreen/comment_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/favourite_screen.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';
import 'package:lesson3/viewscreen/views_screen.dart';
import 'package:lesson3/widgets/custom_widgets.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';

  const UserHomeScreen(
      {required this.user, required this.photoMemoList, Key? key})
      : super(key: key);

  final User user;
  final List<PhotoMemo> photoMemoList;

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;
  late String email;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    email = widget.user.email ?? 'No email';
  }

  void render(fn) => setState(fn);

  bool sortAz=true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('User Home'),
          actions: [
            con.selected.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: con.cancel,
                  ),
            con.selected.isEmpty
                ? IconButton(
                    onPressed: con.search,
                    icon: const Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: con.delete,
                    icon: const Icon(Icons.delete),
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return UserAccountsDrawerHeader(
                        currentAccountPicture: const Icon(
                          Icons.person,
                          size: 70.0,
                        ),
                        accountName: const Text('no profile'),
                        accountEmail: Text(email),
                      );
                    }
                    if (snapshot.data?.size == 0) {
                      return UserAccountsDrawerHeader(
                        currentAccountPicture: const Icon(
                          Icons.person,
                          size: 70.0,
                        ),
                        accountName: const Text('no profile'),
                        accountEmail: Text(email),
                      );
                    }
                    UserModel userModel = UserModel.fromJson(
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>);
                    return UserAccountsDrawerHeader(
                      currentAccountPicture: userModel.imgUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 70.0,
                            )
                          : customProfileAvatar(userModel.imgUrl!),
                      accountName: Text(userModel.name!),
                      accountEmail: Text(email),
                    );
                  }),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: con.profile,
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Shared With'),
                onTap: con.sharedWith,
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Favourites'),
                onTap: con.favourite,
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key_rounded),
                title: const Text('Change Password'),
                onTap: con.changepassword,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: widget.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Found!',
                style: Theme.of(context).textTheme.headline6,
              )
            : Column(
                children: [
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: GestureDetector(
                  //       onTap: () {
                  //       setState(() {
                  //       if(sortAz){
                  //         widget.photoMemoList.sort((a, b) => a.title.compareTo(b.title));
                  //         sortAz=false;
                  //       }else{
                  //         sortAz=true;
                  //         widget.photoMemoList.sort((b, a) => a.title.compareTo(b.title));
                  //       }
                  //       });
                  //       }, child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Icon(Icons.filter_alt_outlined),
                  //           Text('Sort By: Az-Za / Za-Az')
                  //         ],
                  //       )),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: con.photoMemoList.length,
                      itemBuilder: (context, index) {
                        PhotoMemo photoMemo = con.photoMemoList[index];
                        return ListTile(
                          selected: con.selected.contains(index),
                          selectedTileColor: Colors.blue[100],
                          // titleColor: Colors.grey,
                          leading: WebImage(
                            url: photoMemo.photoURL,
                            context: context,
                          ),

                          title: Text(con.photoMemoList[index].title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                con.photoMemoList[index].memo.length >= 40
                                    ? con.photoMemoList[index].memo
                                            .substring(0, 40) +
                                        '...'
                                    : con.photoMemoList[index].memo,
                              ),
                              Text(
                                  'Created By: ${con.photoMemoList[index].createdBy}'),
                              Text(
                                  'Shared With: ${con.photoMemoList[index].shareWith}'),
                              Text(
                                  'Timestamp: ${con.photoMemoList[index].timestamp}'),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (photoMemo.dislikedBy.contains(
                                            FirebaseAuth
                                                .instance.currentUser!.uid)) {
                                          photoMemo.dislikedBy.remove(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          FirestoreController
                                              .removeFromDisliked(
                                                  docId: photoMemo.docId!);
                                        } else {
                                          photoMemo.dislikedBy.add(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          FirestoreController.addToDisliked(
                                              docId: photoMemo.docId!);

                                          photoMemo.likedBy.remove(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          FirestoreController.removeFromLike(
                                              docId: photoMemo.docId!);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Badge(
                                        badgeContent: Text(
                                            "${photoMemo.dislikedBy.length}"),
                                        child: photoMemo.dislikedBy.contains(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            ? Icon(
                                                Icons.thumb_down,
                                                color: Colors.blue,
                                              )
                                            : Icon(
                                                Icons.thumb_down,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (photoMemo.likedBy.contains(
                                            FirebaseAuth
                                                .instance.currentUser!.uid)) {
                                          photoMemo.likedBy.remove(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          FirestoreController.removeFromLike(
                                              docId: photoMemo.docId!);
                                        } else {
                                          photoMemo.likedBy.add(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          FirestoreController.addToLiked(
                                              docId: photoMemo.docId!);

                                          photoMemo.dislikedBy.remove(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          FirestoreController
                                              .removeFromDisliked(
                                                  docId: photoMemo.docId!);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Badge(
                                        badgeContent:
                                            Text("${photoMemo.likedBy.length}"),
                                        child: photoMemo.likedBy.contains(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            ? Icon(
                                                Icons.thumb_up,
                                                color: Colors.blue,
                                              )
                                            : Icon(
                                                Icons.thumb_up,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (photoMemo.favouritesBy.contains(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid)) {
                                            photoMemo.favouritesBy.remove(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                            FirestoreController
                                                .removeFromFavourite(
                                                    docId: photoMemo.docId!);
                                          } else {
                                            photoMemo.favouritesBy.add(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                            FirestoreController.addToFavourite(
                                                docId: photoMemo.docId!);
                                          }
                                        });
                                      },
                                      icon: photoMemo.favouritesBy.contains(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          ? Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            )
                                          : Icon(
                                              Icons.favorite_border,
                                              color: Colors.black,
                                            )),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommentScreen(
                                            postDocId: photoMemo.docId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Badge(
                                        badgeContent: StreamBuilder<
                                                QuerySnapshot>(
                                            stream: CommentController
                                                .getAllComments(
                                                    postId: photoMemo.docId!),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Text('0');
                                              }
                                              if (snapshot.data!.size == 0) {
                                                return Text('0');
                                              }
                                              return Text(
                                                  "${snapshot.data!.size}");
                                            }),
                                        shape: BadgeShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Icon(
                                          Icons.comment_bank_outlined,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const Icon(Icons.arrow_right),
                                ],
                              ),
                              
                              InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      builder: (builder){
                                        return ViewsScreen(postId:photoMemo.docId!,);
                                      }
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width:MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.5),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))
                                  ),
                                  child: Center(child: StreamBuilder<QuerySnapshot>(
                                      stream: ViewController.getViews(photoMemo.docId!),
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
                                      return Text('${snapshot.data!.size} Views',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic,fontSize: 22),);
                                    }
                                  )),
                                ),
                              )
                            ],
                          ),
                          onTap: () => con.onTap(index),
                          onLongPress: () => con.onLongPress(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> selected = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWithMe(
        email: state.email,
      );
      await Navigator.pushNamed(
        state.context,
        sharedWithScreen.routeName,
        arguments: {
          ArgKey.photoMemoList: photoMemoList,
          ArgKey.user: state.widget.user,
        },
      );
      Navigator.of(state.context).pop(); // push in the drawer
    } catch (e) {
      if (Constant.devMode) print('======= get Shared list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void favourite() async {
    try {
      await Navigator.pushNamed(
        state.context,
        FavouriteScreen.routeName,
      ); // push in the drawer
    } catch (e) {
      if (Constant.devMode) print('======= get Shared list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void profile() async {
    try {
      await Navigator.pushNamed(
        state.context,
        ProfileScreen.routeName,
      ); // push in the drawer
    } catch (e) {
      if (Constant.devMode) print('======= get Profile list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get Profile list: $e',
      );
    }
  }

  void changepassword() async {
    try {
      await Navigator.pushNamed(
        state.context,
        ChangePasswordScreen.routeName,
      ); // push in the drawer
    } catch (e) {
      if (Constant.devMode) print('======= get Change Password list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get change password: $e',
      );
    }
  }

  void cancel() {
    state.render(() => selected.clear());
  }

  void delete() async {
    startCircularProgress(state.context);
    selected.sort();
    for (int i = selected.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[selected[i]];
        await FirestoreController.deleteDoc(docId: p.docId!);
        await CloudStorageController.deleteFile(filename: p.photoFilename);
        state.render(() {
          photoMemoList.removeAt(selected[i]);
        });
      } catch (e) {
        if (Constant.devMode) print('========= failed to delete: $e');
        showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Failed! Sign Out and IN again to get updated list\n$e',
        );
        break; // quit further processing
      }
    }
    state.render(() => selected.clear());
    stopCircularProgress(state.context);
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim());
      }
    }
    startCircularProgress(state.context);

    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        results =
            await FirestoreController.getPhotoMemoList(email: state.email);
      } else {
        results = await FirestoreController.searchImages(
          email: state.email,
          searchLabel: keys,
        );
      }
      stopCircularProgress(state.context);
      state.render(() {
        photoMemoList = results;
      });
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('========= failed to search: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'failed to search: $e');
    }
  }

  void addButton() async {
    await Navigator.pushNamed(state.context, AddPhotoMemoScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photoMemoList: photoMemoList,
        });
    state.render(() {}); // rerender the screen
  }

  Future<void> signOut() async {
    try {
      if(FirebaseAuth.instance.currentUser!=null) {
        await AuthController.signout();
      }
    } catch (e) {
      if (Constant.devMode) print('======== sign out error: $e');
      showSnackBar(context: state.context, message: 'Sign out error: $e');
    }
    Navigator.of(state.context).pop(); // close the drawer
    Navigator.of(state.context).pop(); // return to Start screen
  }

  void onTap(int index) async {
    if (selected.isNotEmpty) {
      onLongPress(index);
      return;
    }
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.onePhotoMemo: photoMemoList[index],
        });
    state.render(() {});
  }

  void onLongPress(int index) {
    state.render(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }
}
