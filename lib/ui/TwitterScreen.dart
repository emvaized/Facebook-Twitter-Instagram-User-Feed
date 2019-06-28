import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart' as random;

import '../ui/showListOfPosts.dart';

bool isLoggedIn = false;
var _fetchedData;
var thisSession;
var twitterLogin = new TwitterLogin(
  consumerKey: 'CLXV7kdMJei6kSuXXHFNz0J2o',
  consumerSecret: 'GMOLJZmlAbGbDYxzC3qQU7u3dWPguuYg0ozeRkJgte0Eq0Z83T',
);

class Twitter extends StatefulWidget {
  @override
  _TwitterState createState() => _TwitterState();
}

class _TwitterState extends State<Twitter> {
  bool _isLoading = true;
  bool _errorWhileLoading = false;
  String error;

  void initiateTwitterLogin() async {
    final TwitterSession session = await twitterLogin.currentSession;
    thisSession = session;
    if (session != null) {
      isLoggedIn = true;
      _getAllDataFromTwitter(session);
    } else {
      isLoggedIn = false;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: isLoggedIn
            ? _isLoading
                ? CircularProgressIndicator()
                : RefreshIndicator(
                    child: ShowListOfPosts(
                      errorWhileLoading: _errorWhileLoading,
                      profileData: _fetchedData,
                      socialNetwork: 'twitter',
                    ),
                    onRefresh: () => _getAllDataFromTwitter(thisSession),
                  )
            : _displayLoginButton(),
      ),
    );
  }

  _getAllDataFromTwitter(session) async {
    setState(() {
      _isLoading = true;
    });
    _fetchedData = await getData(session, '/1.1/statuses/user_timeline.json');
    setState(() {
      _isLoading = false;
    });
  }

  void _showLoginRequiredUI() async {
    setState(() {
      _isLoading = true;
    });
    print('////////////////////show Login Required UI');
    final TwitterLoginResult result = await twitterLogin.authorize();
    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
        setState(() {
          _errorWhileLoading = false;
        });
        isLoggedIn = true;
        _showSnackBar(context);
        _getAllDataFromTwitter(session);
        break;
      case TwitterLoginStatus.cancelledByUser:
        break;
      case TwitterLoginStatus.error:
        print('///////////////?Error');
        break;
    }
  }

  void _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 1500),
      content: new Text(
        'Logged in to Twitter',
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
                              'Log in to Twitter',
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                        onTap: _showLoginRequiredUI,
                      )),
                ),
              ]);
  }

  Future<http.Response> _twitterGet(String base, List<List<String>> params, session) async {

    String oauthConsumer =
        'oauth_consumer_key="${Uri.encodeComponent(twitterLogin.consumerKey)}"';
    String oauthToken = 'oauth_token="${Uri.encodeComponent(session.token)}"';
    String oauthNonce =
        'oauth_nonce="${Uri.encodeComponent(random.randomAlphaNumeric(42))}"';
    String oauthVersion = 'oauth_version="${Uri.encodeComponent("1.0")}"';
    String oauthTime =
        'oauth_timestamp="${(DateTime.now().millisecondsSinceEpoch / 1000).toString()}"';
    String oauthMethod =
        'oauth_signature_method="${Uri.encodeComponent("HMAC-SHA1")}"';
    var oauthList = [
      oauthConsumer.replaceAll('"', ""),
      oauthNonce.replaceAll('"', ""),
      oauthMethod.replaceAll('"', ""),
      oauthTime.replaceAll('"', ""),
      oauthToken.replaceAll('"', ""),
      oauthVersion.replaceAll('"', "")
    ];
    var paramMap = Map<String, String>();

    if (params != null)
      for (List<String> param in params) {
        oauthList.add(
            '${Uri.encodeComponent(param[0])}=${Uri.encodeComponent(param[1])}');
        paramMap[param[0]] = param[1];
      }

    oauthList.sort();
    String oauthSig =
        'oauth_signature="${Uri.encodeComponent(generateSignature("GET", "https://api.twitter.com$base", oauthList, session.secret))}"';

    return await http
        .get(new Uri.https("api.twitter.com", base, paramMap), headers: {
      "Authorization":
          'Oauth $oauthConsumer, $oauthNonce, $oauthSig, $oauthMethod, $oauthTime, $oauthToken, $oauthVersion',
      "Content-Type": "application/json"
    }).timeout(Duration(seconds: 15));
  }

  Future getData(session, base) async {
     final response = await _twitterGet(base, null, session);

    if (response.statusCode == 200) {
      try {
        var _resultedData = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorWhileLoading = false;
        });
        print('..................................');
        print(_resultedData);
        return _resultedData;
      } catch (e) {
        print(e);
        setState(() {
          _errorWhileLoading = true;
          _isLoading = false;
          if (e['errors'][0]['message'] != null) {
            error = json.decode(e)['errors'][0]['message'];
            // error = e;
          }
        });
        return null;
      }
    } else {
      print("Error retrieving data from Twitter");
      setState(() {
        _errorWhileLoading = true;
        _isLoading = false;
      });
      print(response.body);
      return null;
    }
  }

  static String generateSignature(String method, String base, List<String> sortedItems, secret) {
    String param = '';

    for (int i = 0; i < sortedItems.length; i++) {
      if (i == 0)
        param = sortedItems[i];
      else
        param += '&${sortedItems[i]}';
    }

    String sig =
        '$method&${Uri.encodeComponent(base)}&${Uri.encodeComponent(param)}';
    String key =
        '${Uri.encodeComponent(twitterLogin.consumerSecret)}&${Uri.encodeComponent(secret)}';
    var digest = Hmac(sha1, utf8.encode(key)).convert(utf8.encode(sig));
    return base64.encode(digest.bytes);
  }

  @override
  void initState() {
    if (isLoggedIn) {
      _fetchedData != null
          ? setState(() {
              _isLoading = false;
            })
          : initiateTwitterLogin();
    } else {
      initiateTwitterLogin();
    }

    super.initState();
  }
}
