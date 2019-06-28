import 'dart:convert';

import 'package:database_intro/ui/showListOfPosts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './login_presenter.dart';

var token;
var _fetchedInstagramPosts;
bool _errorWhileLoading = false;
bool _isLoggedIn = false;

class Instagram extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new LoginScreen(_scaffoldKey);
  }
}

class LoginScreen extends StatefulWidget {
  GlobalKey<ScaffoldState> skey;

  LoginScreen(GlobalKey<ScaffoldState> this.skey, {Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => new _LoginScreenState(skey);
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginViewContract {
  LoginPresenter _presenter;
  bool _isLoading = true;
  GlobalKey<ScaffoldState> _scaffoldKey;

  getPosts() async {
    setState(() {
      _isLoading = true;
    });
    print('........................................');
    var _response = await http.get(
        'https://api.instagram.com/v1/users/self/media/recent/?access_token=${token}');
    print(json.decode(_response.body));
    _fetchedInstagramPosts = json.decode(_response.body)['data'];
    setState(() {
      _isLoading = false;
    });
  }

  _LoginScreenState(GlobalKey<ScaffoldState> skey) {
    _presenter = new LoginPresenter(this);
    _scaffoldKey = skey;
  }

  @override
  void onLoginError(String msg) {
    setState(() {
      _isLoading = false;
    });
    print('///////////////LOGIN ERROR');
  }

  @override
  void onLoginScuccess(Token t) {
    setState(() {
      _errorWhileLoading = false;
    });
    token = t.access;
    _isLoggedIn = true;
    _showSnackBar(context);
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Center(
        child: _isLoggedIn
            ? _isLoading
                ? CircularProgressIndicator()
                : RefreshIndicator(
                    child: ShowListOfPosts(
                      profileData: _fetchedInstagramPosts,
                      socialNetwork: 'instagram',
                      errorWhileLoading: _errorWhileLoading,
                    ),
                    onRefresh: () => getPosts(),
                  )
            : _displayLoginScreen(),
      ),
    );
  }

  void _login() {
    setState(() {
      _isLoading = true;
    });
    _presenter.performLogin(context);
  }

  void _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 1500),
      content: new Text(
        'Logged in to Instagram',
        textAlign: TextAlign.center,
      ),
    ));
  }

  _displayLoginScreen() {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: new Icon(Icons.close)),
          new Text(
            'You are not logged in',
          ),
          new Center(
            child: new Padding(
                padding: new EdgeInsets.all(30.0),
                child: new InkWell(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: new Icon(Icons.exit_to_app),
                      ),
                      new Text(
                        'Log in to Instagram',
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  ),
                  onTap: _login,
                )),
          ),
        ]);
  }

  _loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool('isLoggedInInstagram') != null &&
        preferences.getString('instagramLoginToken') != null) {
      _isLoggedIn = preferences.getBool('isLoggedInInstagram');
      token = preferences.getString('instagramLoginToken');
      await getPosts();
    } else {
      _isLoggedIn = false;
      _isLoading = false;
    }
    // }
  }

  _saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedInInstagram', _isLoggedIn);
    preferences.setString('instagramLoginToken', token);
  }

  @override
  void initState() {
    if (_isLoggedIn) {
      _fetchedInstagramPosts != null
          ? setState(() {
              _isLoading = false;
            })
          : _loadSavedData();
    } else {
      _loadSavedData();
    }
    super.initState();
  }

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }
}
