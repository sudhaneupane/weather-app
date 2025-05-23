import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../model/weatherModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<weatherModel?> _weatherFuture;
  double latitude = 0.0;
  double longitude = 0.0;
  String currentAddress = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _weatherFuture = fetchWeather();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
        return;
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

    setState(() {
      currentAddress =
          '${place.subLocality}, ${place.locality}, ${place.country}';
    });
  }

  Future<weatherModel?> fetchWeather() async {
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
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return weatherModel.fromJson(jsonData);
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch data");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to fetch data");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text("Weather"), centerTitle: true),
      body: FutureBuilder<weatherModel?>(
        future: _weatherFuture,
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshots.hasError) {
            return Center(child: Text("Unable to fetch data"));
          }

          final weatherInfo = snapshots.data;
          final iconWeathr = weatherInfo!.weather![0].icon;

          final iconUrl =
              "https://openweathermap.org/img/wn/${weatherInfo.weather![0].icon}@2x.png";

          final temp = weatherInfo.main!.temp!.toInt();

          String getWeatherImg(int temp) {
            switch (temp) {
              case >= 40:
                return "assets/extreme_hot.jpg";
              case >= 31:
                return "assets/very_hot.avif";
              case >= 26:
                return "assets/hot.avif";
              case >= 21:
                return "assets/sunny.jpg";
              case >= 16:
                return "assets/pleasant.jpg";
              case >= 11:
                return "assets/cloudy.jpg";
              case >= 6:
                return "assets/cool.jpg";
              case >= 1:
                return "assets/cold.jpg";
              case 0:
                return "assets/freezing.jpg";
              case <= -1:
                return "assets/extreme_cold.jpg";
              default:
                return "assets/unknown.jpg";
            }
          }

          return Stack(
            children: [
              Image.asset(
                getWeatherImg(temp),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),

              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentAddress.split(",").first.trim(),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                size: 15,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 70),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(iconUrl, width: 98),
                          Text(
                            "${weatherInfo.main!.temp!.toInt()}°C",
                            style: TextStyle(
                              fontSize: 75,
                              fontFamily: "Poppins",
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Feels like ${weatherInfo.main!.feelsLike!.toInt()}°C ",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppins",
                          color: Colors.white,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "${weatherInfo.main!.humidity}%",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Poppins",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.air, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text(
                              "${weatherInfo.wind!.speed} mph",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Poppins",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.speed, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text(
                              "${weatherInfo.main!.pressure} hPa",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Poppins",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
