import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite helper for structured tracking data (feeding, vaccines, medications, etc.)
///
/// All operations are async and use lazy singleton pattern for database access.
/// Schema includes: pets, feeding_logs, vaccinations, medications, weight_logs,
/// behavior_logs, family_members with foreign keys and indexes.
class DatabaseHelper {
  static Database? _database;
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pawtable.db');

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Pets table
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        breed TEXT,
        birthdate TEXT,
        weight REAL,
        photoUrl TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Feeding logs
    await db.execute('''
      CREATE TABLE feeding_logs (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        mealType TEXT NOT NULL,
        amount REAL,
        unit TEXT,
        time TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Vaccination records
    await db.execute('''
      CREATE TABLE vaccinations (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        vaccineName TEXT NOT NULL,
        dateIssued TEXT NOT NULL,
        nextDueDate TEXT,
        batchNumber TEXT,
        notes TEXT,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Medication records
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        notes TEXT,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Weight records
    await db.execute('''
      CREATE TABLE weight_logs (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Behavior logs
    await db.execute('''
      CREATE TABLE behavior_logs (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        mood TEXT,
        activityLevel TEXT,
        notes TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Family members
    await db.execute('''
      CREATE TABLE family_members (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        userId TEXT NOT NULL,
        role TEXT NOT NULL,
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_feeding_pet ON feeding_logs(petId)');
    await db.execute('CREATE INDEX idx_vaccinations_pet ON vaccinations(petId)');
    await db.execute('CREATE INDEX idx_medications_pet ON medications(petId)');
    await db.execute('CREATE INDEX idx_weight_pet ON weight_logs(petId)');
    await db.execute('CREATE INDEX idx_behavior_pet ON behavior_logs(petId)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // =========================================================================
  // PETS
  // =========================================================================

  Future<int> upsertPet(Map<String, dynamic> pet) async {
    final db = await database;
    final existing = await db.query('pets', where: 'id = ?', whereArgs: [pet['id']]);
    if (existing.isNotEmpty) {
      await db.update('pets', pet, where: 'id = ?', whereArgs: [pet['id']]);
      return 1;
    } else {
      return await db.insert('pets', pet);
    }
  }

  Future<List<Map<String, dynamic>>> getAllPets() async {
    final db = await database;
    return await db.query('pets', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getPet(String id) async {
    final db = await database;
    final results = await db.query('pets', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deletePet(String id) async {
    final db = await database;
    // Delete related records first
    await db.delete('feeding_logs', where: 'petId = ?', whereArgs: [id]);
    await db.delete('vaccinations', where: 'petId = ?', whereArgs: [id]);
    await db.delete('medications', where: 'petId = ?', whereArgs: [id]);
    await db.delete('weight_logs', where: 'petId = ?', whereArgs: [id]);
    await db.delete('behavior_logs', where: 'petId = ?', whereArgs: [id]);
    await db.delete('family_members', where: 'petId = ?', whereArgs: [id]);
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // FEEDING LOGS
  // =========================================================================

  Future<int> insertFeedingLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('feeding_logs', log);
  }

  Future<List<Map<String, dynamic>>> getFeedingLogsByPet(String petId,
      {DateTime? from, DateTime? to}) async {
    final db = await database;
    String query = 'petId = ?';
    List<dynamic> args = [petId];
    if (from != null) {
      query += ' AND time >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      query += ' AND time <= ?';
      args.add(to.toIso8601String());
    }
    return await db.query('feeding_logs', where: query, whereArgs: args,
        orderBy: 'time DESC');
  }

  Future<int> updateFeedingLog(String id, Map<String, dynamic> log) async {
    final db = await database;
    return await db.update('feeding_logs', log, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFeedingLog(String id) async {
    final db = await database;
    return await db.delete('feeding_logs', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // VACCINATIONS
  // =========================================================================

  Future<int> insertVaccination(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('vaccinations', record);
  }

  Future<List<Map<String, dynamic>>> getVaccinationsByPet(String petId) async {
    final db = await database;
    return await db.query('vaccinations', where: 'petId = ?', whereArgs: [petId],
        orderBy: 'dateIssued DESC');
  }

  Future<int> updateVaccination(String id, Map<String, dynamic> record) async {
    final db = await database;
    return await db.update('vaccinations', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteVaccination(String id) async {
    final db = await database;
    return await db.delete('vaccinations', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // MEDICATIONS
  // =========================================================================

  Future<int> insertMedication(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('medications', record);
  }

  Future<List<Map<String, dynamic>>> getMedicationsByPet(String petId) async {
    final db = await database;
    return await db.query('medications', where: 'petId = ?', whereArgs: [petId],
        orderBy: 'startDate DESC');
  }

  Future<int> updateMedication(String id, Map<String, dynamic> record) async {
    final db = await database;
    return await db.update('medications', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMedication(String id) async {
    final db = await database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // WEIGHT LOGS
  // =========================================================================

  Future<int> insertWeightLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('weight_logs', log);
  }

  Future<List<Map<String, dynamic>>> getWeightLogsByPet(String petId) async {
    final db = await database;
    return await db.query('weight_logs', where: 'petId = ?', whereArgs: [petId],
        orderBy: 'date DESC');
  }

  Future<int> updateWeightLog(String id, Map<String, dynamic> log) async {
    final db = await database;
    return await db.update('weight_logs', log, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWeightLog(String id) async {
    final db = await database;
    return await db.delete('weight_logs', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // BEHAVIOR LOGS
  // =========================================================================

  Future<int> insertBehaviorLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('behavior_logs', log);
  }

  Future<List<Map<String, dynamic>>> getBehaviorLogsByPet(String petId) async {
    final db = await database;
    return await db.query('behavior_logs', where: 'petId = ?', whereArgs: [petId],
        orderBy: 'date DESC');
  }

  Future<int> deleteBehaviorLog(String id) async {
    final db = await database;
    return await db.delete('behavior_logs', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // FAMILY MEMBERS
  // =========================================================================

  Future<int> insertFamilyMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('family_members', member);
  }

  Future<List<Map<String, dynamic>>> getFamilyMembersByPet(String petId) async {
    final db = await database;
    return await db.query('family_members', where: 'petId = ?', whereArgs: [petId]);
  }

  Future<int> deleteFamilyMember(String id) async {
    final db = await database;
    return await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
  }
}
