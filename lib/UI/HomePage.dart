import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather/API/weatherApiProvider.dart';

import '../model/weatherModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<weatherModel?> _weatherFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _weatherFuture = fetchWeather();
    Future.microtask(
      () =>
          Provider.of<fetchWeatherProvider>(
            context,
            listen: false,
          ).fetchWeather(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text("Weather"), centerTitle: true),
      body: Consumer<fetchWeatherProvider>(
        builder: (context, provider, child) {
          if (provider.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.hasError) {
            return Center(child: Text("Unable to fetch data"));
          }

          final weatherInfo = provider.weatherData;
          // log(weatherInfo.toString());

          final iconWeathr = weatherInfo!.weather![0].icon;

          final iconUrl =
              "https://openweathermap.org/img/wn/${weatherInfo.weather![0].icon}@2x.png";

          final temp = weatherInfo.main!.temp!.toInt();
          int? sunrise = weatherInfo.sys!.sunrise;
          DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(
            sunrise! * 1000,
          );
          String formattedSunRise = DateFormat.jm().format(sunriseTime);

          int sunset = weatherInfo.sys!.sunset!;
          DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(
            sunset * 1000,
          );
          String formattedSunset = DateFormat.jm().format(sunsetTime);

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
                                weatherInfo.name!.split(",").first.trim(),
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
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 70),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue[200],
                          ),
                          height: 131,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.wb_sunny_rounded,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    Text("Sunrise",style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Poppins",
                                      color: Colors.white,
                                    ),),
                                    SizedBox(height: 20),
                                    Text(
                                      formattedSunRise,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: "Poppins",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.wb_twighlight,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    Text("Sunset",style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Poppins",
                                      color: Colors.white,
                                    ),),
                                    SizedBox(height: 20),
                                    Text(
                                      formattedSunset,
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
