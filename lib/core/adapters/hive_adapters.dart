import 'package:hive_flutter/hive_flutter.dart';
import '../../features/pets/data/models/pet_local_model.dart';
import '../../features/feeding/data/models/feeding_local_model.dart';
import '../../features/health/data/models/health_log_local_model.dart';
import '../../features/vaccinations/data/models/vaccination_local_model.dart';
import '../../features/medications/data/models/medication_local_model.dart';
import '../../features/tracking/data/models/weight_log_local_model.dart';
import '../../features/family/data/models/family_member_local_model.dart';

/// Hive adapter registry
///
/// Registers all Hive ValueAdapter classes for typed storage.
/// Called once during app initialization via [registerAdapters].
void registerAdapters() {
  // Pet adapter
  Hive.registerAdapter(PetLocalModelAdapter());

  // Feeding log adapter
  Hive.registerAdapter(FeedingLocalModelAdapter());

  // Health log adapter
  Hive.registerAdapter(HealthLogLocalModelAdapter());

  // Vaccination adapter
  Hive.registerAdapter(VaccinationLocalModelAdapter());

  // Medication adapter
  Hive.registerAdapter(MedicationLocalModelAdapter());

  // Weight log adapter
  Hive.registerAdapter(WeightLogLocalModelAdapter());

  // Family member adapter
  Hive.registerAdapter(FamilyMemberLocalModelAdapter());
}

// ---------------------------------------------------------------------------
// PetLocalModelAdapter (field 0)
// ---------------------------------------------------------------------------

class PetLocalModelAdapter extends TypeAdapter<PetLocalModel> {
  @override
  final int typeId = 0;

  @override
  PetLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetLocalModel(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      breed: fields[3] as String? ?? '',
      photoUri: fields[4] as String?,
      birthDate: fields[5] as String?,
      weight: fields[6] as double?,
      notes: fields[7] as String?,
      isNeutered: fields[8] as bool? ?? false,
      isMicrochipped: fields[9] as bool? ?? false,
      microchipId: fields[10] as String?,
      createdAt: fields[11] as String,
      updatedAt: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PetLocalModel obj) {
    writer.writeByte(13);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.species);
    writer.writeByte(3);
    writer.write(obj.breed);
    writer.writeByte(4);
    writer.write(obj.photoUri);
    writer.writeByte(5);
    writer.write(obj.birthDate);
    writer.writeByte(6);
    writer.write(obj.weight);
    writer.writeByte(7);
    writer.write(obj.notes);
    writer.writeByte(8);
    writer.write(obj.isNeutered);
    writer.writeByte(9);
    writer.write(obj.isMicrochipped);
    writer.writeByte(10);
    writer.write(obj.microchipId);
    writer.writeByte(11);
    writer.write(obj.createdAt);
    writer.writeByte(12);
    writer.write(obj.updatedAt);
  }
}

// ---------------------------------------------------------------------------
// FeedingLocalModelAdapter (field 1)
// ---------------------------------------------------------------------------

class FeedingLocalModelAdapter extends TypeAdapter<FeedingLocalModel> {
  @override
  final int typeId = 1;

  @override
  FeedingLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedingLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      mealType: fields[2] as String,
      amount: fields[3] as double? ?? 0.0,
      unit: fields[4] as String? ?? 'g',
      scheduledTime: fields[5] as String,
      actualTime: fields[6] as String?,
      completed: fields[7] as bool? ?? false,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedingLocalModel obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.mealType);
    writer.writeByte(3);
    writer.write(obj.amount);
    writer.writeByte(4);
    writer.write(obj.unit);
    writer.writeByte(5);
    writer.write(obj.scheduledTime);
    writer.writeByte(6);
    writer.write(obj.actualTime);
    writer.writeByte(7);
    writer.write(obj.completed);
    writer.writeByte(8);
    writer.write(obj.notes);
  }
}

// ---------------------------------------------------------------------------
// HealthLogLocalModelAdapter (field 2)
// ---------------------------------------------------------------------------

class HealthLogLocalModelAdapter extends TypeAdapter<HealthLogLocalModel> {
  @override
  final int typeId = 2;

  @override
  HealthLogLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthLogLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      logType: fields[2] as String,
      title: fields[3] as String? ?? '',
      description: fields[4] as String?,
      date: fields[5] as String,
      severity: fields[6] as String?,
      imageUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthLogLocalModel obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.logType);
    writer.writeByte(3);
    writer.write(obj.title);
    writer.writeByte(4);
    writer.write(obj.description);
    writer.writeByte(5);
    writer.write(obj.date);
    writer.writeByte(6);
    writer.write(obj.severity);
    writer.writeByte(7);
    writer.write(obj.imageUrl);
  }
}

// ---------------------------------------------------------------------------
// VaccinationLocalModelAdapter (field 3)
// ---------------------------------------------------------------------------

class VaccinationLocalModelAdapter extends TypeAdapter<VaccinationLocalModel> {
  @override
  final int typeId = 3;

  @override
  VaccinationLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccinationLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      vaccineName: fields[2] as String,
      dateIssued: fields[3] as String,
      nextDueDate: fields[4] as String?,
      batchNumber: fields[5] as String?,
      notes: fields[6] as String?,
      completed: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationLocalModel obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.vaccineName);
    writer.writeByte(3);
    writer.write(obj.dateIssued);
    writer.writeByte(4);
    writer.write(obj.nextDueDate);
    writer.writeByte(5);
    writer.write(obj.batchNumber);
    writer.writeByte(6);
    writer.write(obj.notes);
    writer.writeByte(7);
    writer.write(obj.completed);
  }
}

// ---------------------------------------------------------------------------
// MedicationLocalModelAdapter (field 4)
// ---------------------------------------------------------------------------

class MedicationLocalModelAdapter extends TypeAdapter<MedicationLocalModel> {
  @override
  final int typeId = 4;

  @override
  MedicationLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      name: fields[2] as String,
      dosage: fields[3] as String,
      unit: fields[4] as String? ?? 'mg',
      frequency: fields[5] as String,
      startDate: fields[6] as String,
      endDate: fields[7] as String?,
      instructions: fields[8] as String?,
      completedDoses: fields[9] as int? ?? 0,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationLocalModel obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.name);
    writer.writeByte(3);
    writer.write(obj.dosage);
    writer.writeByte(4);
    writer.write(obj.unit);
    writer.writeByte(5);
    writer.write(obj.frequency);
    writer.writeByte(6);
    writer.write(obj.startDate);
    writer.writeByte(7);
    writer.write(obj.endDate);
    writer.writeByte(8);
    writer.write(obj.instructions);
    writer.writeByte(9);
    writer.write(obj.completedDoses);
    writer.writeByte(10);
    writer.write(obj.notes);
  }
}

// ---------------------------------------------------------------------------
// WeightLogLocalModelAdapter (field 5)
// ---------------------------------------------------------------------------

class WeightLogLocalModelAdapter extends TypeAdapter<WeightLogLocalModel> {
  @override
  final int typeId = 5;

  @override
  WeightLogLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightLogLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      weight: fields[2] as double,
      date: fields[3] as String,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeightLogLocalModel obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.weight);
    writer.writeByte(3);
    writer.write(obj.date);
    writer.writeByte(4);
    writer.write(obj.notes);
  }
}

// ---------------------------------------------------------------------------
// FamilyMemberLocalModelAdapter (field 6)
// ---------------------------------------------------------------------------

class FamilyMemberLocalModelAdapter extends TypeAdapter<FamilyMemberLocalModel> {
  @override
  final int typeId = 6;

  @override
  FamilyMemberLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyMemberLocalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      userId: fields[2] as String,
      name: fields[3] as String,
      role: fields[4] as String,
      joinedAt: fields[5] as String,
      avatarUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyMemberLocalModel obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.petId);
    writer.writeByte(2);
    writer.write(obj.userId);
    writer.writeByte(3);
    writer.write(obj.name);
    writer.writeByte(4);
    writer.write(obj.role);
    writer.writeByte(5);
    writer.write(obj.joinedAt);
    writer.writeByte(6);
    writer.write(obj.avatarUrl);
  }
}
