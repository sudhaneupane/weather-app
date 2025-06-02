import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../model/weatherModel.dart';

class fetchWeatherProvider extends ChangeNotifier {
  bool _isLoading = false;
  weatherModel? _weatherData;

  bool get isLoading => _isLoading;
  weatherModel? get weatherData => _weatherData;


  double latitude = 0.0;
  double longitude = 0.0;
  String currentAddress = '';

  bool get hasError => false;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
    //  return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
      //  return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    Placemark place = placemarks[0];

    currentAddress =
        '${place.subLocality}, ${place.locality}, ${place.country}';
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    await getCurrentLocation();
    final apiKey = "daf6fa46d6b5f22440d691f09a6c3204";
    final weatheruri =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";

    // log(longitude.toString() + "Lat: " + latitude.toString());
    try {
      final response = await http.get(
        Uri.parse(weatheruri),
        headers: ({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );
      _isLoading=false;
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _weatherData = weatherModel.fromJson(jsonData);
        notifyListeners();
      } else {

        Fluttertoast.showToast(msg: "Unable to fetch data");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to fetch data");
    }
    _isLoading=false;
    notifyListeners();
  }
}
