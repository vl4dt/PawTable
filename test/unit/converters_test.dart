import 'package:flutter_test/flutter_test.dart';
import 'package:pawtable/core/utils/converters.dart';

void main() {
  group('Converters.weight conversions', () {
    test('converts kg to lbs', () {
      expect(Converters.kgToLbs(1), closeTo(2.20462, 0.001));
      expect(Converters.kgToLbs(10), closeTo(22.0462, 0.001));
    });

    test('converts lbs to kg', () {
      expect(Converters.lbsToKg(1), closeTo(0.4536, 0.001));
      expect(Converters.lbsToKg(10), closeTo(4.536, 0.001));
    });

    test('converts kg to oz', () {
      expect(Converters.kgToOz(1), closeTo(35.274, 0.001));
      expect(Converters.kgToOz(0.5), closeTo(17.637, 0.001));
    });

    test('converts oz to kg', () {
      expect(Converters.ozToKg(35.274), closeTo(1.0, 0.001));
    });

    test('converts g to lbs', () {
      expect(Converters.gToLbs(1000), closeTo(2.20462, 0.001));
    });

    test('converts lbs to g', () {
      expect(Converters.lbsToG(1), closeTo(453.59, 0.01));
    });

    test('converts g to oz', () {
      expect(Converters.gToOz(28.3495), closeTo(1.0, 0.001));
    });

    test('converts oz to g', () {
      expect(Converters.ozToG(1), closeTo(28.3495, 0.001));
    });

    test('convertWeight handles kg to lbs', () {
      expect(Converters.convertWeight(10, 'kg', 'lbs'), closeTo(22.0462, 0.001));
    });

    test('convertWeight handles lbs to kg', () {
      expect(Converters.convertWeight(22.0462, 'lbs', 'kg'), closeTo(10.0, 0.01));
    });

    test('convertWeight returns value for unknown conversion', () {
      expect(Converters.convertWeight(10, 'kg', 'tons'), 10);
    });
  });

  group('Converters.volume conversions', () {
    test('converts ml to fl oz', () {
      expect(Converters.mlToFlOz(29.5735), closeTo(1.0, 0.001));
    });

    test('converts fl oz to ml', () {
      expect(Converters.flOzToMl(1), closeTo(29.5735, 0.001));
    });

    test('converts ml to cups', () {
      expect(Converters.mlToCups(236.588), closeTo(1.0, 0.001));
    });

    test('converts cups to ml', () {
      expect(Converters.cupsToMl(1), closeTo(236.588, 0.001));
    });

    test('converts liters to ml', () {
      expect(Converters.litersToMl(1), 1000);
      expect(Converters.litersToMl(0.5), 500);
    });

    test('converts ml to liters', () {
      expect(Converters.mlToLiters(1000), 1);
      expect(Converters.mlToLiters(500), 0.5);
    });
  });

  group('Converters.temperature conversions', () {
    test('converts Celsius to Fahrenheit', () {
      expect(Converters.celsiusToFahrenheit(0), 32);
      expect(Converters.celsiusToFahrenheit(100), 212);
      expect(Converters.celsiusToFahrenheit(37), closeTo(98.6, 0.1));
    });

    test('converts Fahrenheit to Celsius', () {
      expect(Converters.fahrenheitToCelsius(32), 0);
      expect(Converters.fahrenheitToCelsius(212), 100);
      expect(Converters.fahrenheitToCelsius(98.6), closeTo(37, 0.1));
    });
  });

  group('Converters.length conversions', () {
    test('converts cm to inches', () {
      expect(Converters.cmToInches(1), closeTo(0.3937, 0.001));
      expect(Converters.cmToInches(10), closeTo(3.937, 0.001));
      expect(Converters.cmToInches(2.54), closeTo(1.0, 0.001));
    });

    test('converts inches to cm', () {
      expect(Converters.inchesToCm(1), closeTo(2.54, 0.001));
      expect(Converters.inchesToCm(10), closeTo(25.4, 0.001));
    });

    test('converts meters to feet', () {
      expect(Converters.metersToFeet(1), closeTo(3.28084, 0.001));
    });

    test('converts feet to meters', () {
      expect(Converters.feetToMeters(1), closeTo(0.3048, 0.001));
    });
  });

  group('Converters.medication conversions', () {
    test('converts mg to g', () {
      expect(Converters.mgToG(1000), 1);
      expect(Converters.mgToG(500), 0.5);
    });

    test('converts g to mg', () {
      expect(Converters.gToMg(1), 1000);
      expect(Converters.gToMg(0.5), 500);
    });

    test('converts mcg to mg', () {
      expect(Converters.mcgToMg(1000), 1);
    });

    test('converts mg to mcg', () {
      expect(Converters.mgToMcg(1), 1000);
    });
  });

  group('Converters.unit helpers', () {
    test('getBaseUnit returns kg for common weight units', () {
      expect(Converters.getBaseUnit('kg'), 'kg');
      expect(Converters.getBaseUnit('lbs'), 'kg');
      expect(Converters.getBaseUnit('g'), 'kg');
      expect(Converters.getBaseUnit('oz'), 'kg');
    });

    test('getUnitName returns display names', () {
      expect(Converters.getUnitName('kg'), 'Kilograms');
      expect(Converters.getUnitName('lbs'), 'Pounds');
      expect(Converters.getUnitName('g'), 'Grams');
      expect(Converters.getUnitName('ml'), 'Milliliters');
      expect(Converters.getUnitName('c'), 'Celsius');
      expect(Converters.getUnitName('f'), 'Fahrenheit');
    });

    test('getWeightUnits returns weight unit list', () {
      final units = Converters.getWeightUnits();
      expect(units, contains('kg'));
      expect(units, contains('lbs'));
      expect(units, contains('g'));
      expect(units, contains('oz'));
    });

    test('getVolumeUnits returns volume unit list', () {
      final units = Converters.getVolumeUnits();
      expect(units, contains('ml'));
      expect(units, contains('l'));
      expect(units, contains('cups'));
      expect(units, contains('fl_oz'));
    });

    test('getMedicationUnits returns medication unit list', () {
      final units = Converters.getMedicationUnits();
      expect(units, contains('mg'));
      expect(units, contains('g'));
      expect(units, contains('mcg'));
      expect(units, contains('ml'));
    });
  });

  group('DoubleConversions extension', () {
    test('inLbs converts kg to lbs', () {
      expect((1.0).inLbs, closeTo(2.20462, 0.001));
    });

    test('inKg converts lbs to kg', () {
      expect((2.20462).inKg, closeTo(1.0, 0.001));
    });

    test('inOz converts kg to oz', () {
      expect((1.0).inOz, closeTo(35.274, 0.001));
    });

    test('inFlOz converts ml to fl oz', () {
      expect((29.5735).inFlOz, closeTo(1.0, 0.001));
    });

    test('inCups converts ml to cups', () {
      expect((236.588).inCups, closeTo(1.0, 0.001));
    });

    test('inFahrenheit converts C to F', () {
      expect((0.0).inFahrenheit, 32);
      expect((100.0).inFahrenheit, 212);
    });

    test('inCelsius converts F to C', () {
      expect((32.0).inCelsius, 0);
      expect((212.0).inCelsius, 100);
    });

    test('inG converts mg to g', () {
      expect((1000.0).inG, 1);
    });

    test('inMg converts g to mg', () {
      expect((1.0).inMg, 1000);
    });
  });

  group('Inverse conversions', () {
    test('kgToLbs then lbsToKg returns original', () {
      final lbs = Converters.kgToLbs(10);
      final kg = Converters.lbsToKg(lbs);
      expect(kg, closeTo(10.0, 0.001));
    });

    test('Celsius to Fahrenheit then back', () {
      final f = Converters.celsiusToFahrenheit(37);
      final c = Converters.fahrenheitToCelsius(f);
      expect(c, closeTo(37, 0.1));
    });
  });
}
