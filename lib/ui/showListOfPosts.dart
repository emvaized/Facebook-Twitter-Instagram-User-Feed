import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowListOfPosts extends StatefulWidget {
  var profileData;
  var profileName;
  final socialNetwork;
  bool errorWhileLoading = false;

  ShowListOfPosts ({Key key, this.profileData, this.profileName, this.errorWhileLoading, this.socialNetwork}) : super (key: key );

  getTwitterData (position, String key) {
    switch (key) {
      case 'profile_name': return profileData[position]['user']['name']; break;
      case 'profile_photo': return "https://twitter.com/${profileData[position]['user']['screen_name']}/profile_image?size=mini"; break;
      case 'created': return
//       DateFormat('ddd MMM DD HH:mm:ss +Z yyyy').format(
//          DateTime.parse (
         profileData[position]['created_at'].toString().split('+')[0];
//          )
//           );
        break;
      case 'post_title': return profileData[position]['text'].toString(); break;
      case 'post_media': return
        profileData[position]['entities']['media'] != null ? profileData[position]['entities']['media'][0]['media_url'] : null;
      case 'post_description': return null; break;
      case 'post_likes': return profileData[position]['favorite_count'].toString(); break;
      case 'post_shares': return profileData[position]['retweet_count'].toString(); break;
      case 'post_comments': return null; break;
    }
  }
  getFacebookData (position, String key) {
    switch (key) {
      case 'profile_name': return profileName; break;
      case 'profile_photo': return 'https://graph.facebook.com/v3.1/${profileData[position]['id'].toString().substring(0, 16)}/picture'; break;
      case 'created': return
        DateFormat('kk:mm, dd-MM-yyyy').format( DateTime.parse( '${profileData[position]['created_time']}' )); break;
      case 'post_title': return profileData[position]['attachments']['data'][0]['title']; break;
      case 'post_description': return profileData[position]['attachments']['data'][0]['description']; break;
      case 'post_media': return
        profileData[position]['attachments']['data'][0]['media'] != null ?
        profileData[position]['attachments']['data'][0]['media']['image']['src'] : null;
      break;
      case 'post_likes': return
          profileData[position]['likes'] != null ?
          profileData[position]['likes']['data'].length.toString(): '0';
      break;
      case 'post_shares': return
        profileData[position]['shares'] != null ?
        profileData[position]['shares']['count'].toString() : '0';
      break;
      case 'post_comments': return
        profileData[position]['comments'] != null ?
        profileData[position]['comments']['data'].length.toString() : '0';
      break;
    }
  }

  getInstagramData (position, String key) {
    switch (key) {
      case 'profile_name': return profileData[position]['user']['username']; break;
      case 'profile_photo': return profileData[position]['user']['profile_picture']; break;
      case 'created': return
        DateFormat('kk:mm, dd-MM-yyyy').format(
          DateTime.parse (
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(profileData[position]['created_time']) * 1000
          ).toString().substring(0, 19) ));
      break;
      case 'post_title': return
        profileData[position]['caption'] != null ?
        profileData[position]['caption']['text'].toString() : null; break;
      case 'post_media': return profileData[position]['images']['standard_resolution']['url']; break;
      case 'post_description': return null; break;
      case 'post_likes': return profileData[position]['likes']['count'].toString(); break;
      case 'post_shares': return null; break;
      case 'post_comments': return profileData[position]['comments']['count'].toString(); break;
    }
  }



  returnData(position, String key) {
     switch(socialNetwork) {
       case 'facebook': return getFacebookData(position, key); break;
       case 'twitter': return getTwitterData(position, key); break;
       case 'instagram': return getInstagramData(position, key);
     }
  }


asyncPhoto (position) async {
   var a = await returnData(position, 'post_media');
   return a;
}

  @override
  _ShowListOfPostsState createState() => _ShowListOfPostsState();
}

class _ShowListOfPostsState extends State<ShowListOfPosts> {
  @override
  Widget build(BuildContext context) {
    return widget.errorWhileLoading ?
            _showErrorWhileLoading() :
            Padding (padding: EdgeInsets.only(right: 1), child:
                Scrollbar(child:
                  AnimatedList(
                    initialItemCount: widget.profileData.length,
                    itemBuilder: (_, int position, animation) {
                      return SizeTransition(
                      sizeFactor: animation,
                      child: GestureDetector(
                          onLongPress: () => _showPostDialog(position),
                          child: Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: EdgeInsets.all(15.0),
                              child: new Container(
                                  child: new Column(
                                    children: <Widget>[
                                      // CARD HEADER /////////////////////////////////////////////////////////////////
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: new Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Row(
                                                  children: <Widget>[
                                                    new Image.network(
                                                      widget.returnData(position, 'profile_photo'),
                                                      height: 25,
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(left: 9.0),
                                                        child: new Text(
                                                          widget.returnData(position, 'profile_name')
                                                        )),
                                                  ]),
                                              new Row(
                                                children: <Widget>[
                                                  new Text(
                                                   widget.returnData(position, 'created'),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )),

                                      // CARD CONTENT ////////////////////////////////////////////////////////////////
                                  widget.returnData(position, 'post_title') != null ||
                                  widget.returnData(position, 'post_description') != null ?
                                      new ListTile(
                                          title: widget.returnData(position, 'post_title') != null ? Padding(
                                            padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                                            child: new Text(
                                              '${widget.returnData(position, 'post_title')}'
                                          ) ) : null,
                                          subtitle: widget.returnData(position, 'post_description') != null ? Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0.0, 8.0, 0.0, 8.0),
                                              child: new Text(
                                                //"${widget.profileData[position]['text'].toString()}"),
                                                  '${widget.returnData(position, 'post_description')}'
                                              ) ) : null,
                                      )
                                  : Container(),
                                  widget.returnData(position, 'post_media') != null ?
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: new CachedNetworkImage(
                                            imageUrl: widget.returnData(position, 'post_media'),
                                            placeholder: (context, url) => new CircularProgressIndicator(),
                                           )
                                      ) : new Container(),

                                      //CARD FOOTER ////////////////////////////////////////////////////////////
                                        new Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            //LIKES
                                            new Row( children: <Widget>[
                                              IconButton(
                                                  icon: new Icon(Icons.favorite_border),
                                                  onPressed: null
                                              ),
                                              Text(
                                                  widget.returnData(position, 'post_likes') != null
                                                    //  && widget.returnData(position, 'post_likes') != '0'
                                                      ? widget.returnData(position, 'post_likes')  : '')
                                            ]),
                                            //COMMENTS
                                            widget.returnData(position, 'post_comments') != null ?
                                            new Row( children: <Widget>[
                                                IconButton(
                                                    icon: new Icon(Icons.comment),
                                                    onPressed: null
                                                ),
                                                Text(
                                                    widget.returnData(position, 'post_comments') != null
                                                        ? widget.returnData(position, 'post_comments') : ''
                                                )
                                              ],
                                            ) : Container(),
                                            //SHARES
                                            widget.returnData(position, 'post_shares') != null ?
                                            new Row( children: <Widget>[
                                                  IconButton(
                                                      icon: new Icon(Icons.repeat),
                                                      onPressed: null),
                                                  Text(
                                                      widget.returnData(position, 'post_shares') != null
                                                          ? widget.returnData(position, 'post_shares') : ''
                                                  )
                                            ]) : Container(),
                                          ],
                                        ),

                                    ],
                                  )))  //CARD ENDS HERE
                      )
                      );
                }
                )
                )
            );
  }

  _showErrorWhileLoading () {
    return ListView(
      padding: EdgeInsets.only(top: 250),
      children: <Widget>[
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(child: Icon(Icons.cancel), padding: EdgeInsets.all(8.0),),
              Text('Error while loading.'),
             // error != null ? Text(error.toString()) : Container(),
              Text('Pull down to try again.')
            ])
      ],);
  }

  _showPostDialog (position) {
    var _titleController = new TextEditingController();
    _titleController.text = widget.socialNetwork == "facebook" ? widget.returnData(position, 'post_title') : null;
    var _descriptionController = new TextEditingController();
    _descriptionController.text = widget.socialNetwork == "facebook" ? widget.returnData(position, 'post_description') : widget.returnData(position, 'post_title');

    showDialog(
        context: context,
        builder: ((_) => AlertDialog(
//          shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: new Text('Edit'),
          content: new Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _titleController.text != '' ?
                  Container(
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: new Scrollbar(
                        child: new SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: new TextField(
                            maxLines: null,
                            controller: _titleController,
                            decoration: new InputDecoration(labelText: 'Title'),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(),

                  Container(
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: new Scrollbar(
                        child: new SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: new TextField(
                            maxLines: null,
                            controller: _descriptionController,
                            decoration: new InputDecoration(labelText: widget.socialNetwork == 'facebook' || widget.socialNetwork == 'instagram' ? 'Desciption' :  'Tweet'),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
          actions: <Widget>[
            new FlatButton(
                onPressed: ()  => Navigator.of(context).pop(),
                child: new Text('Ok')),
            new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('Cancel')),
            new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('Delete', style: TextStyle(color: Colors.red),))
          ],
        )));
  }

}
