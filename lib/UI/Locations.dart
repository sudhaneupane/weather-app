import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../API/weatherApiProvider.dart';

class LocationAdd extends StatefulWidget {
  const LocationAdd({super.key});

  @override
  State<LocationAdd> createState() => _LocationAddState();
}

class _LocationAddState extends State<LocationAdd> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Cities")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Current City"),
            SizedBox(height: 20),
            Consumer<fetchWeatherProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading == true) {
                  return Center(child: CircularProgressIndicator());
                }
                final weatherInfo = provider.weatherData;
                return Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width/1.6,
                  color: Colors.brown[300],
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        weatherInfo!.name!.split(",").first.trim(),
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Poppins",
                          color: Colors.white,
                      ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
