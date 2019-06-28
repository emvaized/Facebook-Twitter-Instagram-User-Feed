import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewPost extends StatefulWidget {
   bool facebookEnabled;
   bool twitterEnabled;
   bool instaEnabled;

  NewPost ({Key key, this.facebookEnabled, this.twitterEnabled, this.instaEnabled}) : super (key: key );

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  var _newPostController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(icon: Icon(Icons.arrow_back), color: Colors.black87, onPressed: () => Navigator.of(context).pop(),),
          title: new Text('New Post', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54),),
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.done, color: Colors.black87,),
                onPressed: () => Navigator.pop(context, {
                    'facebookEnabled': widget.facebookEnabled,
                    'twitterEnabled': widget.twitterEnabled,
                  'instaEnabled': widget.instaEnabled
            }))
          ],
        ),
        body: ListView(
                 children: <Widget>[ Column(children: <Widget>[
                  Padding(
                    child: Container(
                      child: new ConstrainedBox(
                               constraints: BoxConstraints(
                               maxHeight: 300.0,
                               ),
                        child: new Scrollbar(
                          child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            child: new TextField(
                                style: TextStyle(fontSize: 18),
                                autofocus: true,
                                autocorrect: true,
                                maxLines: null,
                                controller: _newPostController,
                                decoration: InputDecoration(helperText: 'Enter your post here'),
                              ),
                          ),
                        ),
                      ),
                      ),
                    padding: EdgeInsets.all(13.5),),
                  new ListTile(
                    title: new Text('Social networks:', textAlign: TextAlign.center),
                  ),
                   new Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: <Widget>[
                       new Column(
                         children: <Widget>[
                           GestureDetector(
                             onTap: () => setState(() {widget.facebookEnabled = !widget.facebookEnabled;}),
                             child: new Row (children: <Widget> [ new Checkbox(value: widget.facebookEnabled, onChanged: (bool value) => setState(() {widget.facebookEnabled = value;})),
                             new Text('Facebook') ],
                             ) )
                         ]
                       ),
                       new Column(
                           children: <Widget>[
                             GestureDetector(
                               onTap: () => setState(() {widget.twitterEnabled = !widget.twitterEnabled;}),
                               child: new Row (children: <Widget> [ new Checkbox(value: widget.twitterEnabled, onChanged: (bool value) => setState(() {widget.twitterEnabled = value;})),
                               new Text('Twitter')  ],
                               ), )
                           ]
                       ),
                       new Column(
                           children: <Widget>[
                             GestureDetector(
                               onTap: () => setState(() {widget.instaEnabled = !widget.instaEnabled;}),
                               child: new Row (children: <Widget> [ new Checkbox(value: widget.instaEnabled, onChanged: (bool value) => setState(() {widget.instaEnabled = value;})),
                                 new Text('Instagram')  ],
                               ), )
                           ]
                       )
                     ],
                   )
                ] )
            ])

    );
  }

  _loadSavedData() async {
    //if (facebookLoginToken == null) {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool('newPostFacebook') != null &&
    preferences.getBool('newPostTwitter') != null &&
    preferences.getBool('newPostInstagram') != null ) {
      widget.instaEnabled = preferences.getBool('newPostFacebook');
      widget.twitterEnabled = preferences.getBool('newPostTwitter');
      widget.instaEnabled = preferences.getBool('newPostInstagram');


    } else {
      widget.instaEnabled = true;
      widget.twitterEnabled = true;
      widget.instaEnabled = true;

    }
    // }
  }

  _saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('newPostFacebook', widget.facebookEnabled);
    preferences.setBool('newPostTwitter', widget.twitterEnabled);
    preferences.setBool('newPostInstagram', widget.instaEnabled);

  }
}
