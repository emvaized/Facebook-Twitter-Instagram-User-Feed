import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:database_intro/main.dart' as main;

class Add extends StatefulWidget {
  bool facebookEnabled;
  bool twitterEnabled;
  bool instaEnabled;

  Add ({Key key, this.facebookEnabled, this.twitterEnabled, this.instaEnabled}) : super (key: key );

  @override
  _AddState createState() => new _AddState();
}

class _AddState extends State<Add> {
//  bool newUsersEnabled;
//  bool newPostsEnabled;
//  bool settingsChanged;

  @override
  Widget build(BuildContext context) {
    return  new Padding(
        padding: EdgeInsets.all(8.0),
        child: new Column(
       // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CheckboxListTile(
            value: widget.facebookEnabled,
            onChanged: (bool value) {
              setState(() { widget.facebookEnabled = value;  });
            },
            title: Text ('Facebook'),),
          new CheckboxListTile(
              value: widget.twitterEnabled,
              onChanged: (bool value) {
                setState(() { widget.twitterEnabled = value;  });
              },
              title: Text ('Twitter')),
          new CheckboxListTile(
              value: widget.instaEnabled,
              onChanged: (bool value) {
                setState(() { widget.instaEnabled = value;  });
              },
              title: Text ('Instagram')),
          new ListTile(
            //trailing: Icon(Icons.done),
           onTap: () {
             if (Navigator.canPop(context)) {
               Navigator.pop(context, {
                 'facebookEnabled': widget.facebookEnabled,
                 'twitterEnabled': widget.twitterEnabled,
                 'instaEnabled': widget.instaEnabled
               }); }
             _saveSettings();
             //main.main();
             main.main();
           },
           // padding: EdgeInsets.only(top: 8.0),
            title: new Row (mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text ('Done', textAlign: TextAlign.center,),
                Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: new Icon(Icons.done)
                )
              ],)
//            title: new FlatButton(
//                onPressed: () {
//                  if (Navigator.canPop(context)) {
//                    Navigator.pop(context, {
//                      'facebookEnabled': widget.facebookEnabled,
//                      'twitterEnabled': widget.twitterEnabled,
//
//                      //  'settingsChanged': settingsChanged
//                    }); }
//
//                  _saveSettings();
//                    main.main();
//                },
//                textColor: Colors.black,
//                padding: EdgeInsets.all(5.0),
//                //color: Colors.white,
//                child: new Text('Done')),
          )
        ],
      ));
  }

//  _checkChanged () {
//    if (newUsersEnabled != widget.usersEnabled || newPostsEnabled != widget.postsEnabled)
//    {settingsChanged = true;}
//  }

  _saveSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('facebookEnabled', widget.facebookEnabled); // key : value ==> "paulo" : "Smart"
    preferences.setBool('twitterEnabled', widget.twitterEnabled);
    preferences.setBool('instaEnabled', widget.instaEnabled);
  }

//setTextField () {
//  _cityFieldController.text = widget.currentCity =! null ? widget.currentCity : null;
// }




}



