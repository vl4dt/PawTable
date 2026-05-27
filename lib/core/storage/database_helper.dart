import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite helper for structured tracking data (feeding, vaccines, medications, etc.)
///
/// All operations are async and use lazy singleton pattern for database access.
/// Schema includes: pets, feeding_logs, vaccinations, medications, weight_logs,
/// behavior_logs, family_members with foreign keys and indexes.
class DatabaseHelper {
  static Database? _database;
  static const int _databaseVersion = 5;

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

    // Streak logs (gamification)
    await db.execute('''
      CREATE TABLE streak_logs (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        date TEXT NOT NULL,
        activityType TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');

    // Family groups
    await db.execute('''
      CREATE TABLE family_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        ownerId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Family member profiles (cross-pet family membership)
    await db.execute('''
      CREATE TABLE family_members (
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        userId TEXT NOT NULL,
        displayName TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES family_groups(id)
      )
    ''');

    // Pet-family links (shared pets)
    await db.execute('''
      CREATE TABLE pet_family_links (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        groupId TEXT NOT NULL,
        sharedBy TEXT NOT NULL,
        sharedAt TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id),
        FOREIGN KEY (groupId) REFERENCES family_groups(id)
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
    await db.execute('CREATE INDEX idx_streak_pet ON streak_logs(petId)');
    await db.execute('CREATE INDEX idx_streak_date ON streak_logs(petId, date)');
    await db.execute('CREATE INDEX idx_family_group ON family_groups(ownerId)');
    await db.execute('CREATE INDEX idx_family_member ON family_members(groupId)');
    await db.execute('CREATE INDEX idx_pet_family ON pet_family_links(groupId)');
    await db.execute('CREATE INDEX idx_pet_family_pet ON pet_family_links(petId)');

    // Milestone achievements (gamification)
    await db.execute('''
      CREATE TABLE milestone_achievements (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        milestoneId TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        unlocked INTEGER NOT NULL DEFAULT 0,
        unlockedAt TEXT,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_milestone_pet ON milestone_achievements(petId)');
    await db.execute('CREATE INDEX idx_milestone_pet_milestone ON milestone_achievements(petId, milestoneId)');

    // Achievement events — tracks when achievements are unlocked
    await db.execute('''
      CREATE TABLE achievement_events (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        achievementType TEXT NOT NULL,
        achievementId TEXT NOT NULL,
        eventData TEXT,
        unlockedAt TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_achievement_event_pet ON achievement_events(petId)');
    await db.execute(
        'CREATE INDEX idx_achievement_event_pet_type ON achievement_events(petId, achievementType)');
    await db.execute(
        'CREATE INDEX idx_achievement_event_type ON achievement_events(achievementType)');

    // Invite tokens — family group invites
    await db.execute('''
      CREATE TABLE invite_tokens (
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        createdById TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        maxUses INTEGER NOT NULL DEFAULT 1,
        usedCount INTEGER NOT NULL DEFAULT 0,
        expiresAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES family_groups(id)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_invite_token_code ON invite_tokens(code)');
    await db.execute(
        'CREATE INDEX idx_invite_token_group ON invite_tokens(groupId)');

    // Activity feed — unified activity log for family groups
    await db.execute('''
      CREATE TABLE activity_feed (
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        petId TEXT NOT NULL,
        petName TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        metadata TEXT DEFAULT '{}',
        timestamp TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES family_groups(id),
        FOREIGN KEY (userId) REFERENCES family_members(userId)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_activity_feed_group ON activity_feed(groupId)');
    await db.execute(
        'CREATE INDEX idx_activity_feed_user ON activity_feed(userId)');
    await db.execute(
        'CREATE INDEX idx_activity_feed_pet ON activity_feed(petId)');
    await db.execute(
        'CREATE INDEX idx_activity_feed_type ON activity_feed(type)');
    await db.execute(
        'CREATE INDEX idx_activity_feed_timestamp ON activity_feed(timestamp DESC)');

    // Shared pet profiles — pets shared with family groups
    await db.execute('''
      CREATE TABLE shared_pet_profiles (
        id TEXT PRIMARY KEY,
        petId TEXT NOT NULL,
        petData TEXT NOT NULL,
        groupId TEXT NOT NULL,
        sharedBy TEXT NOT NULL,
        sharedByName TEXT NOT NULL,
        sharedAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets(id),
        FOREIGN KEY (groupId) REFERENCES family_groups(id)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_shared_pet_pet ON shared_pet_profiles(petId)');
    await db.execute(
        'CREATE INDEX idx_shared_pet_group ON shared_pet_profiles(groupId)');
    await db.execute(
        'CREATE INDEX idx_shared_pet_unique ON shared_pet_profiles(petId, groupId)');
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
    await db.delete('streak_logs', where: 'petId = ?', whereArgs: [id]);
    await db.delete('pet_family_links', where: 'petId = ?', whereArgs: [id]);
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
  // STREAK LOGS
  // =========================================================================

  Future<int> insertStreakLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('streak_logs', log);
  }

  Future<List<Map<String, dynamic>>> getStreakLogsByPet(String petId,
      {DateTime? from, DateTime? to}) async {
    final db = await database;
    String query = 'petId = ?';
    List<dynamic> args = [petId];
    if (from != null) {
      query += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      query += ' AND date <= ?';
      args.add(to.toIso8601String());
    }
    return await db.query('streak_logs', where: query, whereArgs: args,
        orderBy: 'date DESC');
  }

  Future<List<String>> getStreakDatesByPet(String petId,
      {DateTime? from, DateTime? to}) async {
    final db = await database;
    String query = 'petId = ?';
    List<dynamic> args = [petId];
    if (from != null) {
      query += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      query += ' AND date <= ?';
      args.add(to.toIso8601String());
    }
    final results = await db.query('streak_logs',
        columns: ['date'], where: query, whereArgs: args);
    return results.map((r) => r['date'] as String).toList();
  }

  Future<bool> hasStreakOnDate(String petId, String date) async {
    final db = await database;
    final results = await db.query('streak_logs',
        where: 'petId = ? AND date = ?', whereArgs: [petId, date]);
    return results.isNotEmpty;
  }

  Future<int> updateStreakLog(String id, Map<String, dynamic> log) async {
    final db = await database;
    return await db.update('streak_logs', log, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStreakLog(String id) async {
    final db = await database;
    return await db.delete('streak_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStreakLogsByPet(String petId) async {
    final db = await database;
    return await db.delete('streak_logs', where: 'petId = ?', whereArgs: [petId]);
  }

  // =========================================================================
  // FAMILY GROUPS
  // =========================================================================

  Future<int> insertFamilyGroup(Map<String, dynamic> group) async {
    final db = await database;
    return await db.insert('family_groups', group);
  }

  Future<List<Map<String, dynamic>>> getAllFamilyGroups() async {
    final db = await database;
    return await db.query('family_groups', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getFamilyGroup(String id) async {
    final db = await database;
    final results = await db.query('family_groups', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateFamilyGroup(String id, Map<String, dynamic> group) async {
    final db = await database;
    return await db.update('family_groups', group, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFamilyGroup(String id) async {
    final db = await database;
    // Cascade delete members and links
    await db.delete('family_members', where: 'groupId = ?', whereArgs: [id]);
    await db.delete('pet_family_links', where: 'groupId = ?', whereArgs: [id]);
    return await db.delete('family_groups', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // FAMILY MEMBERS
  // =========================================================================

  Future<int> insertFamilyMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('family_members', member);
  }

  Future<List<Map<String, dynamic>>> getFamilyMembersByGroup(String groupId) async {
    final db = await database;
    return await db.query('family_members', where: 'groupId = ?', whereArgs: [groupId],
        orderBy: 'joinedAt DESC');
  }

  Future<Map<String, dynamic>?> getFamilyMember(String id) async {
    final db = await database;
    final results = await db.query('family_members', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateFamilyMember(String id, Map<String, dynamic> member) async {
    final db = await database;
    return await db.update('family_members', member, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFamilyMember(String id) async {
    final db = await database;
    return await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFamilyMembersByGroup(String groupId) async {
    final db = await database;
    return await db.delete('family_members', where: 'groupId = ?', whereArgs: [groupId]);
  }

  // =========================================================================
  // PET FAMILY LINKS
  // =========================================================================

  Future<int> insertPetFamilyLink(Map<String, dynamic> link) async {
    final db = await database;
    return await db.insert('pet_family_links', link);
  }

  Future<List<Map<String, dynamic>>> getPetFamilyLinksByPet(String petId) async {
    final db = await database;
    return await db.query('pet_family_links', where: 'petId = ?', whereArgs: [petId]);
  }

  Future<List<Map<String, dynamic>>> getPetFamilyLinksByGroup(String groupId) async {
    final db = await database;
    return await db.query('pet_family_links', where: 'groupId = ?', whereArgs: [groupId]);
  }

  Future<bool> isPetSharedWithGroup(String petId, String groupId) async {
    final db = await database;
    final results = await db.query('pet_family_links',
        where: 'petId = ? AND groupId = ?', whereArgs: [petId, groupId]);
    return results.isNotEmpty;
  }

  Future<int> deletePetFamilyLink(String id) async {
    final db = await database;
    return await db.delete('pet_family_links', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePetFamilyLinksByGroup(String groupId) async {
    final db = await database;
    return await db.delete('pet_family_links', where: 'groupId = ?', whereArgs: [groupId]);
  }

  Future<int> deletePetFamilyLinksByPet(String petId) async {
    final db = await database;
    return await db.delete('pet_family_links', where: 'petId = ?', whereArgs: [petId]);
  }

  // =========================================================================
  // ACHIEVEMENT EVENTS
  // =========================================================================

  Future<int> insertAchievementEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('achievement_events', event);
  }

  Future<List<Map<String, dynamic>>> getAchievementEventsByPet(String petId)
      async {
    final db = await database;
    return await db.query('achievement_events',
        where: 'petId = ?', whereArgs: [petId], orderBy: 'unlockedAt DESC');
  }

  Future<List<Map<String, dynamic>>> getAchievementEventsByType(
    String petId,
    String achievementType,
  ) async {
    final db = await database;
    return await db.query('achievement_events',
        where: 'petId = ? AND achievementType = ?',
        whereArgs: [petId, achievementType],
        orderBy: 'unlockedAt DESC');
  }

  Future<int> deleteAchievementEventsByPet(String petId) async {
    final db = await database;
    return await db.delete('achievement_events',
        where: 'petId = ?', whereArgs: [petId]);
  }

  // =========================================================================
  // INVITE TOKENS
  // =========================================================================

  Future<int> insertInviteToken(Map<String, dynamic> invite) async {
    final db = await database;
    return await db.insert('invite_tokens', invite);
  }

  Future<Map<String, dynamic>?> getInviteToken(String id) async {
    final db = await database;
    final results = await db.query('invite_tokens',
        where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getInviteTokenByCode(String code) async {
    final db = await database;
    final results = await db.query('invite_tokens',
        where: 'code = ?', whereArgs: [code]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateInviteToken(String id, Map<String, dynamic> invite) async {
    final db = await database;
    return await db.update('invite_tokens', invite,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getActiveInvitesByGroup(String groupId) async {
    final db = await database;
    return await db.query('invite_tokens',
        where: 'groupId = ? AND status = ?',
        whereArgs: [groupId, 'active']);
  }

  Future<int> expireOldInvites() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.update('invite_tokens',
        {'status': 'expired'},
        where: "status = 'active' AND expiresAt < ?",
        whereArgs: [now]);
  }

  // =========================================================================
  // ACTIVITY FEED
  // =========================================================================

  Future<int> insertActivityFeed(Map<String, dynamic> activity) async {
    final db = await database;
    return await db.insert('activity_feed', activity);
  }

  Future<int> insertActivitiesFeedBatch(List<Map<String, dynamic>> activities) async {
    final db = await database;
    final batch = db.batch();
    for (final activity in activities) {
      batch.insert('activity_feed', activity);
    }
    final results = await batch.commit();
    return results.length;
  }

  Future<List<Map<String, dynamic>>> getActivityFeedByGroup(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'activity_feed',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getActivityFeedByUser(
    String groupId,
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'activity_feed',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getActivityFeedByPet(
    String groupId,
    String petId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'activity_feed',
      where: 'groupId = ? AND petId = ?',
      whereArgs: [groupId, petId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getActivityFeedCount(String groupId) async {
    final db = await database;
    final results = await db.query(
      'activity_feed',
      where: 'groupId = ?',
      whereArgs: [groupId],
      columns: ['COUNT(*) as count'],
    );
    return results.isNotEmpty
        ? (results.first['count'] as int)
        : 0;
  }

  Future<int> getActivityFeedCountByType(
    String groupId, String type) async {
    final db = await database;
    final results = await db.query(
      'activity_feed',
      where: 'groupId = ? AND type = ?',
      whereArgs: [groupId, type],
      columns: ['COUNT(*) as count'],
    );
    return results.isNotEmpty
        ? (results.first['count'] as int)
        : 0;
  }

  Future<int> deleteActivityFeedEntry(String id) async {
    final db = await database;
    return await db.delete(
      'activity_feed',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActivityFeedByGroup(String groupId) async {
    final db = await database;
    return await db.delete(
      'activity_feed',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
  }

  /// Get today's activity count for a group
  Future<int> getTodayActivityCount(String groupId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    return await db.query(
      'activity_feed',
      where: 'groupId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [groupId, startOfDay, endOfDay],
      columns: ['COUNT(*) as count'],
    ).then((results) => results.isNotEmpty
        ? (results.first['count'] as int)
        : 0);
  }

  /// Get this week's activity count for a group
  Future<int> getWeekActivityCount(String groupId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    return await db.query(
      'activity_feed',
      where: 'groupId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [groupId, start, end],
      columns: ['COUNT(*) as count'],
    ).then((results) => results.isNotEmpty
        ? (results.first['count'] as int)
        : 0);
  }

  /// Get this month's activity count for a group
  Future<int> getMonthActivityCount(String groupId) async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    return await db.query(
      'activity_feed',
      where: 'groupId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [groupId, start, end],
      columns: ['COUNT(*) as count'],
    ).then((results) => results.isNotEmpty
        ? (results.first['count'] as int)
        : 0);
  }

  /// Get unique active user IDs for a group
  Future<List<String>> getActiveUserIds(String groupId) async {
    final db = await database;
    final results = await db.query(
      'activity_feed',
      where: 'groupId = ?',
      whereArgs: [groupId],
      columns: ['DISTINCT userId'],
      orderBy: 'MAX(timestamp) DESC',
    );
    return results.map((row) => row['userId'] as String).toList();
  }

  /// Get unique active pet IDs for a group
  Future<List<String>> getActivePetIds(String groupId) async {
    final db = await database;
    final results = await db.query(
      'activity_feed',
      where: 'groupId = ?',
      whereArgs: [groupId],
      columns: ['DISTINCT petId'],
      orderBy: 'MAX(timestamp) DESC',
    );
    return results.map((row) => row['petId'] as String).toList();
  }

  // =========================================================================
  // SHARED PET PROFILES
  // =========================================================================

  Future<int> insertSharedPetProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.insert('shared_pet_profiles', profile);
  }

  Future<List<Map<String, dynamic>>> getSharedProfilesByGroup(
    String groupId,
  ) async {
    final db = await database;
    return await db.query(
      'shared_pet_profiles',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'updatedAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getSharedProfile(String id) async {
    final db = await database;
    final results = await db.query(
      'shared_pet_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getSharedProfileByPetAndGroup(
    String petId,
    String groupId,
  ) async {
    final db = await database;
    final results = await db.query(
      'shared_pet_profiles',
      where: 'petId = ? AND groupId = ?',
      whereArgs: [petId, groupId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateSharedPetProfile(String id, Map<String, dynamic> profile) async {
    final db = await database;
    return await db.update(
      'shared_pet_profiles',
      profile,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSharedPetProfile(String id) async {
    final db = await database;
    return await db.delete(
      'shared_pet_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getSharedGroupIds(String petId) async {
    final db = await database;
    final results = await db.query(
      'shared_pet_profiles',
      where: 'petId = ?',
      whereArgs: [petId],
      columns: ['DISTINCT groupId'],
    );
    return results.map((row) => row['groupId'] as String).toList();
  }

  Future<int> touchSharedPetProfile(String id, String updatedAt) async {
    final db = await database;
    return await db.update(
      'shared_pet_profiles',
      {'updatedAt': updatedAt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getSharedPetProfileCount(String petId, String groupId) async {
    final db = await database;
    final results = await db.query(
      'shared_pet_profiles',
      where: 'petId = ? AND groupId = ?',
      whereArgs: [petId, groupId],
      columns: ['COUNT(*) as count'],
    );
    return results.isNotEmpty && (results.first['count'] as int) > 0
        ? 1
        : 0;
  }
}
