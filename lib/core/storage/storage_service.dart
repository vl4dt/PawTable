import 'package:hive_flutter/hive_flutter.dart';

/// Hive storage service — offline-first local cache for settings and preferences
///
/// Uses typed `Box<String>` for settings (JSON strings) and `Box<dynamic>`
/// for entity boxes (Hive ValueAdapter serialized objects).
class StorageService {
  static const String _settingsBox = 'settings';
  static const String _petsBox = 'pets';
  static const String _healthBox = 'health';
  static const String _feedingBox = 'feeding';
  static const String _vaccinationsBox = 'vaccinations';
  static const String _medicationsBox = 'medications';
  static const String _weightBox = 'weight';
  static const String _familyBox = 'family';

  late Box _settingsBoxInstance;
  late Box _petsBoxInstance;
  late Box _healthBoxInstance;
  late Box _feedingBoxInstance;
  late Box _vaccinationsBoxInstance;
  late Box _medicationsBoxInstance;
  late Box _weightBoxInstance;
  late Box _familyBoxInstance;

  /// Initialize all Hive boxes.
  ///
  /// Must be called once during app startup. Registers Hive adapters
  /// and opens all boxes for typed access.
  Future<void> init() async {
    await Hive.initFlutter();

    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    _petsBoxInstance = await Hive.openBox(_petsBox);
    _healthBoxInstance = await Hive.openBox(_healthBox);
    _feedingBoxInstance = await Hive.openBox(_feedingBox);
    _vaccinationsBoxInstance = await Hive.openBox(_vaccinationsBox);
    _medicationsBoxInstance = await Hive.openBox(_medicationsBox);
    _weightBoxInstance = await Hive.openBox(_weightBox);
    _familyBoxInstance = await Hive.openBox(_familyBox);
  }

  // =========================================================================
  // Box accessors
  // =========================================================================

  Box get settingsBox => _settingsBoxInstance;
  Box get petsBox => _petsBoxInstance;
  Box get healthBox => _healthBoxInstance;
  Box get feedingBox => _feedingBoxInstance;
  Box get vaccinationsBox => _vaccinationsBoxInstance;
  Box get medicationsBox => _medicationsBoxInstance;
  Box get weightBox => _weightBoxInstance;
  Box get familyBox => _familyBoxInstance;

  // =========================================================================
  // SETTINGS (typed: key → JSON string)
  // =========================================================================

  String? getSettingString(String key, {String? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  int? getSettingInt(String key, {int? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  double? getSettingDouble(String key, {double? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  bool? getSettingBool(String key, {bool? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  Future<void> setSettingString(String key, String value) async {
    await _settingsBoxInstance.put(key, value);
  }

  Future<void> setSettingInt(String key, int value) async {
    await _settingsBoxInstance.put(key, value);
  }

  Future<void> setSettingDouble(String key, double value) async {
    await _settingsBoxInstance.put(key, value);
  }

  Future<void> setSettingBool(String key, bool value) async {
    await _settingsBoxInstance.put(key, value);
  }

  Future<void> removeSetting(String key) async {
    await _settingsBoxInstance.delete(key);
  }

  // =========================================================================
  // PETS (typed via ValueAdapter)
  // =========================================================================

  dynamic getPet(String id) {
    return _petsBoxInstance.get(id);
  }

  Future<void> savePet(String id, dynamic data) async {
    await _petsBoxInstance.put(id, data);
  }

  Future<void> deletePet(String id) async {
    await _petsBoxInstance.delete(id);
  }

  // =========================================================================
  // HEALTH LOGS (typed via ValueAdapter)
  // =========================================================================

  dynamic getHealthLog(String petId) {
    return _healthBoxInstance.get(petId);
  }

  Future<void> saveHealthLog(String petId, dynamic log) async {
    await _healthBoxInstance.put(petId, log);
  }

  // =========================================================================
  // CLOSURE
  // =========================================================================

  Future<void> close() async {
    await Hive.close();
  }
}
