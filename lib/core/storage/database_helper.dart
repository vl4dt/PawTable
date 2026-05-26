import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite helper for structured tracking data (feeding, vaccines, medications, etc.)
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

  // Pet CRUD
  Future<int> upsertPet(Map<String, dynamic> pet) async {
    final db = await database;
    final existing = await db.query('pets', where: 'id = ?', whereArgs: [pet['id']]);
    if (existing.isNotEmpty) {
      await db.update('pets', pet, where: 'id = ?', whereArgs: [pet['id']]);
      return 1;
    } else {
      await db.insert('pets', pet); // ignoreDuplicates
      return 1;
    }
  }

  Future<int> deletePet(String id) async {
    final db = await database;
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }
}
