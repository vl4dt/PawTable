/// PawTable unit converters
///
/// Conversion helpers for weight, length, temperature, and volume units
/// commonly used in pet care (kg↔lb, g↔oz, ml↔cup, etc.)
class Converters {
  Converters._();

  // =========================================================================
  // WEIGHT CONVERSIONS
  // =========================================================================

  /// Kilograms to pounds
  static double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  /// Pounds to kilograms
  static double lbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  /// Kilograms to ounces
  static double kgToOz(double kg) {
    return kg * 35.274;
  }

  /// Ounces to kilograms
  static double ozToKg(double oz) {
    return oz / 35.274;
  }

  /// Grams to pounds
  static double gToLbs(double g) {
    return g * 0.00220462;
  }

  /// Pounds to grams
  static double lbsToG(double lbs) {
    return lbs / 0.00220462;
  }

  /// Grams to ounces
  static double gToOz(double g) {
    return g / 28.3495;
  }

  /// Ounces to grams
  static double ozToG(double oz) {
    return oz * 28.3495;
  }

  /// Convert weight with target unit
  static double convertWeight(double value, String fromUnit, String toUnit) {
    switch ('$fromUnit-$toUnit') {
      case 'kg-lbs':
        return kgToLbs(value);
      case 'lbs-kg':
        return lbsToKg(value);
      case 'kg-oz':
        return kgToOz(value);
      case 'oz-kg':
        return ozToKg(value);
      case 'g-oz':
        return gToOz(value);
      case 'oz-g':
        return ozToG(value);
      case 'g-lbs':
        return gToLbs(value);
      case 'lbs-g':
        return lbsToG(value);
      default:
        return value;
    }
  }

  // =========================================================================
  // VOLUME CONVERSIONS
  // =========================================================================

  /// Milliliters to fluid ounces
  static double mlToFlOz(double ml) {
    return ml / 29.5735;
  }

  /// Fluid ounces to milliliters
  static double flOzToMl(double flOz) {
    return flOz * 29.5735;
  }

  /// Milliliters to cups (US)
  static double mlToCups(double ml) {
    return ml / 236.588;
  }

  /// Cups to milliliters
  static double cupsToMl(double cups) {
    return cups * 236.588;
  }

  /// Liters to milliliters
  static double litersToMl(double liters) {
    return liters * 1000;
  }

  /// Milliliters to liters
  static double mlToLiters(double ml) {
    return ml / 1000;
  }

  // =========================================================================
  // TEMPERATURE CONVERSIONS
  // =========================================================================

  /// Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  // =========================================================================
  // LENGTH CONVERSIONS
  // =========================================================================

  /// Centimeters to inches
  static double cmToInches(double cm) {
    return cm / 2.54;
  }

  /// Inches to centimeters
  static double inchesToCm(double inches) {
    return inches * 2.54;
  }

  /// Meters to feet
  static double metersToFeet(double meters) {
    return meters * 3.28084;
  }

  /// Feet to meters
  static double feetToMeters(double feet) {
    return feet / 3.28084;
  }

  // =========================================================================
  // MEDICATION CONVERSIONS
  // =========================================================================

  /// Milligrams to grams
  static double mgToG(double mg) {
    return mg / 1000;
  }

  /// Grams to milligrams
  static double gToMg(double g) {
    return g * 1000;
  }

  /// Micrograms to milligrams
  static double mcgToMg(double mcg) {
    return mcg / 1000;
  }

  /// Milligrams to micrograms
  static double mgToMcg(double mg) {
    return mg * 1000;
  }

  // =========================================================================
  // UNIT HELPERS
  // =========================================================================

  /// Get the base unit for a weight unit
  static String getBaseUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'pounds':
      case 'lbs':
      case 'g':
      case 'grams':
      case 'oz':
      case 'ounces':
        return 'kg';
      default:
        return unit.toLowerCase();
    }
  }

  /// Get display name for a unit
  static String getUnitName(String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return 'Kilograms';
      case 'lbs':
      case 'pounds':
        return 'Pounds';
      case 'g':
        return 'Grams';
      case 'oz':
      case 'ounces':
        return 'Ounces';
      case 'ml':
        return 'Milliliters';
      case 'fl_oz':
      case 'floz':
        return 'Fluid ounces';
      case 'cups':
        return 'Cups';
      case 'l':
      case 'liters':
        return 'Liters';
      case 'mg':
        return 'Milligrams';
      case 'mcg':
        return 'Micrograms';
      case 'cm':
        return 'Centimeters';
      case 'in':
      case 'inches':
        return 'Inches';
      case 'm':
      case 'meters':
        return 'Meters';
      case 'ft':
      case 'feet':
        return 'Feet';
      case 'c':
      case 'celsius':
        return 'Celsius';
      case 'f':
      case 'fahrenheit':
        return 'Fahrenheit';
      default:
        return unit;
    }
  }

  /// Get available units for a measurement type
  static List<String> getWeightUnits() {
    return ['kg', 'g', 'lbs', 'oz'];
  }

  static List<String> getVolumeUnits() {
    return ['ml', 'l', 'cups', 'fl_oz'];
  }

  static List<String> getMedicationUnits() {
    return ['mg', 'g', 'mcg', 'ml'];
  }
}

/// Extension on [double] for convenient conversions
extension DoubleConversions on double {
  /// Convert this kg value to lbs
  double get inLbs => Converters.kgToLbs(this);

  /// Convert this lbs value to kg
  double get inKg => Converters.lbsToKg(this);

  /// Convert this kg value to oz
  double get inOz => Converters.kgToOz(this);

  /// Convert this ml value to fl oz
  double get inFlOz => Converters.mlToFlOz(this);

  /// Convert this ml value to cups
  double get inCups => Converters.mlToCups(this);

  /// Convert this Celsius to Fahrenheit
  double get inFahrenheit => Converters.celsiusToFahrenheit(this);

  /// Convert this Fahrenheit to Celsius
  double get inCelsius => Converters.fahrenheitToCelsius(this);

  /// Convert this mg to grams
  double get inG => Converters.mgToG(this);

  /// Convert this g to mg
  double get inMg => Converters.gToMg(this);
}
