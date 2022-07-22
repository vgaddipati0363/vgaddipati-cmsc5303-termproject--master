import 'package:flutter/material.dart';

class MyAlert{

  static showAlertDialog(BuildContext context,{btnText,btnAction,title,subtitle}) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("CANCEL"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(btnText),
      onPressed:btnAction,
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}