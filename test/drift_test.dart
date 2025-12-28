import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:d0/features/missions/data/datasources/local/drift/database.dart';

void main() {
  test('Database should create tables', () async {
    // Crear BD en memoria
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    
    // Intentar insertar una misión
    await db.into(db.missions).insert(MissionsCompanion.insert(
      id: 'test_mission_1',
      title: 'Test Mission',
      description: 'This is a test',
      type: 'physical',
      xpReward: 50,
    ));
    
    // Leer misiones
    final missions = await db.select(db.missions).get();
    
    // Verificar
    expect(missions.length, 1);
    expect(missions.first.title, 'Test Mission');
    
    // Limpiar
    await db.close();
  });
}
