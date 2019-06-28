import 'dart:async';

import 'package:flutter/material.dart';

var _opacity = 0.0;

class Poster extends StatefulWidget {
  @override
  _PosterState createState() => _PosterState();
}

class _PosterState extends State<Poster> {
  Timer _timer;

  _PosterState() {
    _timer = new Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 0.6;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 90.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Swipe left to add any social network'),
            Padding(
                padding: EdgeInsets.all(30.0),
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 2000),
                  child: Image.asset(
                    'drawable/swipe.png',
                    height: 75,
                    width: 75,
                    color: Colors.black38,
                  ),
                ))
          ],
        ));
  }
}
