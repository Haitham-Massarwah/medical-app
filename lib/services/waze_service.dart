import 'package:url_launcher/url_launcher.dart';

class WazeService {
  /// Opens Waze with coordinates
  static Future<bool> openWazeWithCoordinates(double latitude, double longitude) async {
    final url = 'https://waze.com/ul?ll=$latitude,$longitude';
    return await _launchWaze(url);
  }

  /// Opens Waze with address
  static Future<bool> openWazeWithAddress(String address) async {
    final url = 'https://waze.com/ul?q=$address';
    return await _launchWaze(url);
  }

  static Future<bool> _launchWaze(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error launching Waze: $e');
      return false;
    }
  }
}
