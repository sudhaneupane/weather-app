import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather/API/weatherApiProvider.dart';
import 'package:weather/UI/Locations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<fetchWeatherProvider>(context, listen: false).fetchWeather();
  }

  Future<void> handleRefresh() async {
   await
      Provider.of<fetchWeatherProvider>(context, listen: false).fetchWeather();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: CustomRefreshIndicator(
        onRefresh: handleRefresh,
        builder: (context, child, controller) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (!controller.isIdle)
                Positioned(
                  top: 30 * controller.value,
                  child: Icon(Icons.refresh, size: 30),
                ),
              child,
            ],
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 65),
            child: Consumer<fetchWeatherProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading == true) {
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

                // log(iconUrl);
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

                String getWeatherImg(iconWeathr) {
                  switch (iconWeathr) {
                    case '01d':
                      return "assets/clear_day.gif";
                    case '01n':
                      return "assets/clear_night.gif";
                    case '02d':
                    case '02n':
                      return "assets/few_clouds.gif";
                    case '03d':
                    case '03n':
                      return "assets/scattered_clouds.gif";
                    case '04d':
                    case '04n':
                      return "assets/broken_clouds.gif";
                    case '09d':
                    case '09n':
                      return "assets/shower_rain.gif";
                    case '10d':
                    case '10n':
                      return "assets/raining.gif";
                    case '11d':
                    case '11n':
                      return "assets/thunderstorm.gif";
                    case '13d':
                    case '13n':
                      return "assets/snow.gif";
                    case '50d':
                    case '50n':
                      return "assets/mist.gif";
                    default:
                      return "assets/no_clue.gif";
                  }
                }

                return Stack(
                  children: [
                    Image.asset(
                      getWeatherImg(iconWeathr),
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
                                      provider.currentAddress
                                          .split(",")
                                          .first
                                          .trim(),
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationAdd(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_location_alt,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
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
                                  Icon(
                                    Icons.air,
                                    color: Colors.white,
                                    size: 30,
                                  ),
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
                                  Icon(
                                    Icons.speed,
                                    color: Colors.white,
                                    size: 30,
                                  ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 70),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFF5D76A5),
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
                                          Text(
                                            "Sunrise",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: "Poppins",
                                              color: Colors.white,
                                            ),
                                          ),
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
                                          Text(
                                            "Sunset",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: "Poppins",
                                              color: Colors.white,
                                            ),
                                          ),
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
          ),
        ),
      ),
    );
  }
}
