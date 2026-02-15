import 'package:adhan/adhan.dart';

class PrayerService {
  PrayerTimes calculatePrayerTimes(
      Coordinates coordinates, DateTime date, CalculationMethod method) {
    final params = method.getParameters();
    params.madhab = Madhab.hanafi;
    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  Prayer getNextPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.nextPrayer();
  }
}