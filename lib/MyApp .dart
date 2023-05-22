import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sensors/sensors.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<double> _accelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  bool _isAccidentDetected = false;
  String accident = 'an accident accure';
  String noaccident = 'no accident accure , you are safe';
  LocationData? curentLocation;

  Location location = Location();
  late bool serveceEnabled;
  late PermissionStatus _permissionGenarated;
  LocationData? locationData;

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        if (_accelerometerValues[0] > 20 ||
            _accelerometerValues[1] > 20 ||
            _accelerometerValues[2] > 20) {
          _isAccidentDetected = true;
          _getLocation().then((value) {
            curentLocation = value;
          });
        }
      });
    }));
  }

  Future<LocationData?> _getLocation() async {
    serveceEnabled = await location.serviceEnabled();
    if (!serveceEnabled) serveceEnabled = await location.requestService();

    _permissionGenarated = await location.hasPermission();
    if (_permissionGenarated == PermissionStatus.denied) {
      _permissionGenarated = await location.requestPermission();
    }
    locationData = await location.getLocation();

    return locationData;
  }

  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
            ),
          ),
          title: const Text('Accident Detection'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Text('Accelerometer: $_accelerometerValues'),

              Container(
                alignment: Alignment.center,
                width: 320,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: _isAccidentDetected
                        ? Colors.amber[800]
                        : Colors.blue[400]),
                child: Text(
                  ' ${_isAccidentDetected ? accident : noaccident} ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              if (_isAccidentDetected)
                Container(
                    alignment: Alignment.center,
                    width: 320,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: _isAccidentDetected
                            ? Colors.amber[800]
                            : Colors.blue[400]),
                    child: Text(
                      'Accident Location is :$curentLocation',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
              SizedBox(
                height: 40,
              ),
              if (_isAccidentDetected)
                Container(
                    alignment: Alignment.center,
                    width: 320,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: _isAccidentDetected
                            ? Colors.amber[800]
                            : Colors.blue[400]),
                    child: Text(
                      'time and date accident occur:$time',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
