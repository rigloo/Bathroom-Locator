import 'package:map_launcher/map_launcher.dart';

class MapLauncherHelper {
  static Future<void> showMap(double latitude, double longitude, String address) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(latitude, longitude),
      title: address,
    );
  }
}
