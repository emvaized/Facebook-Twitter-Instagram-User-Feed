import 'package:database_intro/ui/InstagramScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import  './my_flutter_app_icons.dart' as CustomIcons;
import './ui/ManageScreens.dart';
import './ui/EmptyScreen.dart';
import './ui/FacebookPosts.dart';
import './ui/NewPostScreen.dart';
import './ui/Settings.dart';
import './ui/TwitterScreen.dart';

List<BottomNavigationBarItem> _bottomBarItems;
List<Widget> _screens;
PageController _pageController = PageController();
int _cIndex = 0;
bool _facebookEnabled;
bool _twitterEnabled;
bool _instaEnabled;
String _appName;
var _leadingIcon;
var _fabColor;
bool _showFab = true;

void main() async {
  _bottomBarItems = [];
  _screens = [];

  await _loadSavedData();

  runApp(new MaterialApp(
    title: "Poster",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      accentColor: Colors.black87,
    ),
    home: new Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(

          title: new Text(
            _appName,
            style: new TextStyle(color: Colors.black54),
          ),
          centerTitle: true,
          leading: _leadingIcon,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.settings, color: Colors.black54),
                onPressed: () {
                  _goToSettingsScreen(context);
                })
          ],
          backgroundColor: Colors.white,
        ),
//       floatingActionButton: _showFab ? new FloatingActionButton(
//            elevation: 0.0,
//            child: new Icon(Icons.add),
//            backgroundColor: _fabColor,
//           onPressed: () {
//             _goToNewPostScreen(context);
//           } ) : null,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => {
               setState(() {
                  _cIndex = index;
               }),
                _updateAppName(index),
                _updateLeadingIcon(),
                _updateFabColor()
              },
          children: _screens,
          physics: BouncingScrollPhysics(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _cIndex,
          type: BottomNavigationBarType.shifting,
          items: List.of(_bottomBarItems),
          onTap: (index) {
            _changeTab(index);
          },
        ));
  }

  void _changeTab(index) async {
    await _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
    _updateAppName(index);
    _cIndex = index;
    setState(() { });
    _updateLeadingIcon();
    _updateFabColor();
  }

  Future _goToSettingsScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
          return new SettingsScreen(
            facebookEnabled: _facebookEnabled, twitterEnabled: _twitterEnabled, instaEnabled: _instaEnabled
          );
    }));

    if (results != null &&
            results.containsKey('facebookEnabled') &&
            results.containsKey('twitterEnabled') &&
            results.containsKey('instaEnabled')

        ) {
      setState(() {
        _facebookEnabled = results['facebookEnabled'];
        _twitterEnabled = results['twitterEnabled'];
        _instaEnabled = results['instaEnabled'];
      });

      await _saveSettings();
      _loadSavedData();
      _returnToFirstPage();
    }
  }
  _goToNewPostScreen(BuildContext context) async {
    Navigator.of(context).push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new NewPost(
          facebookEnabled: _facebookEnabled, twitterEnabled: _twitterEnabled, instaEnabled: _instaEnabled);
    }));

  }

}


_updateAppName(index) {
  _appName = _screens[index].toString();
}

_updateFabColor(){
  switch (_appName) {
    case 'Facebook': _fabColor = Colors.blueAccent; break;
    case 'Twitter': _fabColor = Colors.blue; break;
    case 'Instagram': _fabColor = Colors.red; break;
    default: _fabColor = Colors.blue; break;
  }
}

_updateLeadingIcon() {
  switch (_appName) {
    case 'Users':
      _leadingIcon = Icon(
        Icons.supervised_user_circle, color: Colors.black54,
      );
      break;
    case 'Posts':
      _leadingIcon = Icon(
        Icons.featured_play_list, color: Colors.black54,
      );
      break;
    case 'Add':
      _showFab = false;
      _leadingIcon = Icon(
        Icons.add, color: Colors.black54,
      );
      break;
    case 'Poster':
      _showFab = false;
      _leadingIcon = Icon(
        Icons.featured_play_list, color: Colors.black54,
      );
      break;
    case 'Facebook':
      _showFab = true;
      _leadingIcon = Icon(
        CustomIcons.MyFlutterApp.facebook, color: Colors.blueAccent,
      );
      break;
    case 'Twitter':
      _showFab = true;
      _leadingIcon = Icon(
        CustomIcons.MyFlutterApp.twitter, color: Colors.blue,
      );
      break;
    case 'Instagram':
      _showFab = true;
      _leadingIcon = Icon(
        CustomIcons.MyFlutterApp.instagram, color: Colors.red,
      );
      break;
    default:
      _showFab = true;
      _leadingIcon = Icon(
        Icons.android, color: Colors.black54,
      );
      break;
  }
}

_returnToFirstPage() {
  if (_cIndex != 0) {
  _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
 _cIndex = 0;
 // _pageController.jumpToPage(_cIndex);
  }
}

_saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(
      'facebookEnabled', _facebookEnabled);
  preferences.setBool(
      'twitterEnabled', _twitterEnabled);
  preferences.setBool(
      'instaEnabled', _instaEnabled);
}

_loadSavedData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getBool('facebookEnabled') != null &&
      preferences.getBool('twitterEnabled') != null &&
      preferences.getBool('instaEnabled') != null )
  {
    _facebookEnabled = preferences.getBool('facebookEnabled');
    _twitterEnabled = preferences.getBool('twitterEnabled');
    _instaEnabled = preferences.getBool('instaEnabled');
  } else {
    _facebookEnabled = false;
    _twitterEnabled = false;
    _instaEnabled = false;
  }
  _bottomBarItems = [];
  _screens = [];

  if (_facebookEnabled) {
    _bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(CustomIcons.MyFlutterApp.facebook,
            color: Color.fromARGB(255, 0, 0, 0)),
        title: new Text('')));
    _screens.add(Facebook());
  }

if (_twitterEnabled) {
  _bottomBarItems.add(BottomNavigationBarItem(
      icon: Icon(CustomIcons.MyFlutterApp.twitter,
          color: Color.fromARGB(255, 0, 0, 0)),
      title: new Text('')));
  _screens.add(Twitter());
}

  if (_instaEnabled) {
    _bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(CustomIcons.MyFlutterApp.instagram,
            color: Color.fromARGB(255, 0, 0, 0)),
        title: new Text('')));
    _screens.add(Instagram());
  }

  if (_bottomBarItems.length < 2 || _screens.length < 2) {
    if (_bottomBarItems.length < 1 || _screens.length < 1) {
      _bottomBarItems.add(BottomNavigationBarItem(
          icon: Icon(Icons.featured_play_list, color: Color.fromARGB(255, 0, 0, 0)),
          title: new Text('')));
      _screens.add(Poster());
    }
    _bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
        title: new Text('')));
    _screens.add(Add(facebookEnabled: _facebookEnabled, twitterEnabled: _twitterEnabled, instaEnabled: _instaEnabled));
    //_returnToFirstPage();
  }

  _returnToFirstPage();
  _updateAppName(_cIndex);
  _updateLeadingIcon();
  _updateFabColor();
}
