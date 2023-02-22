import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:bathroom_locator/Constants.dart';

class LocationHelper {
  static String generateLocationPreviewImage(
      double latitude, double longitude) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=${Constants.geo_google_key}";
  }

  static Future<String> generateAddress(
      double latitude, double longitude) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Constants.geo_google_key}");
    final response = await http.get(url);
    print(json.decode(response.body));
    return json.decode(response.body)['results'][0]['formatted_address'];
  }
}
