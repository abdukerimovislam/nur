import 'dart:async'; // Для TimeoutException
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      try {
        await Geolocator.openAppSettings();
      } catch (e) {
        debugPrint("Could not open App Settings: $e");
      }
      return Future.error(
          'Location permissions are permanently denied. Please enable in Settings.');
    }

    // ИСПРАВЛЕНИЕ: Жесткая защита от бесконечного поиска спутников на Android.
    // Если за 7 секунд точная локация не найдена, берем последнюю известную или выдаем ошибку.
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 7));
    } on TimeoutException {
      debugPrint("GPS search timed out. Falling back to last known position.");
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
      return Future.error('Location request timed out. Please enter city manually.');
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}