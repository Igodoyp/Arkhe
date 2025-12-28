import 'package:drift/drift.dart';

@DataClassName('MissionData')
class Missions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text()();
  TextColumn get type => text()();
  IntColumn get xpReward => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserStatsData')
class UserStats extends Table {
  TextColumn get id => text()();
  TextColumn get statsJson => text()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DaySessionData')
class DaySessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get completedMissionIds => text().withDefault(const Constant('[]'))();
  BoolColumn get isFinalized => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finalizedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayFeedbackData')
class DayFeedbacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(DaySessions, #id)();
  TextColumn get difficulty => text()();
  IntColumn get energy => integer()();
  TextColumn get struggledMissionIds => text().withDefault(const Constant('[]'))();
  TextColumn get easyMissionIds => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
