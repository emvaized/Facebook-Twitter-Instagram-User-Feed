import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/showListOfPosts.dart';

bool isLoggedIn = false;
var profileData;
var profileName;
var facebookLoginResult;
var facebookLoginToken;
var facebookId;

class Facebook extends StatefulWidget {
  @override
  _FacebookState createState() => _FacebookState();
}

class _FacebookState extends State<Facebook> {
  bool _isLoading = true;
  bool _errorWhileLoading = false;

  void initiateFacebookLogin() async {
    setState(() {
      _isLoading = true;
    });
    var facebookLogin = FacebookLogin();
    facebookLoginResult = await facebookLogin.logInWithReadPermissions(
        ['email', 'instagram_basic', 'pages_show_list']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        setState(() {
          _errorWhileLoading = true;
          _isLoading = false;
        });
        onLoginStatusChanged(false, false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false, false);
        break;
      case FacebookLoginStatus.loggedIn:
        facebookLoginToken = facebookLoginResult.accessToken.token;
        setState(() {
          _errorWhileLoading = false;
        });
        isLoggedIn = true;
        _showSnackBar(context);
        _updatePosts();
        break;
    }
  }

  Future<void> _updatePosts() async {
    setState(() {
      _isLoading = true;
    });
    var graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,feed{attachments,message,story,created_time,actions,likes,shares,comments}&access_token=$facebookLoginToken');
    var profile = json.decode(graphResponse.body);
    var fetchedPosts = profile['feed']['data'];
    var profileName = profile['name'];
    var userId = profile['id'];
    var userIdResponse = await http.get(
        "https://graph.facebook.com/v3.2/me/accounts?access_token=$facebookLoginToken");
    print('.........................');
    print('All facebook data fetched');
    print(json.decode(userIdResponse.body)['data']);

    onLoginStatusChanged(true, false,
        profileDataState: fetchedPosts, profileNameState: profileName);
  }

  void onLoginStatusChanged(bool isLoggedInState, bool isLoading,
      {profileDataState, profileNameState}) {
    isLoggedIn = isLoggedInState;
    profileData = profileDataState;
    profileName = profileNameState;
    setState(() {
      this._isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Center(
        child: isLoggedIn
            ? _isLoading
                ? CircularProgressIndicator()
                : RefreshIndicator(
                    child: ShowListOfPosts(
                        profileName: profileName,
                        errorWhileLoading: _errorWhileLoading,
                        profileData: profileData,
                        socialNetwork: 'facebook'),
                    onRefresh: _updatePosts,
                  )
            : _displayLoginButton(),
      ),
    );
  }

  void _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 1500),
      content: new Text(
        'Logged in to Facebook',
        textAlign: TextAlign.center,
      ),
    ));
  }

  _displayLoginButton() {
    return _isLoading
        ? CircularProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: new Icon(Icons.close)),
                Text('You are not logged in'),
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
                                child: new Icon(Icons.exit_to_app)),
                            new Text(
                              'Log in to Facebook',
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                        onTap: () => initiateFacebookLogin(),
                      )),
                ),
              ]);
  }

  _loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool('isLoggedIn') != null &&
        preferences.getString('facebookLoginToken') != null) {
      isLoggedIn = preferences.getBool('isLoggedIn');
      facebookLoginToken = preferences.getString('facebookLoginToken');
      await _updatePosts();
    } else {
      isLoggedIn = false;
      setState(() {
        _isLoading = false;
      });
    }
  }

  _saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(
        'isLoggedIn', isLoggedIn);
    preferences.setString('facebookLoginToken',
        facebookLoginToken);
  }

  @override
  void initState() {
    if (isLoggedIn) {
      profileData != null
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
