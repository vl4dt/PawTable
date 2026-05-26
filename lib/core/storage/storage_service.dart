import 'package:hive_flutter/hive_flutter.dart';

/// Hive storage service — offline-first local cache for settings and preferences
class StorageService {
  static const String _settingsBox = 'settings';
  static const String _petsBox = 'pets';
  static const String _healthBox = 'health';

  late Box<dynamic> _settingsBoxInstance;
  late Box<dynamic> _petsBoxInstance;
  late Box<dynamic> _healthBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    _petsBoxInstance = await Hive.openBox(_petsBox);
    _healthBoxInstance = await Hive.openBox(_healthBox);
  }

  // Box accessors
  Box<dynamic> get settingsBox => _settingsBoxInstance;
  Box<dynamic> get petsBox => _petsBoxInstance;
  Box<dynamic> get healthBox => _healthBoxInstance;

  // Settings
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBoxInstance.put(key, value);
  }

  Future<void> removeSetting(String key) async {
    await _settingsBoxInstance.delete(key);
  }

  // Pets (local cache)
  dynamic getPet(String id) {
    return _petsBoxInstance.get(id);
  }

  Future<void> savePet(String id, dynamic data) async {
    await _petsBoxInstance.put(id, data);
  }

  Future<void> deletePet(String id) async {
    await _petsBoxInstance.delete(id);
  }

  // Health logs
  dynamic getHealthLog(String petId) {
    return _healthBoxInstance.get(petId);
  }

  Future<void> saveHealthLog(String petId, dynamic log) async {
    await _healthBoxInstance.put(petId, log);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
