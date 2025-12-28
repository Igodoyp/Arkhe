// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MissionsTable extends Missions
    with TableInfo<$MissionsTable, MissionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    type,
    xpReward,
    isCompleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }
}

class MissionData extends DataClass implements Insertable<MissionData> {
  final String id;
  final String title;
  final String description;
  final String type;
  final int xpReward;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const MissionData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['xp_reward'] = Variable<int>(xpReward);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      type: Value(type),
      xpReward: Value(xpReward),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory MissionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'xpReward': serializer.toJson<int>(xpReward),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  MissionData copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? xpReward,
    bool? isCompleted,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => MissionData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    type: type ?? this.type,
    xpReward: xpReward ?? this.xpReward,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  MissionData copyWithCompanion(MissionsCompanion data) {
    return MissionData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('xpReward: $xpReward, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    type,
    xpReward,
    isCompleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.xpReward == this.xpReward &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MissionsCompanion extends UpdateCompanion<MissionData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> type;
  final Value<int> xpReward;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String type,
    required int xpReward,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       type = Value(type),
       xpReward = Value(xpReward);
  static Insertable<MissionData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<int>? xpReward,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (xpReward != null) 'xp_reward': xpReward,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? type,
    Value<int>? xpReward,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('xpReward: $xpReward, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStatsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statsJsonMeta = const VerificationMeta(
    'statsJson',
  );
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
    'stats_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, statsJson, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStatsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stats_json')) {
      context.handle(
        _statsJsonMeta,
        statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_statsJsonMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStatsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      statsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_json'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }
}

class UserStatsData extends DataClass implements Insertable<UserStatsData> {
  final String id;
  final String statsJson;
  final DateTime lastUpdated;
  const UserStatsData({
    required this.id,
    required this.statsJson,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stats_json'] = Variable<String>(statsJson);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      id: Value(id),
      statsJson: Value(statsJson),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory UserStatsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatsData(
      id: serializer.fromJson<String>(json['id']),
      statsJson: serializer.fromJson<String>(json['statsJson']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'statsJson': serializer.toJson<String>(statsJson),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  UserStatsData copyWith({
    String? id,
    String? statsJson,
    DateTime? lastUpdated,
  }) => UserStatsData(
    id: id ?? this.id,
    statsJson: statsJson ?? this.statsJson,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  UserStatsData copyWithCompanion(UserStatsCompanion data) {
    return UserStatsData(
      id: data.id.present ? data.id.value : this.id,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsData(')
          ..write('id: $id, ')
          ..write('statsJson: $statsJson, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, statsJson, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatsData &&
          other.id == this.id &&
          other.statsJson == this.statsJson &&
          other.lastUpdated == this.lastUpdated);
}

class UserStatsCompanion extends UpdateCompanion<UserStatsData> {
  final Value<String> id;
  final Value<String> statsJson;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const UserStatsCompanion({
    this.id = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStatsCompanion.insert({
    required String id,
    required String statsJson,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       statsJson = Value(statsJson);
  static Insertable<UserStatsData> custom({
    Expression<String>? id,
    Expression<String>? statsJson,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (statsJson != null) 'stats_json': statsJson,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStatsCompanion copyWith({
    Value<String>? id,
    Value<String>? statsJson,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return UserStatsCompanion(
      id: id ?? this.id,
      statsJson: statsJson ?? this.statsJson,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('id: $id, ')
          ..write('statsJson: $statsJson, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaySessionsTable extends DaySessions
    with TableInfo<$DaySessionsTable, DaySessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMissionIdsMeta =
      const VerificationMeta('completedMissionIds');
  @override
  late final GeneratedColumn<String> completedMissionIds =
      GeneratedColumn<String>(
        'completed_mission_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isFinalizedMeta = const VerificationMeta(
    'isFinalized',
  );
  @override
  late final GeneratedColumn<bool> isFinalized = GeneratedColumn<bool>(
    'is_finalized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_finalized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finalizedAt = GeneratedColumn<DateTime>(
    'finalized_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    completedMissionIds,
    isFinalized,
    createdAt,
    finalizedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DaySessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_mission_ids')) {
      context.handle(
        _completedMissionIdsMeta,
        completedMissionIds.isAcceptableOrUnknown(
          data['completed_mission_ids']!,
          _completedMissionIdsMeta,
        ),
      );
    }
    if (data.containsKey('is_finalized')) {
      context.handle(
        _isFinalizedMeta,
        isFinalized.isAcceptableOrUnknown(
          data['is_finalized']!,
          _isFinalizedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DaySessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaySessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      completedMissionIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_mission_ids'],
      )!,
      isFinalized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_finalized'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finalized_at'],
      ),
    );
  }

  @override
  $DaySessionsTable createAlias(String alias) {
    return $DaySessionsTable(attachedDatabase, alias);
  }
}

class DaySessionData extends DataClass implements Insertable<DaySessionData> {
  final String id;
  final DateTime date;
  final String completedMissionIds;
  final bool isFinalized;
  final DateTime createdAt;
  final DateTime? finalizedAt;
  const DaySessionData({
    required this.id,
    required this.date,
    required this.completedMissionIds,
    required this.isFinalized,
    required this.createdAt,
    this.finalizedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['completed_mission_ids'] = Variable<String>(completedMissionIds);
    map['is_finalized'] = Variable<bool>(isFinalized);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt);
    }
    return map;
  }

  DaySessionsCompanion toCompanion(bool nullToAbsent) {
    return DaySessionsCompanion(
      id: Value(id),
      date: Value(date),
      completedMissionIds: Value(completedMissionIds),
      isFinalized: Value(isFinalized),
      createdAt: Value(createdAt),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
    );
  }

  factory DaySessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaySessionData(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      completedMissionIds: serializer.fromJson<String>(
        json['completedMissionIds'],
      ),
      isFinalized: serializer.fromJson<bool>(json['isFinalized']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      finalizedAt: serializer.fromJson<DateTime?>(json['finalizedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'completedMissionIds': serializer.toJson<String>(completedMissionIds),
      'isFinalized': serializer.toJson<bool>(isFinalized),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'finalizedAt': serializer.toJson<DateTime?>(finalizedAt),
    };
  }

  DaySessionData copyWith({
    String? id,
    DateTime? date,
    String? completedMissionIds,
    bool? isFinalized,
    DateTime? createdAt,
    Value<DateTime?> finalizedAt = const Value.absent(),
  }) => DaySessionData(
    id: id ?? this.id,
    date: date ?? this.date,
    completedMissionIds: completedMissionIds ?? this.completedMissionIds,
    isFinalized: isFinalized ?? this.isFinalized,
    createdAt: createdAt ?? this.createdAt,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
  );
  DaySessionData copyWithCompanion(DaySessionsCompanion data) {
    return DaySessionData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      completedMissionIds: data.completedMissionIds.present
          ? data.completedMissionIds.value
          : this.completedMissionIds,
      isFinalized: data.isFinalized.present
          ? data.isFinalized.value
          : this.isFinalized,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaySessionData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('completedMissionIds: $completedMissionIds, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('finalizedAt: $finalizedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    completedMissionIds,
    isFinalized,
    createdAt,
    finalizedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaySessionData &&
          other.id == this.id &&
          other.date == this.date &&
          other.completedMissionIds == this.completedMissionIds &&
          other.isFinalized == this.isFinalized &&
          other.createdAt == this.createdAt &&
          other.finalizedAt == this.finalizedAt);
}

class DaySessionsCompanion extends UpdateCompanion<DaySessionData> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> completedMissionIds;
  final Value<bool> isFinalized;
  final Value<DateTime> createdAt;
  final Value<DateTime?> finalizedAt;
  final Value<int> rowid;
  const DaySessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.completedMissionIds = const Value.absent(),
    this.isFinalized = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaySessionsCompanion.insert({
    required String id,
    required DateTime date,
    this.completedMissionIds = const Value.absent(),
    this.isFinalized = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date);
  static Insertable<DaySessionData> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? completedMissionIds,
    Expression<bool>? isFinalized,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? finalizedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (completedMissionIds != null)
        'completed_mission_ids': completedMissionIds,
      if (isFinalized != null) 'is_finalized': isFinalized,
      if (createdAt != null) 'created_at': createdAt,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaySessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? completedMissionIds,
    Value<bool>? isFinalized,
    Value<DateTime>? createdAt,
    Value<DateTime?>? finalizedAt,
    Value<int>? rowid,
  }) {
    return DaySessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      completedMissionIds: completedMissionIds ?? this.completedMissionIds,
      isFinalized: isFinalized ?? this.isFinalized,
      createdAt: createdAt ?? this.createdAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (completedMissionIds.present) {
      map['completed_mission_ids'] = Variable<String>(
        completedMissionIds.value,
      );
    }
    if (isFinalized.present) {
      map['is_finalized'] = Variable<bool>(isFinalized.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaySessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('completedMissionIds: $completedMissionIds, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayFeedbacksTable extends DayFeedbacks
    with TableInfo<$DayFeedbacksTable, DayFeedbackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayFeedbacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES day_sessions (id)',
    ),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _struggledMissionIdsMeta =
      const VerificationMeta('struggledMissionIds');
  @override
  late final GeneratedColumn<String> struggledMissionIds =
      GeneratedColumn<String>(
        'struggled_mission_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _easyMissionIdsMeta = const VerificationMeta(
    'easyMissionIds',
  );
  @override
  late final GeneratedColumn<String> easyMissionIds = GeneratedColumn<String>(
    'easy_mission_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    difficulty,
    energy,
    struggledMissionIds,
    easyMissionIds,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_feedbacks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayFeedbackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('struggled_mission_ids')) {
      context.handle(
        _struggledMissionIdsMeta,
        struggledMissionIds.isAcceptableOrUnknown(
          data['struggled_mission_ids']!,
          _struggledMissionIdsMeta,
        ),
      );
    }
    if (data.containsKey('easy_mission_ids')) {
      context.handle(
        _easyMissionIdsMeta,
        easyMissionIds.isAcceptableOrUnknown(
          data['easy_mission_ids']!,
          _easyMissionIdsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayFeedbackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayFeedbackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      struggledMissionIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}struggled_mission_ids'],
      )!,
      easyMissionIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}easy_mission_ids'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DayFeedbacksTable createAlias(String alias) {
    return $DayFeedbacksTable(attachedDatabase, alias);
  }
}

class DayFeedbackData extends DataClass implements Insertable<DayFeedbackData> {
  final int id;
  final String sessionId;
  final String difficulty;
  final int energy;
  final String struggledMissionIds;
  final String easyMissionIds;
  final String notes;
  final DateTime createdAt;
  const DayFeedbackData({
    required this.id,
    required this.sessionId,
    required this.difficulty,
    required this.energy,
    required this.struggledMissionIds,
    required this.easyMissionIds,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['difficulty'] = Variable<String>(difficulty);
    map['energy'] = Variable<int>(energy);
    map['struggled_mission_ids'] = Variable<String>(struggledMissionIds);
    map['easy_mission_ids'] = Variable<String>(easyMissionIds);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DayFeedbacksCompanion toCompanion(bool nullToAbsent) {
    return DayFeedbacksCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      difficulty: Value(difficulty),
      energy: Value(energy),
      struggledMissionIds: Value(struggledMissionIds),
      easyMissionIds: Value(easyMissionIds),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory DayFeedbackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayFeedbackData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      energy: serializer.fromJson<int>(json['energy']),
      struggledMissionIds: serializer.fromJson<String>(
        json['struggledMissionIds'],
      ),
      easyMissionIds: serializer.fromJson<String>(json['easyMissionIds']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'difficulty': serializer.toJson<String>(difficulty),
      'energy': serializer.toJson<int>(energy),
      'struggledMissionIds': serializer.toJson<String>(struggledMissionIds),
      'easyMissionIds': serializer.toJson<String>(easyMissionIds),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DayFeedbackData copyWith({
    int? id,
    String? sessionId,
    String? difficulty,
    int? energy,
    String? struggledMissionIds,
    String? easyMissionIds,
    String? notes,
    DateTime? createdAt,
  }) => DayFeedbackData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    difficulty: difficulty ?? this.difficulty,
    energy: energy ?? this.energy,
    struggledMissionIds: struggledMissionIds ?? this.struggledMissionIds,
    easyMissionIds: easyMissionIds ?? this.easyMissionIds,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  DayFeedbackData copyWithCompanion(DayFeedbacksCompanion data) {
    return DayFeedbackData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      energy: data.energy.present ? data.energy.value : this.energy,
      struggledMissionIds: data.struggledMissionIds.present
          ? data.struggledMissionIds.value
          : this.struggledMissionIds,
      easyMissionIds: data.easyMissionIds.present
          ? data.easyMissionIds.value
          : this.easyMissionIds,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayFeedbackData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('difficulty: $difficulty, ')
          ..write('energy: $energy, ')
          ..write('struggledMissionIds: $struggledMissionIds, ')
          ..write('easyMissionIds: $easyMissionIds, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    difficulty,
    energy,
    struggledMissionIds,
    easyMissionIds,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayFeedbackData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.difficulty == this.difficulty &&
          other.energy == this.energy &&
          other.struggledMissionIds == this.struggledMissionIds &&
          other.easyMissionIds == this.easyMissionIds &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DayFeedbacksCompanion extends UpdateCompanion<DayFeedbackData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> difficulty;
  final Value<int> energy;
  final Value<String> struggledMissionIds;
  final Value<String> easyMissionIds;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  const DayFeedbacksCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.energy = const Value.absent(),
    this.struggledMissionIds = const Value.absent(),
    this.easyMissionIds = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DayFeedbacksCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String difficulty,
    required int energy,
    this.struggledMissionIds = const Value.absent(),
    this.easyMissionIds = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       difficulty = Value(difficulty),
       energy = Value(energy);
  static Insertable<DayFeedbackData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? difficulty,
    Expression<int>? energy,
    Expression<String>? struggledMissionIds,
    Expression<String>? easyMissionIds,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (difficulty != null) 'difficulty': difficulty,
      if (energy != null) 'energy': energy,
      if (struggledMissionIds != null)
        'struggled_mission_ids': struggledMissionIds,
      if (easyMissionIds != null) 'easy_mission_ids': easyMissionIds,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DayFeedbacksCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? difficulty,
    Value<int>? energy,
    Value<String>? struggledMissionIds,
    Value<String>? easyMissionIds,
    Value<String>? notes,
    Value<DateTime>? createdAt,
  }) {
    return DayFeedbacksCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      difficulty: difficulty ?? this.difficulty,
      energy: energy ?? this.energy,
      struggledMissionIds: struggledMissionIds ?? this.struggledMissionIds,
      easyMissionIds: easyMissionIds ?? this.easyMissionIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (struggledMissionIds.present) {
      map['struggled_mission_ids'] = Variable<String>(
        struggledMissionIds.value,
      );
    }
    if (easyMissionIds.present) {
      map['easy_mission_ids'] = Variable<String>(easyMissionIds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayFeedbacksCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('difficulty: $difficulty, ')
          ..write('energy: $energy, ')
          ..write('struggledMissionIds: $struggledMissionIds, ')
          ..write('easyMissionIds: $easyMissionIds, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  late final $DaySessionsTable daySessions = $DaySessionsTable(this);
  late final $DayFeedbacksTable dayFeedbacks = $DayFeedbacksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    missions,
    userStats,
    daySessions,
    dayFeedbacks,
  ];
}

typedef $$MissionsTableCreateCompanionBuilder =
    MissionsCompanion Function({
      required String id,
      required String title,
      required String description,
      required String type,
      required int xpReward,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$MissionsTableUpdateCompanionBuilder =
    MissionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> type,
      Value<int> xpReward,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$MissionsTableFilterComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionsTable,
          MissionData,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (
            MissionData,
            BaseReferences<_$AppDatabase, $MissionsTable, MissionData>,
          ),
          MissionData,
          PrefetchHooks Function()
        > {
  $$MissionsTableTableManager(_$AppDatabase db, $MissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                title: title,
                description: description,
                type: type,
                xpReward: xpReward,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required String type,
                required int xpReward,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                type: type,
                xpReward: xpReward,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionsTable,
      MissionData,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (MissionData, BaseReferences<_$AppDatabase, $MissionsTable, MissionData>),
      MissionData,
      PrefetchHooks Function()
    >;
typedef $$UserStatsTableCreateCompanionBuilder =
    UserStatsCompanion Function({
      required String id,
      required String statsJson,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$UserStatsTableUpdateCompanionBuilder =
    UserStatsCompanion Function({
      Value<String> id,
      Value<String> statsJson,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$UserStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserStatsTable,
          UserStatsData,
          $$UserStatsTableFilterComposer,
          $$UserStatsTableOrderingComposer,
          $$UserStatsTableAnnotationComposer,
          $$UserStatsTableCreateCompanionBuilder,
          $$UserStatsTableUpdateCompanionBuilder,
          (
            UserStatsData,
            BaseReferences<_$AppDatabase, $UserStatsTable, UserStatsData>,
          ),
          UserStatsData,
          PrefetchHooks Function()
        > {
  $$UserStatsTableTableManager(_$AppDatabase db, $UserStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStatsCompanion(
                id: id,
                statsJson: statsJson,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String statsJson,
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStatsCompanion.insert(
                id: id,
                statsJson: statsJson,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserStatsTable,
      UserStatsData,
      $$UserStatsTableFilterComposer,
      $$UserStatsTableOrderingComposer,
      $$UserStatsTableAnnotationComposer,
      $$UserStatsTableCreateCompanionBuilder,
      $$UserStatsTableUpdateCompanionBuilder,
      (
        UserStatsData,
        BaseReferences<_$AppDatabase, $UserStatsTable, UserStatsData>,
      ),
      UserStatsData,
      PrefetchHooks Function()
    >;
typedef $$DaySessionsTableCreateCompanionBuilder =
    DaySessionsCompanion Function({
      required String id,
      required DateTime date,
      Value<String> completedMissionIds,
      Value<bool> isFinalized,
      Value<DateTime> createdAt,
      Value<DateTime?> finalizedAt,
      Value<int> rowid,
    });
typedef $$DaySessionsTableUpdateCompanionBuilder =
    DaySessionsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> completedMissionIds,
      Value<bool> isFinalized,
      Value<DateTime> createdAt,
      Value<DateTime?> finalizedAt,
      Value<int> rowid,
    });

final class $$DaySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $DaySessionsTable, DaySessionData> {
  $$DaySessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DayFeedbacksTable, List<DayFeedbackData>>
  _dayFeedbacksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dayFeedbacks,
    aliasName: $_aliasNameGenerator(
      db.daySessions.id,
      db.dayFeedbacks.sessionId,
    ),
  );

  $$DayFeedbacksTableProcessedTableManager get dayFeedbacksRefs {
    final manager = $$DayFeedbacksTableTableManager(
      $_db,
      $_db.dayFeedbacks,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dayFeedbacksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DaySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DaySessionsTable> {
  $$DaySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedMissionIds => $composableBuilder(
    column: $table.completedMissionIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dayFeedbacksRefs(
    Expression<bool> Function($$DayFeedbacksTableFilterComposer f) f,
  ) {
    final $$DayFeedbacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayFeedbacks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayFeedbacksTableFilterComposer(
            $db: $db,
            $table: $db.dayFeedbacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DaySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DaySessionsTable> {
  $$DaySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedMissionIds => $composableBuilder(
    column: $table.completedMissionIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaySessionsTable> {
  $$DaySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get completedMissionIds => $composableBuilder(
    column: $table.completedMissionIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );

  Expression<T> dayFeedbacksRefs<T extends Object>(
    Expression<T> Function($$DayFeedbacksTableAnnotationComposer a) f,
  ) {
    final $$DayFeedbacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayFeedbacks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayFeedbacksTableAnnotationComposer(
            $db: $db,
            $table: $db.dayFeedbacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DaySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaySessionsTable,
          DaySessionData,
          $$DaySessionsTableFilterComposer,
          $$DaySessionsTableOrderingComposer,
          $$DaySessionsTableAnnotationComposer,
          $$DaySessionsTableCreateCompanionBuilder,
          $$DaySessionsTableUpdateCompanionBuilder,
          (DaySessionData, $$DaySessionsTableReferences),
          DaySessionData,
          PrefetchHooks Function({bool dayFeedbacksRefs})
        > {
  $$DaySessionsTableTableManager(_$AppDatabase db, $DaySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> completedMissionIds = const Value.absent(),
                Value<bool> isFinalized = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> finalizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySessionsCompanion(
                id: id,
                date: date,
                completedMissionIds: completedMissionIds,
                isFinalized: isFinalized,
                createdAt: createdAt,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<String> completedMissionIds = const Value.absent(),
                Value<bool> isFinalized = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> finalizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySessionsCompanion.insert(
                id: id,
                date: date,
                completedMissionIds: completedMissionIds,
                isFinalized: isFinalized,
                createdAt: createdAt,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DaySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayFeedbacksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dayFeedbacksRefs) db.dayFeedbacks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dayFeedbacksRefs)
                    await $_getPrefetchedData<
                      DaySessionData,
                      $DaySessionsTable,
                      DayFeedbackData
                    >(
                      currentTable: table,
                      referencedTable: $$DaySessionsTableReferences
                          ._dayFeedbacksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DaySessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).dayFeedbacksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DaySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaySessionsTable,
      DaySessionData,
      $$DaySessionsTableFilterComposer,
      $$DaySessionsTableOrderingComposer,
      $$DaySessionsTableAnnotationComposer,
      $$DaySessionsTableCreateCompanionBuilder,
      $$DaySessionsTableUpdateCompanionBuilder,
      (DaySessionData, $$DaySessionsTableReferences),
      DaySessionData,
      PrefetchHooks Function({bool dayFeedbacksRefs})
    >;
typedef $$DayFeedbacksTableCreateCompanionBuilder =
    DayFeedbacksCompanion Function({
      Value<int> id,
      required String sessionId,
      required String difficulty,
      required int energy,
      Value<String> struggledMissionIds,
      Value<String> easyMissionIds,
      Value<String> notes,
      Value<DateTime> createdAt,
    });
typedef $$DayFeedbacksTableUpdateCompanionBuilder =
    DayFeedbacksCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> difficulty,
      Value<int> energy,
      Value<String> struggledMissionIds,
      Value<String> easyMissionIds,
      Value<String> notes,
      Value<DateTime> createdAt,
    });

final class $$DayFeedbacksTableReferences
    extends BaseReferences<_$AppDatabase, $DayFeedbacksTable, DayFeedbackData> {
  $$DayFeedbacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DaySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.daySessions.createAlias(
        $_aliasNameGenerator(db.dayFeedbacks.sessionId, db.daySessions.id),
      );

  $$DaySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$DaySessionsTableTableManager(
      $_db,
      $_db.daySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DayFeedbacksTableFilterComposer
    extends Composer<_$AppDatabase, $DayFeedbacksTable> {
  $$DayFeedbacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get struggledMissionIds => $composableBuilder(
    column: $table.struggledMissionIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get easyMissionIds => $composableBuilder(
    column: $table.easyMissionIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DaySessionsTableFilterComposer get sessionId {
    final $$DaySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.daySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaySessionsTableFilterComposer(
            $db: $db,
            $table: $db.daySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayFeedbacksTableOrderingComposer
    extends Composer<_$AppDatabase, $DayFeedbacksTable> {
  $$DayFeedbacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get struggledMissionIds => $composableBuilder(
    column: $table.struggledMissionIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get easyMissionIds => $composableBuilder(
    column: $table.easyMissionIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DaySessionsTableOrderingComposer get sessionId {
    final $$DaySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.daySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.daySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayFeedbacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayFeedbacksTable> {
  $$DayFeedbacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get struggledMissionIds => $composableBuilder(
    column: $table.struggledMissionIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get easyMissionIds => $composableBuilder(
    column: $table.easyMissionIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DaySessionsTableAnnotationComposer get sessionId {
    final $$DaySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.daySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.daySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayFeedbacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayFeedbacksTable,
          DayFeedbackData,
          $$DayFeedbacksTableFilterComposer,
          $$DayFeedbacksTableOrderingComposer,
          $$DayFeedbacksTableAnnotationComposer,
          $$DayFeedbacksTableCreateCompanionBuilder,
          $$DayFeedbacksTableUpdateCompanionBuilder,
          (DayFeedbackData, $$DayFeedbacksTableReferences),
          DayFeedbackData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DayFeedbacksTableTableManager(_$AppDatabase db, $DayFeedbacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayFeedbacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayFeedbacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayFeedbacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<String> struggledMissionIds = const Value.absent(),
                Value<String> easyMissionIds = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DayFeedbacksCompanion(
                id: id,
                sessionId: sessionId,
                difficulty: difficulty,
                energy: energy,
                struggledMissionIds: struggledMissionIds,
                easyMissionIds: easyMissionIds,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String difficulty,
                required int energy,
                Value<String> struggledMissionIds = const Value.absent(),
                Value<String> easyMissionIds = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DayFeedbacksCompanion.insert(
                id: id,
                sessionId: sessionId,
                difficulty: difficulty,
                energy: energy,
                struggledMissionIds: struggledMissionIds,
                easyMissionIds: easyMissionIds,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DayFeedbacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$DayFeedbacksTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$DayFeedbacksTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DayFeedbacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayFeedbacksTable,
      DayFeedbackData,
      $$DayFeedbacksTableFilterComposer,
      $$DayFeedbacksTableOrderingComposer,
      $$DayFeedbacksTableAnnotationComposer,
      $$DayFeedbacksTableCreateCompanionBuilder,
      $$DayFeedbacksTableUpdateCompanionBuilder,
      (DayFeedbackData, $$DayFeedbacksTableReferences),
      DayFeedbackData,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
  $$DaySessionsTableTableManager get daySessions =>
      $$DaySessionsTableTableManager(_db, _db.daySessions);
  $$DayFeedbacksTableTableManager get dayFeedbacks =>
      $$DayFeedbacksTableTableManager(_db, _db.dayFeedbacks);
}
