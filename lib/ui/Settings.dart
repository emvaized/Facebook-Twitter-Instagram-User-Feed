import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import './ManageScreens.dart';

class SettingsScreen extends StatefulWidget {
  final bool facebookEnabled;
  final twitterEnabled;
  final bool instaEnabled;

  SettingsScreen ({Key key, this.facebookEnabled, this.twitterEnabled, this.instaEnabled}) : super (key: key );

  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blueGrey,
        title: new Text('Settings'),
       // centerTitle: true,
      ),
        body:
        new Column(children: <Widget>[
//          new ListTile(
//            title: new Text('Screens:', textAlign: TextAlign.center),
//        ),
        Add(facebookEnabled: widget.facebookEnabled, twitterEnabled: widget.twitterEnabled, instaEnabled: widget.instaEnabled,)
    ] )
    );
  }
}



