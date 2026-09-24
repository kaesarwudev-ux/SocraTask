// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectMeta = const VerificationMeta(
    'project',
  );
  @override
  late final GeneratedColumn<String> project = GeneratedColumn<String>(
    'project',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Inbox'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    project,
    priority,
    done,
    dueAt,
    listId,
    parentId,
    deletedAt,
    version,
    dirty,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('project')) {
      context.handle(
        _projectMeta,
        project.isAcceptableOrUnknown(data['project']!, _projectMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
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
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      project: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? notes;
  final String project;
  final int priority;
  final bool done;
  final DateTime? dueAt;
  final int listId;
  final int? parentId;
  final DateTime? deletedAt;
  final int version;
  final bool dirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    required this.project,
    required this.priority,
    required this.done,
    this.dueAt,
    required this.listId,
    this.parentId,
    this.deletedAt,
    required this.version,
    required this.dirty,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['project'] = Variable<String>(project);
    map['priority'] = Variable<int>(priority);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['list_id'] = Variable<int>(listId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['dirty'] = Variable<bool>(dirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      project: Value(project),
      priority: Value(priority),
      done: Value(done),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      listId: Value(listId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      dirty: Value(dirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      project: serializer.fromJson<String>(json['project']),
      priority: serializer.fromJson<int>(json['priority']),
      done: serializer.fromJson<bool>(json['done']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      listId: serializer.fromJson<int>(json['listId']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'project': serializer.toJson<String>(project),
      'priority': serializer.toJson<int>(priority),
      'done': serializer.toJson<bool>(done),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'listId': serializer.toJson<int>(listId),
      'parentId': serializer.toJson<int?>(parentId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'dirty': serializer.toJson<bool>(dirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? project,
    int? priority,
    bool? done,
    Value<DateTime?> dueAt = const Value.absent(),
    int? listId,
    Value<int?> parentId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    bool? dirty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    project: project ?? this.project,
    priority: priority ?? this.priority,
    done: done ?? this.done,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    listId: listId ?? this.listId,
    parentId: parentId.present ? parentId.value : this.parentId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    dirty: dirty ?? this.dirty,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      project: data.project.present ? data.project.value : this.project,
      priority: data.priority.present ? data.priority.value : this.priority,
      done: data.done.present ? data.done.value : this.done,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      listId: data.listId.present ? data.listId.value : this.listId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('project: $project, ')
          ..write('priority: $priority, ')
          ..write('done: $done, ')
          ..write('dueAt: $dueAt, ')
          ..write('listId: $listId, ')
          ..write('parentId: $parentId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    project,
    priority,
    done,
    dueAt,
    listId,
    parentId,
    deletedAt,
    version,
    dirty,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.project == this.project &&
          other.priority == this.priority &&
          other.done == this.done &&
          other.dueAt == this.dueAt &&
          other.listId == this.listId &&
          other.parentId == this.parentId &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.dirty == this.dirty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> project;
  final Value<int> priority;
  final Value<bool> done;
  final Value<DateTime?> dueAt;
  final Value<int> listId;
  final Value<int?> parentId;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<bool> dirty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.project = const Value.absent(),
    this.priority = const Value.absent(),
    this.done = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.listId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.project = const Value.absent(),
    this.priority = const Value.absent(),
    this.done = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.listId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? project,
    Expression<int>? priority,
    Expression<bool>? done,
    Expression<DateTime>? dueAt,
    Expression<int>? listId,
    Expression<int>? parentId,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<bool>? dirty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (project != null) 'project': project,
      if (priority != null) 'priority': priority,
      if (done != null) 'done': done,
      if (dueAt != null) 'due_at': dueAt,
      if (listId != null) 'list_id': listId,
      if (parentId != null) 'parent_id': parentId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (dirty != null) 'dirty': dirty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? project,
    Value<int>? priority,
    Value<bool>? done,
    Value<DateTime?>? dueAt,
    Value<int>? listId,
    Value<int?>? parentId,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<bool>? dirty,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      project: project ?? this.project,
      priority: priority ?? this.priority,
      done: done ?? this.done,
      dueAt: dueAt ?? this.dueAt,
      listId: listId ?? this.listId,
      parentId: parentId ?? this.parentId,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      dirty: dirty ?? this.dirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (project.present) {
      map['project'] = Variable<String>(project.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('project: $project, ')
          ..write('priority: $priority, ')
          ..write('done: $done, ')
          ..write('dueAt: $dueAt, ')
          ..write('listId: $listId, ')
          ..write('parentId: $parentId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TaskListsTable extends TaskLists
    with TableInfo<$TaskListsTable, TaskList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskListsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  TaskList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskListsTable createAlias(String alias) {
    return $TaskListsTable(attachedDatabase, alias);
  }
}

class TaskList extends DataClass implements Insertable<TaskList> {
  final int id;
  final String name;
  final DateTime createdAt;
  const TaskList({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskListsCompanion toCompanion(bool nullToAbsent) {
    return TaskListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory TaskList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskList copyWith({int? id, String? name, DateTime? createdAt}) => TaskList(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskList copyWithCompanion(TaskListsCompanion data) {
    return TaskList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TaskListsCompanion extends UpdateCompanion<TaskList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const TaskListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TaskList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return TaskListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    kind,
    entityId,
    op,
    payloadJson,
    attempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
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
  OutboxOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxOp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxOp extends DataClass implements Insertable<OutboxOp> {
  final int id;
  final String kind;
  final int entityId;
  final String op;
  final String payloadJson;
  final int attempts;
  final DateTime createdAt;
  const OutboxOp({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.op,
    required this.payloadJson,
    required this.attempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['entity_id'] = Variable<int>(entityId);
    map['op'] = Variable<String>(op);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      id: Value(id),
      kind: Value(kind),
      entityId: Value(entityId),
      op: Value(op),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxOp(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      entityId: serializer.fromJson<int>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'entityId': serializer.toJson<int>(entityId),
      'op': serializer.toJson<String>(op),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxOp copyWith({
    int? id,
    String? kind,
    int? entityId,
    String? op,
    String? payloadJson,
    int? attempts,
    DateTime? createdAt,
  }) => OutboxOp(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payloadJson: payloadJson ?? this.payloadJson,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxOp copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxOp(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOp(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, entityId, op, payloadJson, attempts, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxOp &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxOp> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int> entityId;
  final Value<String> op;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  const OutboxOpsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required int entityId,
    required String op,
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : kind = Value(kind),
       entityId = Value(entityId),
       op = Value(op);
  static Insertable<OutboxOp> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? entityId,
    Expression<String>? op,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int>? entityId,
    Value<String>? op,
    Value<String>? payloadJson,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
  }) {
    return OutboxOpsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end = GeneratedColumn<DateTime>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<String> guests = GeneratedColumn<String>(
    'guests',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _busyMeta = const VerificationMeta('busy');
  @override
  late final GeneratedColumn<bool> busy = GeneratedColumn<bool>(
    'busy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("busy" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Default'),
  );
  static const VerificationMeta _remindersMeta = const VerificationMeta(
    'reminders',
  );
  @override
  late final GeneratedColumn<String> reminders = GeneratedColumn<String>(
    'reminders',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _guestFlagsMeta = const VerificationMeta(
    'guestFlags',
  );
  @override
  late final GeneratedColumn<int> guestFlags = GeneratedColumn<int>(
    'guest_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    location,
    start,
    end,
    allDay,
    colorId,
    feedId,
    uid,
    guests,
    busy,
    visibility,
    reminders,
    guestFlags,
    deletedAt,
    version,
    dirty,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('guests')) {
      context.handle(
        _guestsMeta,
        guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta),
      );
    }
    if (data.containsKey('busy')) {
      context.handle(
        _busyMeta,
        busy.isAcceptableOrUnknown(data['busy']!, _busyMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('reminders')) {
      context.handle(
        _remindersMeta,
        reminders.isAcceptableOrUnknown(data['reminders']!, _remindersMeta),
      );
    }
    if (data.containsKey('guest_flags')) {
      context.handle(
        _guestFlagsMeta,
        guestFlags.isAcceptableOrUnknown(data['guest_flags']!, _guestFlagsMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
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
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      guests: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guests'],
      )!,
      busy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}busy'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      reminders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders'],
      )!,
      guestFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guest_flags'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final int colorId;
  final int feedId;
  final String uid;
  final String guests;
  final bool busy;
  final String visibility;
  final String reminders;
  final int guestFlags;
  final DateTime? deletedAt;
  final int version;
  final bool dirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.start,
    required this.end,
    required this.allDay,
    required this.colorId,
    required this.feedId,
    required this.uid,
    required this.guests,
    required this.busy,
    required this.visibility,
    required this.reminders,
    required this.guestFlags,
    this.deletedAt,
    required this.version,
    required this.dirty,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['start'] = Variable<DateTime>(start);
    map['end'] = Variable<DateTime>(end);
    map['all_day'] = Variable<bool>(allDay);
    map['color_id'] = Variable<int>(colorId);
    map['feed_id'] = Variable<int>(feedId);
    map['uid'] = Variable<String>(uid);
    map['guests'] = Variable<String>(guests);
    map['busy'] = Variable<bool>(busy);
    map['visibility'] = Variable<String>(visibility);
    map['reminders'] = Variable<String>(reminders);
    map['guest_flags'] = Variable<int>(guestFlags);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['dirty'] = Variable<bool>(dirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      start: Value(start),
      end: Value(end),
      allDay: Value(allDay),
      colorId: Value(colorId),
      feedId: Value(feedId),
      uid: Value(uid),
      guests: Value(guests),
      busy: Value(busy),
      visibility: Value(visibility),
      reminders: Value(reminders),
      guestFlags: Value(guestFlags),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      dirty: Value(dirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      location: serializer.fromJson<String?>(json['location']),
      start: serializer.fromJson<DateTime>(json['start']),
      end: serializer.fromJson<DateTime>(json['end']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      colorId: serializer.fromJson<int>(json['colorId']),
      feedId: serializer.fromJson<int>(json['feedId']),
      uid: serializer.fromJson<String>(json['uid']),
      guests: serializer.fromJson<String>(json['guests']),
      busy: serializer.fromJson<bool>(json['busy']),
      visibility: serializer.fromJson<String>(json['visibility']),
      reminders: serializer.fromJson<String>(json['reminders']),
      guestFlags: serializer.fromJson<int>(json['guestFlags']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'location': serializer.toJson<String?>(location),
      'start': serializer.toJson<DateTime>(start),
      'end': serializer.toJson<DateTime>(end),
      'allDay': serializer.toJson<bool>(allDay),
      'colorId': serializer.toJson<int>(colorId),
      'feedId': serializer.toJson<int>(feedId),
      'uid': serializer.toJson<String>(uid),
      'guests': serializer.toJson<String>(guests),
      'busy': serializer.toJson<bool>(busy),
      'visibility': serializer.toJson<String>(visibility),
      'reminders': serializer.toJson<String>(reminders),
      'guestFlags': serializer.toJson<int>(guestFlags),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'dirty': serializer.toJson<bool>(dirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Event copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? start,
    DateTime? end,
    bool? allDay,
    int? colorId,
    int? feedId,
    String? uid,
    String? guests,
    bool? busy,
    String? visibility,
    String? reminders,
    int? guestFlags,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    bool? dirty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    location: location.present ? location.value : this.location,
    start: start ?? this.start,
    end: end ?? this.end,
    allDay: allDay ?? this.allDay,
    colorId: colorId ?? this.colorId,
    feedId: feedId ?? this.feedId,
    uid: uid ?? this.uid,
    guests: guests ?? this.guests,
    busy: busy ?? this.busy,
    visibility: visibility ?? this.visibility,
    reminders: reminders ?? this.reminders,
    guestFlags: guestFlags ?? this.guestFlags,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    dirty: dirty ?? this.dirty,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      uid: data.uid.present ? data.uid.value : this.uid,
      guests: data.guests.present ? data.guests.value : this.guests,
      busy: data.busy.present ? data.busy.value : this.busy,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      reminders: data.reminders.present ? data.reminders.value : this.reminders,
      guestFlags: data.guestFlags.present
          ? data.guestFlags.value
          : this.guestFlags,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('allDay: $allDay, ')
          ..write('colorId: $colorId, ')
          ..write('feedId: $feedId, ')
          ..write('uid: $uid, ')
          ..write('guests: $guests, ')
          ..write('busy: $busy, ')
          ..write('visibility: $visibility, ')
          ..write('reminders: $reminders, ')
          ..write('guestFlags: $guestFlags, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('dirty: $dirty, ')
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
    location,
    start,
    end,
    allDay,
    colorId,
    feedId,
    uid,
    guests,
    busy,
    visibility,
    reminders,
    guestFlags,
    deletedAt,
    version,
    dirty,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.location == this.location &&
          other.start == this.start &&
          other.end == this.end &&
          other.allDay == this.allDay &&
          other.colorId == this.colorId &&
          other.feedId == this.feedId &&
          other.uid == this.uid &&
          other.guests == this.guests &&
          other.busy == this.busy &&
          other.visibility == this.visibility &&
          other.reminders == this.reminders &&
          other.guestFlags == this.guestFlags &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.dirty == this.dirty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> location;
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<bool> allDay;
  final Value<int> colorId;
  final Value<int> feedId;
  final Value<String> uid;
  final Value<String> guests;
  final Value<bool> busy;
  final Value<String> visibility;
  final Value<String> reminders;
  final Value<int> guestFlags;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<bool> dirty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.allDay = const Value.absent(),
    this.colorId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.uid = const Value.absent(),
    this.guests = const Value.absent(),
    this.busy = const Value.absent(),
    this.visibility = const Value.absent(),
    this.reminders = const Value.absent(),
    this.guestFlags = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime start,
    required DateTime end,
    this.allDay = const Value.absent(),
    this.colorId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.uid = const Value.absent(),
    this.guests = const Value.absent(),
    this.busy = const Value.absent(),
    this.visibility = const Value.absent(),
    this.reminders = const Value.absent(),
    this.guestFlags = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       start = Value(start),
       end = Value(end);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? location,
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<bool>? allDay,
    Expression<int>? colorId,
    Expression<int>? feedId,
    Expression<String>? uid,
    Expression<String>? guests,
    Expression<bool>? busy,
    Expression<String>? visibility,
    Expression<String>? reminders,
    Expression<int>? guestFlags,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<bool>? dirty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (allDay != null) 'all_day': allDay,
      if (colorId != null) 'color_id': colorId,
      if (feedId != null) 'feed_id': feedId,
      if (uid != null) 'uid': uid,
      if (guests != null) 'guests': guests,
      if (busy != null) 'busy': busy,
      if (visibility != null) 'visibility': visibility,
      if (reminders != null) 'reminders': reminders,
      if (guestFlags != null) 'guest_flags': guestFlags,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (dirty != null) 'dirty': dirty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? location,
    Value<DateTime>? start,
    Value<DateTime>? end,
    Value<bool>? allDay,
    Value<int>? colorId,
    Value<int>? feedId,
    Value<String>? uid,
    Value<String>? guests,
    Value<bool>? busy,
    Value<String>? visibility,
    Value<String>? reminders,
    Value<int>? guestFlags,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<bool>? dirty,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      start: start ?? this.start,
      end: end ?? this.end,
      allDay: allDay ?? this.allDay,
      colorId: colorId ?? this.colorId,
      feedId: feedId ?? this.feedId,
      uid: uid ?? this.uid,
      guests: guests ?? this.guests,
      busy: busy ?? this.busy,
      visibility: visibility ?? this.visibility,
      reminders: reminders ?? this.reminders,
      guestFlags: guestFlags ?? this.guestFlags,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      dirty: dirty ?? this.dirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<DateTime>(end.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (guests.present) {
      map['guests'] = Variable<String>(guests.value);
    }
    if (busy.present) {
      map['busy'] = Variable<bool>(busy.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<String>(reminders.value);
    }
    if (guestFlags.present) {
      map['guest_flags'] = Variable<int>(guestFlags.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('allDay: $allDay, ')
          ..write('colorId: $colorId, ')
          ..write('feedId: $feedId, ')
          ..write('uid: $uid, ')
          ..write('guests: $guests, ')
          ..write('busy: $busy, ')
          ..write('visibility: $visibility, ')
          ..write('reminders: $reminders, ')
          ..write('guestFlags: $guestFlags, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CalendarFeedsTable extends CalendarFeeds
    with TableInfo<$CalendarFeedsTable, CalendarFeed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarFeedsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    name,
    url,
    colorId,
    enabled,
    lastSyncAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarFeed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
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
  CalendarFeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarFeed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CalendarFeedsTable createAlias(String alias) {
    return $CalendarFeedsTable(attachedDatabase, alias);
  }
}

class CalendarFeed extends DataClass implements Insertable<CalendarFeed> {
  final int id;
  final String name;
  final String url;
  final int colorId;
  final bool enabled;
  final DateTime? lastSyncAt;
  final DateTime createdAt;
  const CalendarFeed({
    required this.id,
    required this.name,
    required this.url,
    required this.colorId,
    required this.enabled,
    this.lastSyncAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['color_id'] = Variable<int>(colorId);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalendarFeedsCompanion toCompanion(bool nullToAbsent) {
    return CalendarFeedsCompanion(
      id: Value(id),
      name: Value(name),
      url: Value(url),
      colorId: Value(colorId),
      enabled: Value(enabled),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      createdAt: Value(createdAt),
    );
  }

  factory CalendarFeed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarFeed(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      colorId: serializer.fromJson<int>(json['colorId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'colorId': serializer.toJson<int>(colorId),
      'enabled': serializer.toJson<bool>(enabled),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalendarFeed copyWith({
    int? id,
    String? name,
    String? url,
    int? colorId,
    bool? enabled,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    DateTime? createdAt,
  }) => CalendarFeed(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    colorId: colorId ?? this.colorId,
    enabled: enabled ?? this.enabled,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    createdAt: createdAt ?? this.createdAt,
  );
  CalendarFeed copyWithCompanion(CalendarFeedsCompanion data) {
    return CalendarFeed(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarFeed(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('colorId: $colorId, ')
          ..write('enabled: $enabled, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, url, colorId, enabled, lastSyncAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarFeed &&
          other.id == this.id &&
          other.name == this.name &&
          other.url == this.url &&
          other.colorId == this.colorId &&
          other.enabled == this.enabled &&
          other.lastSyncAt == this.lastSyncAt &&
          other.createdAt == this.createdAt);
}

class CalendarFeedsCompanion extends UpdateCompanion<CalendarFeed> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> url;
  final Value<int> colorId;
  final Value<bool> enabled;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime> createdAt;
  const CalendarFeedsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.colorId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CalendarFeedsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.url = const Value.absent(),
    this.colorId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CalendarFeed> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? url,
    Expression<int>? colorId,
    Expression<bool>? enabled,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (colorId != null) 'color_id': colorId,
      if (enabled != null) 'enabled': enabled,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CalendarFeedsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? url,
    Value<int>? colorId,
    Value<bool>? enabled,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime>? createdAt,
  }) {
    return CalendarFeedsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      colorId: colorId ?? this.colorId,
      enabled: enabled ?? this.enabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarFeedsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('colorId: $colorId, ')
          ..write('enabled: $enabled, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trashedMeta = const VerificationMeta(
    'trashed',
  );
  @override
  late final GeneratedColumn<bool> trashed = GeneratedColumn<bool>(
    'trashed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trashed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trashedAtMeta = const VerificationMeta(
    'trashedAt',
  );
  @override
  late final GeneratedColumn<DateTime> trashedAt = GeneratedColumn<DateTime>(
    'trashed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    colorId,
    pinned,
    archived,
    trashed,
    trashedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('trashed')) {
      context.handle(
        _trashedMeta,
        trashed.isAcceptableOrUnknown(data['trashed']!, _trashedMeta),
      );
    }
    if (data.containsKey('trashed_at')) {
      context.handle(
        _trashedAtMeta,
        trashedAt.isAcceptableOrUnknown(data['trashed_at']!, _trashedAtMeta),
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
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_id'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      trashed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trashed'],
      )!,
      trashedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trashed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String title;
  final String body;
  final int colorId;
  final bool pinned;
  final bool archived;
  final bool trashed;
  final DateTime? trashedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.colorId,
    required this.pinned,
    required this.archived,
    required this.trashed,
    this.trashedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['color_id'] = Variable<int>(colorId);
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    map['trashed'] = Variable<bool>(trashed);
    if (!nullToAbsent || trashedAt != null) {
      map['trashed_at'] = Variable<DateTime>(trashedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      colorId: Value(colorId),
      pinned: Value(pinned),
      archived: Value(archived),
      trashed: Value(trashed),
      trashedAt: trashedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trashedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      colorId: serializer.fromJson<int>(json['colorId']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      trashed: serializer.fromJson<bool>(json['trashed']),
      trashedAt: serializer.fromJson<DateTime?>(json['trashedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'colorId': serializer.toJson<int>(colorId),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'trashed': serializer.toJson<bool>(trashed),
      'trashedAt': serializer.toJson<DateTime?>(trashedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    int? colorId,
    bool? pinned,
    bool? archived,
    bool? trashed,
    Value<DateTime?> trashedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    colorId: colorId ?? this.colorId,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    trashed: trashed ?? this.trashed,
    trashedAt: trashedAt.present ? trashedAt.value : this.trashedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      trashed: data.trashed.present ? data.trashed.value : this.trashed,
      trashedAt: data.trashedAt.present ? data.trashedAt.value : this.trashedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('colorId: $colorId, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('trashed: $trashed, ')
          ..write('trashedAt: $trashedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    colorId,
    pinned,
    archived,
    trashed,
    trashedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.colorId == this.colorId &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.trashed == this.trashed &&
          other.trashedAt == this.trashedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<int> colorId;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<bool> trashed;
  final Value<DateTime?> trashedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.colorId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.trashed = const Value.absent(),
    this.trashedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.colorId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.trashed = const Value.absent(),
    this.trashedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? colorId,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<bool>? trashed,
    Expression<DateTime>? trashedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (colorId != null) 'color_id': colorId,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (trashed != null) 'trashed': trashed,
      if (trashedAt != null) 'trashed_at': trashedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<int>? colorId,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<bool>? trashed,
    Value<DateTime?>? trashedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      colorId: colorId ?? this.colorId,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      trashed: trashed ?? this.trashed,
      trashedAt: trashedAt ?? this.trashedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (trashed.present) {
      map['trashed'] = Variable<bool>(trashed.value);
    }
    if (trashedAt.present) {
      map['trashed_at'] = Variable<DateTime>(trashedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('colorId: $colorId, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('trashed: $trashed, ')
          ..write('trashedAt: $trashedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels with TableInfo<$LabelsTable, Label> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Label> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Label map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Label(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class Label extends DataClass implements Insertable<Label> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Label({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Label.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Label(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Label copyWith({int? id, String? name, DateTime? createdAt}) => Label(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Label copyWithCompanion(LabelsCompanion data) {
    return Label(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Label(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class LabelsCompanion extends UpdateCompanion<Label> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const LabelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LabelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Label> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LabelsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return LabelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NoteLabelsTable extends NoteLabels
    with TableInfo<$NoteLabelsTable, NoteLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, labelId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteLabel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, labelId};
  @override
  NoteLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteLabel(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label_id'],
      )!,
    );
  }

  @override
  $NoteLabelsTable createAlias(String alias) {
    return $NoteLabelsTable(attachedDatabase, alias);
  }
}

class NoteLabel extends DataClass implements Insertable<NoteLabel> {
  final int noteId;
  final int labelId;
  const NoteLabel({required this.noteId, required this.labelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<int>(noteId);
    map['label_id'] = Variable<int>(labelId);
    return map;
  }

  NoteLabelsCompanion toCompanion(bool nullToAbsent) {
    return NoteLabelsCompanion(noteId: Value(noteId), labelId: Value(labelId));
  }

  factory NoteLabel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteLabel(
      noteId: serializer.fromJson<int>(json['noteId']),
      labelId: serializer.fromJson<int>(json['labelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<int>(noteId),
      'labelId': serializer.toJson<int>(labelId),
    };
  }

  NoteLabel copyWith({int? noteId, int? labelId}) => NoteLabel(
    noteId: noteId ?? this.noteId,
    labelId: labelId ?? this.labelId,
  );
  NoteLabel copyWithCompanion(NoteLabelsCompanion data) {
    return NoteLabel(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteLabel(')
          ..write('noteId: $noteId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, labelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteLabel &&
          other.noteId == this.noteId &&
          other.labelId == this.labelId);
}

class NoteLabelsCompanion extends UpdateCompanion<NoteLabel> {
  final Value<int> noteId;
  final Value<int> labelId;
  final Value<int> rowid;
  const NoteLabelsCompanion({
    this.noteId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteLabelsCompanion.insert({
    required int noteId,
    required int labelId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       labelId = Value(labelId);
  static Insertable<NoteLabel> custom({
    Expression<int>? noteId,
    Expression<int>? labelId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (labelId != null) 'label_id': labelId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteLabelsCompanion copyWith({
    Value<int>? noteId,
    Value<int>? labelId,
    Value<int>? rowid,
  }) {
    return NoteLabelsCompanion(
      noteId: noteId ?? this.noteId,
      labelId: labelId ?? this.labelId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteLabelsCompanion(')
          ..write('noteId: $noteId, ')
          ..write('labelId: $labelId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, noteId, content, done, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChecklistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItem extends DataClass implements Insertable<ChecklistItem> {
  final int id;
  final int noteId;
  final String content;
  final bool done;
  final int position;
  const ChecklistItem({
    required this.id,
    required this.noteId,
    required this.content,
    required this.done,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['content'] = Variable<String>(content);
    map['done'] = Variable<bool>(done);
    map['position'] = Variable<int>(position);
    return map;
  }

  ChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      content: Value(content),
      done: Value(done),
      position: Value(position),
    );
  }

  factory ChecklistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItem(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      content: serializer.fromJson<String>(json['content']),
      done: serializer.fromJson<bool>(json['done']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'content': serializer.toJson<String>(content),
      'done': serializer.toJson<bool>(done),
      'position': serializer.toJson<int>(position),
    };
  }

  ChecklistItem copyWith({
    int? id,
    int? noteId,
    String? content,
    bool? done,
    int? position,
  }) => ChecklistItem(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    content: content ?? this.content,
    done: done ?? this.done,
    position: position ?? this.position,
  );
  ChecklistItem copyWithCompanion(ChecklistItemsCompanion data) {
    return ChecklistItem(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      content: data.content.present ? data.content.value : this.content,
      done: data.done.present ? data.done.value : this.done,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItem(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, content, done, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItem &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.content == this.content &&
          other.done == this.done &&
          other.position == this.position);
}

class ChecklistItemsCompanion extends UpdateCompanion<ChecklistItem> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<String> content;
  final Value<bool> done;
  final Value<int> position;
  const ChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.content = const Value.absent(),
    this.done = const Value.absent(),
    this.position = const Value.absent(),
  });
  ChecklistItemsCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required String content,
    this.done = const Value.absent(),
    this.position = const Value.absent(),
  }) : noteId = Value(noteId),
       content = Value(content);
  static Insertable<ChecklistItem> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<String>? content,
    Expression<bool>? done,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (content != null) 'content': content,
      if (done != null) 'done': done,
      if (position != null) 'position': position,
    });
  }

  ChecklistItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<String>? content,
    Value<bool>? done,
    Value<int>? position,
  }) {
    return ChecklistItemsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      content: content ?? this.content,
      done: done ?? this.done,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _weeklyDaysMeta = const VerificationMeta(
    'weeklyDays',
  );
  @override
  late final GeneratedColumn<int> weeklyDays = GeneratedColumn<int>(
    'weekly_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _timesPerWeekMeta = const VerificationMeta(
    'timesPerWeek',
  );
  @override
  late final GeneratedColumn<int> timesPerWeek = GeneratedColumn<int>(
    'times_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<DateTime> anchor = GeneratedColumn<DateTime>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    colorId,
    kind,
    weeklyDays,
    timesPerWeek,
    intervalDays,
    anchor,
    reminderMinutes,
    score,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('weekly_days')) {
      context.handle(
        _weeklyDaysMeta,
        weeklyDays.isAcceptableOrUnknown(data['weekly_days']!, _weeklyDaysMeta),
      );
    }
    if (data.containsKey('times_per_week')) {
      context.handle(
        _timesPerWeekMeta,
        timesPerWeek.isAcceptableOrUnknown(
          data['times_per_week']!,
          _timesPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
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
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      weeklyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_days'],
      )!,
      timesPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_week'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}anchor'],
      )!,
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String description;
  final int colorId;
  final String kind;
  final int weeklyDays;
  final int timesPerWeek;
  final int intervalDays;
  final DateTime anchor;
  final int? reminderMinutes;
  final double score;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.colorId,
    required this.kind,
    required this.weeklyDays,
    required this.timesPerWeek,
    required this.intervalDays,
    required this.anchor,
    this.reminderMinutes,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['color_id'] = Variable<int>(colorId);
    map['kind'] = Variable<String>(kind);
    map['weekly_days'] = Variable<int>(weeklyDays);
    map['times_per_week'] = Variable<int>(timesPerWeek);
    map['interval_days'] = Variable<int>(intervalDays);
    map['anchor'] = Variable<DateTime>(anchor);
    if (!nullToAbsent || reminderMinutes != null) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes);
    }
    map['score'] = Variable<double>(score);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      colorId: Value(colorId),
      kind: Value(kind),
      weeklyDays: Value(weeklyDays),
      timesPerWeek: Value(timesPerWeek),
      intervalDays: Value(intervalDays),
      anchor: Value(anchor),
      reminderMinutes: reminderMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutes),
      score: Value(score),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      colorId: serializer.fromJson<int>(json['colorId']),
      kind: serializer.fromJson<String>(json['kind']),
      weeklyDays: serializer.fromJson<int>(json['weeklyDays']),
      timesPerWeek: serializer.fromJson<int>(json['timesPerWeek']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      anchor: serializer.fromJson<DateTime>(json['anchor']),
      reminderMinutes: serializer.fromJson<int?>(json['reminderMinutes']),
      score: serializer.fromJson<double>(json['score']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'colorId': serializer.toJson<int>(colorId),
      'kind': serializer.toJson<String>(kind),
      'weeklyDays': serializer.toJson<int>(weeklyDays),
      'timesPerWeek': serializer.toJson<int>(timesPerWeek),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'anchor': serializer.toJson<DateTime>(anchor),
      'reminderMinutes': serializer.toJson<int?>(reminderMinutes),
      'score': serializer.toJson<double>(score),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    int? colorId,
    String? kind,
    int? weeklyDays,
    int? timesPerWeek,
    int? intervalDays,
    DateTime? anchor,
    Value<int?> reminderMinutes = const Value.absent(),
    double? score,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    colorId: colorId ?? this.colorId,
    kind: kind ?? this.kind,
    weeklyDays: weeklyDays ?? this.weeklyDays,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    intervalDays: intervalDays ?? this.intervalDays,
    anchor: anchor ?? this.anchor,
    reminderMinutes: reminderMinutes.present
        ? reminderMinutes.value
        : this.reminderMinutes,
    score: score ?? this.score,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      kind: data.kind.present ? data.kind.value : this.kind,
      weeklyDays: data.weeklyDays.present
          ? data.weeklyDays.value
          : this.weeklyDays,
      timesPerWeek: data.timesPerWeek.present
          ? data.timesPerWeek.value
          : this.timesPerWeek,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
      score: data.score.present ? data.score.value : this.score,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorId: $colorId, ')
          ..write('kind: $kind, ')
          ..write('weeklyDays: $weeklyDays, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('anchor: $anchor, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    colorId,
    kind,
    weeklyDays,
    timesPerWeek,
    intervalDays,
    anchor,
    reminderMinutes,
    score,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.colorId == this.colorId &&
          other.kind == this.kind &&
          other.weeklyDays == this.weeklyDays &&
          other.timesPerWeek == this.timesPerWeek &&
          other.intervalDays == this.intervalDays &&
          other.anchor == this.anchor &&
          other.reminderMinutes == this.reminderMinutes &&
          other.score == this.score &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> colorId;
  final Value<String> kind;
  final Value<int> weeklyDays;
  final Value<int> timesPerWeek;
  final Value<int> intervalDays;
  final Value<DateTime> anchor;
  final Value<int?> reminderMinutes;
  final Value<double> score;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.colorId = const Value.absent(),
    this.kind = const Value.absent(),
    this.weeklyDays = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.anchor = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.score = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.colorId = const Value.absent(),
    this.kind = const Value.absent(),
    this.weeklyDays = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.anchor = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.score = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? colorId,
    Expression<String>? kind,
    Expression<int>? weeklyDays,
    Expression<int>? timesPerWeek,
    Expression<int>? intervalDays,
    Expression<DateTime>? anchor,
    Expression<int>? reminderMinutes,
    Expression<double>? score,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (colorId != null) 'color_id': colorId,
      if (kind != null) 'kind': kind,
      if (weeklyDays != null) 'weekly_days': weeklyDays,
      if (timesPerWeek != null) 'times_per_week': timesPerWeek,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (anchor != null) 'anchor': anchor,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (score != null) 'score': score,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? colorId,
    Value<String>? kind,
    Value<int>? weeklyDays,
    Value<int>? timesPerWeek,
    Value<int>? intervalDays,
    Value<DateTime>? anchor,
    Value<int?>? reminderMinutes,
    Value<double>? score,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorId: colorId ?? this.colorId,
      kind: kind ?? this.kind,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      anchor: anchor ?? this.anchor,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (weeklyDays.present) {
      map['weekly_days'] = Variable<int>(weeklyDays.value);
    }
    if (timesPerWeek.present) {
      map['times_per_week'] = Variable<int>(timesPerWeek.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<DateTime>(anchor.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorId: $colorId, ')
          ..write('kind: $kind, ')
          ..write('weeklyDays: $weeklyDays, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('anchor: $anchor, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HabitChecksTable extends HabitChecks
    with TableInfo<$HabitChecksTable, HabitCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, day, done, skipped];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, day};
  @override
  HabitCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCheck(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $HabitChecksTable createAlias(String alias) {
    return $HabitChecksTable(attachedDatabase, alias);
  }
}

class HabitCheck extends DataClass implements Insertable<HabitCheck> {
  final int habitId;
  final DateTime day;
  final bool done;
  final bool skipped;
  const HabitCheck({
    required this.habitId,
    required this.day,
    required this.done,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<int>(habitId);
    map['day'] = Variable<DateTime>(day);
    map['done'] = Variable<bool>(done);
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  HabitChecksCompanion toCompanion(bool nullToAbsent) {
    return HabitChecksCompanion(
      habitId: Value(habitId),
      day: Value(day),
      done: Value(done),
      skipped: Value(skipped),
    );
  }

  factory HabitCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCheck(
      habitId: serializer.fromJson<int>(json['habitId']),
      day: serializer.fromJson<DateTime>(json['day']),
      done: serializer.fromJson<bool>(json['done']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<int>(habitId),
      'day': serializer.toJson<DateTime>(day),
      'done': serializer.toJson<bool>(done),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  HabitCheck copyWith({
    int? habitId,
    DateTime? day,
    bool? done,
    bool? skipped,
  }) => HabitCheck(
    habitId: habitId ?? this.habitId,
    day: day ?? this.day,
    done: done ?? this.done,
    skipped: skipped ?? this.skipped,
  );
  HabitCheck copyWithCompanion(HabitChecksCompanion data) {
    return HabitCheck(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      day: data.day.present ? data.day.value : this.day,
      done: data.done.present ? data.done.value : this.done,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCheck(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('done: $done, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, day, done, skipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCheck &&
          other.habitId == this.habitId &&
          other.day == this.day &&
          other.done == this.done &&
          other.skipped == this.skipped);
}

class HabitChecksCompanion extends UpdateCompanion<HabitCheck> {
  final Value<int> habitId;
  final Value<DateTime> day;
  final Value<bool> done;
  final Value<bool> skipped;
  final Value<int> rowid;
  const HabitChecksCompanion({
    this.habitId = const Value.absent(),
    this.day = const Value.absent(),
    this.done = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitChecksCompanion.insert({
    required int habitId,
    required DateTime day,
    this.done = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       day = Value(day);
  static Insertable<HabitCheck> custom({
    Expression<int>? habitId,
    Expression<DateTime>? day,
    Expression<bool>? done,
    Expression<bool>? skipped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (day != null) 'day': day,
      if (done != null) 'done': done,
      if (skipped != null) 'skipped': skipped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitChecksCompanion copyWith({
    Value<int>? habitId,
    Value<DateTime>? day,
    Value<bool>? done,
    Value<bool>? skipped,
    Value<int>? rowid,
  }) {
    return HabitChecksCompanion(
      habitId: habitId ?? this.habitId,
      day: day ?? this.day,
      done: done ?? this.done,
      skipped: skipped ?? this.skipped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitChecksCompanion(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('done: $done, ')
          ..write('skipped: $skipped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashDecksTable extends FlashDecks
    with TableInfo<$FlashDecksTable, FlashDeck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashDecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flash_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashDeck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  FlashDeck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashDeck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FlashDecksTable createAlias(String alias) {
    return $FlashDecksTable(attachedDatabase, alias);
  }
}

class FlashDeck extends DataClass implements Insertable<FlashDeck> {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FlashDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FlashDecksCompanion toCompanion(bool nullToAbsent) {
    return FlashDecksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FlashDeck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashDeck(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FlashDeck copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FlashDeck(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FlashDeck copyWithCompanion(FlashDecksCompanion data) {
    return FlashDeck(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashDeck(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashDeck &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FlashDecksCompanion extends UpdateCompanion<FlashDeck> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FlashDecksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FlashDecksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<FlashDeck> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FlashDecksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FlashDecksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashDecksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FlashCardsTable extends FlashCards
    with TableInfo<$FlashCardsTable, FlashCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashCardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageTermMeta = const VerificationMeta(
    'imageTerm',
  );
  @override
  late final GeneratedColumn<String> imageTerm = GeneratedColumn<String>(
    'image_term',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageDefMeta = const VerificationMeta(
    'imageDef',
  );
  @override
  late final GeneratedColumn<String> imageDef = GeneratedColumn<String>(
    'image_def',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('basic'),
  );
  static const VerificationMeta _highlightsMeta = const VerificationMeta(
    'highlights',
  );
  @override
  late final GeneratedColumn<String> highlights = GeneratedColumn<String>(
    'highlights',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _answerIndexMeta = const VerificationMeta(
    'answerIndex',
  );
  @override
  late final GeneratedColumn<int> answerIndex = GeneratedColumn<int>(
    'answer_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
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
    deckId,
    term,
    definition,
    imageTerm,
    imageDef,
    position,
    type,
    highlights,
    options,
    answerIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flash_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('image_term')) {
      context.handle(
        _imageTermMeta,
        imageTerm.isAcceptableOrUnknown(data['image_term']!, _imageTermMeta),
      );
    }
    if (data.containsKey('image_def')) {
      context.handle(
        _imageDefMeta,
        imageDef.isAcceptableOrUnknown(data['image_def']!, _imageDefMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('highlights')) {
      context.handle(
        _highlightsMeta,
        highlights.isAcceptableOrUnknown(data['highlights']!, _highlightsMeta),
      );
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('answer_index')) {
      context.handle(
        _answerIndexMeta,
        answerIndex.isAcceptableOrUnknown(
          data['answer_index']!,
          _answerIndexMeta,
        ),
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
  FlashCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      imageTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_term'],
      ),
      imageDef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_def'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      highlights: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlights'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      )!,
      answerIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answer_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FlashCardsTable createAlias(String alias) {
    return $FlashCardsTable(attachedDatabase, alias);
  }
}

class FlashCard extends DataClass implements Insertable<FlashCard> {
  final int id;
  final int deckId;
  final String term;
  final String definition;
  final String? imageTerm;
  final String? imageDef;
  final int position;
  final String type;
  final String highlights;
  final String options;
  final int answerIndex;
  final DateTime createdAt;
  const FlashCard({
    required this.id,
    required this.deckId,
    required this.term,
    required this.definition,
    this.imageTerm,
    this.imageDef,
    required this.position,
    required this.type,
    required this.highlights,
    required this.options,
    required this.answerIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['term'] = Variable<String>(term);
    map['definition'] = Variable<String>(definition);
    if (!nullToAbsent || imageTerm != null) {
      map['image_term'] = Variable<String>(imageTerm);
    }
    if (!nullToAbsent || imageDef != null) {
      map['image_def'] = Variable<String>(imageDef);
    }
    map['position'] = Variable<int>(position);
    map['type'] = Variable<String>(type);
    map['highlights'] = Variable<String>(highlights);
    map['options'] = Variable<String>(options);
    map['answer_index'] = Variable<int>(answerIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FlashCardsCompanion toCompanion(bool nullToAbsent) {
    return FlashCardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      term: Value(term),
      definition: Value(definition),
      imageTerm: imageTerm == null && nullToAbsent
          ? const Value.absent()
          : Value(imageTerm),
      imageDef: imageDef == null && nullToAbsent
          ? const Value.absent()
          : Value(imageDef),
      position: Value(position),
      type: Value(type),
      highlights: Value(highlights),
      options: Value(options),
      answerIndex: Value(answerIndex),
      createdAt: Value(createdAt),
    );
  }

  factory FlashCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashCard(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      term: serializer.fromJson<String>(json['term']),
      definition: serializer.fromJson<String>(json['definition']),
      imageTerm: serializer.fromJson<String?>(json['imageTerm']),
      imageDef: serializer.fromJson<String?>(json['imageDef']),
      position: serializer.fromJson<int>(json['position']),
      type: serializer.fromJson<String>(json['type']),
      highlights: serializer.fromJson<String>(json['highlights']),
      options: serializer.fromJson<String>(json['options']),
      answerIndex: serializer.fromJson<int>(json['answerIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'term': serializer.toJson<String>(term),
      'definition': serializer.toJson<String>(definition),
      'imageTerm': serializer.toJson<String?>(imageTerm),
      'imageDef': serializer.toJson<String?>(imageDef),
      'position': serializer.toJson<int>(position),
      'type': serializer.toJson<String>(type),
      'highlights': serializer.toJson<String>(highlights),
      'options': serializer.toJson<String>(options),
      'answerIndex': serializer.toJson<int>(answerIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FlashCard copyWith({
    int? id,
    int? deckId,
    String? term,
    String? definition,
    Value<String?> imageTerm = const Value.absent(),
    Value<String?> imageDef = const Value.absent(),
    int? position,
    String? type,
    String? highlights,
    String? options,
    int? answerIndex,
    DateTime? createdAt,
  }) => FlashCard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    term: term ?? this.term,
    definition: definition ?? this.definition,
    imageTerm: imageTerm.present ? imageTerm.value : this.imageTerm,
    imageDef: imageDef.present ? imageDef.value : this.imageDef,
    position: position ?? this.position,
    type: type ?? this.type,
    highlights: highlights ?? this.highlights,
    options: options ?? this.options,
    answerIndex: answerIndex ?? this.answerIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  FlashCard copyWithCompanion(FlashCardsCompanion data) {
    return FlashCard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      term: data.term.present ? data.term.value : this.term,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      imageTerm: data.imageTerm.present ? data.imageTerm.value : this.imageTerm,
      imageDef: data.imageDef.present ? data.imageDef.value : this.imageDef,
      position: data.position.present ? data.position.value : this.position,
      type: data.type.present ? data.type.value : this.type,
      highlights: data.highlights.present
          ? data.highlights.value
          : this.highlights,
      options: data.options.present ? data.options.value : this.options,
      answerIndex: data.answerIndex.present
          ? data.answerIndex.value
          : this.answerIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashCard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('imageTerm: $imageTerm, ')
          ..write('imageDef: $imageDef, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('highlights: $highlights, ')
          ..write('options: $options, ')
          ..write('answerIndex: $answerIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    term,
    definition,
    imageTerm,
    imageDef,
    position,
    type,
    highlights,
    options,
    answerIndex,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashCard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.term == this.term &&
          other.definition == this.definition &&
          other.imageTerm == this.imageTerm &&
          other.imageDef == this.imageDef &&
          other.position == this.position &&
          other.type == this.type &&
          other.highlights == this.highlights &&
          other.options == this.options &&
          other.answerIndex == this.answerIndex &&
          other.createdAt == this.createdAt);
}

class FlashCardsCompanion extends UpdateCompanion<FlashCard> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> term;
  final Value<String> definition;
  final Value<String?> imageTerm;
  final Value<String?> imageDef;
  final Value<int> position;
  final Value<String> type;
  final Value<String> highlights;
  final Value<String> options;
  final Value<int> answerIndex;
  final Value<DateTime> createdAt;
  const FlashCardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.term = const Value.absent(),
    this.definition = const Value.absent(),
    this.imageTerm = const Value.absent(),
    this.imageDef = const Value.absent(),
    this.position = const Value.absent(),
    this.type = const Value.absent(),
    this.highlights = const Value.absent(),
    this.options = const Value.absent(),
    this.answerIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FlashCardsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String term,
    required String definition,
    this.imageTerm = const Value.absent(),
    this.imageDef = const Value.absent(),
    this.position = const Value.absent(),
    this.type = const Value.absent(),
    this.highlights = const Value.absent(),
    this.options = const Value.absent(),
    this.answerIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : deckId = Value(deckId),
       term = Value(term),
       definition = Value(definition);
  static Insertable<FlashCard> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? term,
    Expression<String>? definition,
    Expression<String>? imageTerm,
    Expression<String>? imageDef,
    Expression<int>? position,
    Expression<String>? type,
    Expression<String>? highlights,
    Expression<String>? options,
    Expression<int>? answerIndex,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (term != null) 'term': term,
      if (definition != null) 'definition': definition,
      if (imageTerm != null) 'image_term': imageTerm,
      if (imageDef != null) 'image_def': imageDef,
      if (position != null) 'position': position,
      if (type != null) 'type': type,
      if (highlights != null) 'highlights': highlights,
      if (options != null) 'options': options,
      if (answerIndex != null) 'answer_index': answerIndex,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FlashCardsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<String>? term,
    Value<String>? definition,
    Value<String?>? imageTerm,
    Value<String?>? imageDef,
    Value<int>? position,
    Value<String>? type,
    Value<String>? highlights,
    Value<String>? options,
    Value<int>? answerIndex,
    Value<DateTime>? createdAt,
  }) {
    return FlashCardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      imageTerm: imageTerm ?? this.imageTerm,
      imageDef: imageDef ?? this.imageDef,
      position: position ?? this.position,
      type: type ?? this.type,
      highlights: highlights ?? this.highlights,
      options: options ?? this.options,
      answerIndex: answerIndex ?? this.answerIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (imageTerm.present) {
      map['image_term'] = Variable<String>(imageTerm.value);
    }
    if (imageDef.present) {
      map['image_def'] = Variable<String>(imageDef.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (highlights.present) {
      map['highlights'] = Variable<String>(highlights.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (answerIndex.present) {
      map['answer_index'] = Variable<int>(answerIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashCardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('imageTerm: $imageTerm, ')
          ..write('imageDef: $imageDef, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('highlights: $highlights, ')
          ..write('options: $options, ')
          ..write('answerIndex: $answerIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StudyBoardsTable extends StudyBoards
    with TableInfo<$StudyBoardsTable, StudyBoard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyBoardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Study Space'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_boards';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyBoard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
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
  StudyBoard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyBoard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StudyBoardsTable createAlias(String alias) {
    return $StudyBoardsTable(attachedDatabase, alias);
  }
}

class StudyBoard extends DataClass implements Insertable<StudyBoard> {
  final int id;
  final String title;
  final DateTime updatedAt;
  const StudyBoard({
    required this.id,
    required this.title,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudyBoardsCompanion toCompanion(bool nullToAbsent) {
    return StudyBoardsCompanion(
      id: Value(id),
      title: Value(title),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudyBoard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyBoard(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudyBoard copyWith({int? id, String? title, DateTime? updatedAt}) =>
      StudyBoard(
        id: id ?? this.id,
        title: title ?? this.title,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StudyBoard copyWithCompanion(StudyBoardsCompanion data) {
    return StudyBoard(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyBoard(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyBoard &&
          other.id == this.id &&
          other.title == this.title &&
          other.updatedAt == this.updatedAt);
}

class StudyBoardsCompanion extends UpdateCompanion<StudyBoard> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> updatedAt;
  const StudyBoardsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StudyBoardsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<StudyBoard> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StudyBoardsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? updatedAt,
  }) {
    return StudyBoardsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyBoardsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BoardWidgetsTable extends BoardWidgets
    with TableInfo<$BoardWidgetsTable, BoardWidget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardWidgetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<int> boardId = GeneratedColumn<int>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _wMeta = const VerificationMeta('w');
  @override
  late final GeneratedColumn<double> w = GeneratedColumn<double>(
    'w',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(320),
  );
  static const VerificationMeta _hMeta = const VerificationMeta('h');
  @override
  late final GeneratedColumn<double> h = GeneratedColumn<double>(
    'h',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(220),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _zMeta = const VerificationMeta('z');
  @override
  late final GeneratedColumn<int> z = GeneratedColumn<int>(
    'z',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardId,
    type,
    x,
    y,
    w,
    h,
    payloadJson,
    z,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_widgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardWidget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    if (data.containsKey('w')) {
      context.handle(_wMeta, w.isAcceptableOrUnknown(data['w']!, _wMeta));
    }
    if (data.containsKey('h')) {
      context.handle(_hMeta, h.isAcceptableOrUnknown(data['h']!, _hMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('z')) {
      context.handle(_zMeta, z.isAcceptableOrUnknown(data['z']!, _zMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoardWidget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardWidget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      w: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}w'],
      )!,
      h: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}h'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      z: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}z'],
      )!,
    );
  }

  @override
  $BoardWidgetsTable createAlias(String alias) {
    return $BoardWidgetsTable(attachedDatabase, alias);
  }
}

class BoardWidget extends DataClass implements Insertable<BoardWidget> {
  final int id;
  final int boardId;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final String payloadJson;
  final int z;
  const BoardWidget({
    required this.id,
    required this.boardId,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.payloadJson,
    required this.z,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['board_id'] = Variable<int>(boardId);
    map['type'] = Variable<String>(type);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['w'] = Variable<double>(w);
    map['h'] = Variable<double>(h);
    map['payload_json'] = Variable<String>(payloadJson);
    map['z'] = Variable<int>(z);
    return map;
  }

  BoardWidgetsCompanion toCompanion(bool nullToAbsent) {
    return BoardWidgetsCompanion(
      id: Value(id),
      boardId: Value(boardId),
      type: Value(type),
      x: Value(x),
      y: Value(y),
      w: Value(w),
      h: Value(h),
      payloadJson: Value(payloadJson),
      z: Value(z),
    );
  }

  factory BoardWidget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardWidget(
      id: serializer.fromJson<int>(json['id']),
      boardId: serializer.fromJson<int>(json['boardId']),
      type: serializer.fromJson<String>(json['type']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      w: serializer.fromJson<double>(json['w']),
      h: serializer.fromJson<double>(json['h']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      z: serializer.fromJson<int>(json['z']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boardId': serializer.toJson<int>(boardId),
      'type': serializer.toJson<String>(type),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'w': serializer.toJson<double>(w),
      'h': serializer.toJson<double>(h),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'z': serializer.toJson<int>(z),
    };
  }

  BoardWidget copyWith({
    int? id,
    int? boardId,
    String? type,
    double? x,
    double? y,
    double? w,
    double? h,
    String? payloadJson,
    int? z,
  }) => BoardWidget(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    type: type ?? this.type,
    x: x ?? this.x,
    y: y ?? this.y,
    w: w ?? this.w,
    h: h ?? this.h,
    payloadJson: payloadJson ?? this.payloadJson,
    z: z ?? this.z,
  );
  BoardWidget copyWithCompanion(BoardWidgetsCompanion data) {
    return BoardWidget(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      type: data.type.present ? data.type.value : this.type,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      w: data.w.present ? data.w.value : this.w,
      h: data.h.present ? data.h.value : this.h,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      z: data.z.present ? data.z.value : this.z,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardWidget(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('type: $type, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('w: $w, ')
          ..write('h: $h, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('z: $z')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, boardId, type, x, y, w, h, payloadJson, z);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardWidget &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.type == this.type &&
          other.x == this.x &&
          other.y == this.y &&
          other.w == this.w &&
          other.h == this.h &&
          other.payloadJson == this.payloadJson &&
          other.z == this.z);
}

class BoardWidgetsCompanion extends UpdateCompanion<BoardWidget> {
  final Value<int> id;
  final Value<int> boardId;
  final Value<String> type;
  final Value<double> x;
  final Value<double> y;
  final Value<double> w;
  final Value<double> h;
  final Value<String> payloadJson;
  final Value<int> z;
  const BoardWidgetsCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.type = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.w = const Value.absent(),
    this.h = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.z = const Value.absent(),
  });
  BoardWidgetsCompanion.insert({
    this.id = const Value.absent(),
    required int boardId,
    required String type,
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.w = const Value.absent(),
    this.h = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.z = const Value.absent(),
  }) : boardId = Value(boardId),
       type = Value(type);
  static Insertable<BoardWidget> custom({
    Expression<int>? id,
    Expression<int>? boardId,
    Expression<String>? type,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? w,
    Expression<double>? h,
    Expression<String>? payloadJson,
    Expression<int>? z,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (type != null) 'type': type,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (w != null) 'w': w,
      if (h != null) 'h': h,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (z != null) 'z': z,
    });
  }

  BoardWidgetsCompanion copyWith({
    Value<int>? id,
    Value<int>? boardId,
    Value<String>? type,
    Value<double>? x,
    Value<double>? y,
    Value<double>? w,
    Value<double>? h,
    Value<String>? payloadJson,
    Value<int>? z,
  }) {
    return BoardWidgetsCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      payloadJson: payloadJson ?? this.payloadJson,
      z: z ?? this.z,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<int>(boardId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (w.present) {
      map['w'] = Variable<double>(w.value);
    }
    if (h.present) {
      map['h'] = Variable<double>(h.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (z.present) {
      map['z'] = Variable<int>(z.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardWidgetsCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('type: $type, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('w: $w, ')
          ..write('h: $h, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('z: $z')
          ..write(')'))
        .toString();
  }
}

class $BoardStrokesTable extends BoardStrokes
    with TableInfo<$BoardStrokesTable, BoardStroke> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardStrokesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<int> boardId = GeneratedColumn<int>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolMeta = const VerificationMeta('tool');
  @override
  late final GeneratedColumn<String> tool = GeneratedColumn<String>(
    'tool',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsJsonMeta = const VerificationMeta(
    'pointsJson',
  );
  @override
  late final GeneratedColumn<String> pointsJson = GeneratedColumn<String>(
    'points_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opacityMeta = const VerificationMeta(
    'opacity',
  );
  @override
  late final GeneratedColumn<double> opacity = GeneratedColumn<double>(
    'opacity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardId,
    tool,
    pointsJson,
    color,
    width,
    opacity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_strokes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardStroke> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('tool')) {
      context.handle(
        _toolMeta,
        tool.isAcceptableOrUnknown(data['tool']!, _toolMeta),
      );
    } else if (isInserting) {
      context.missing(_toolMeta);
    }
    if (data.containsKey('points_json')) {
      context.handle(
        _pointsJsonMeta,
        pointsJson.isAcceptableOrUnknown(data['points_json']!, _pointsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsJsonMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('opacity')) {
      context.handle(
        _opacityMeta,
        opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoardStroke map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardStroke(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_id'],
      )!,
      tool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool'],
      )!,
      pointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}points_json'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      opacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opacity'],
      )!,
    );
  }

  @override
  $BoardStrokesTable createAlias(String alias) {
    return $BoardStrokesTable(attachedDatabase, alias);
  }
}

class BoardStroke extends DataClass implements Insertable<BoardStroke> {
  final int id;
  final int boardId;
  final String tool;
  final String pointsJson;
  final String color;
  final double width;
  final double opacity;
  const BoardStroke({
    required this.id,
    required this.boardId,
    required this.tool,
    required this.pointsJson,
    required this.color,
    required this.width,
    required this.opacity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['board_id'] = Variable<int>(boardId);
    map['tool'] = Variable<String>(tool);
    map['points_json'] = Variable<String>(pointsJson);
    map['color'] = Variable<String>(color);
    map['width'] = Variable<double>(width);
    map['opacity'] = Variable<double>(opacity);
    return map;
  }

  BoardStrokesCompanion toCompanion(bool nullToAbsent) {
    return BoardStrokesCompanion(
      id: Value(id),
      boardId: Value(boardId),
      tool: Value(tool),
      pointsJson: Value(pointsJson),
      color: Value(color),
      width: Value(width),
      opacity: Value(opacity),
    );
  }

  factory BoardStroke.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardStroke(
      id: serializer.fromJson<int>(json['id']),
      boardId: serializer.fromJson<int>(json['boardId']),
      tool: serializer.fromJson<String>(json['tool']),
      pointsJson: serializer.fromJson<String>(json['pointsJson']),
      color: serializer.fromJson<String>(json['color']),
      width: serializer.fromJson<double>(json['width']),
      opacity: serializer.fromJson<double>(json['opacity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boardId': serializer.toJson<int>(boardId),
      'tool': serializer.toJson<String>(tool),
      'pointsJson': serializer.toJson<String>(pointsJson),
      'color': serializer.toJson<String>(color),
      'width': serializer.toJson<double>(width),
      'opacity': serializer.toJson<double>(opacity),
    };
  }

  BoardStroke copyWith({
    int? id,
    int? boardId,
    String? tool,
    String? pointsJson,
    String? color,
    double? width,
    double? opacity,
  }) => BoardStroke(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    tool: tool ?? this.tool,
    pointsJson: pointsJson ?? this.pointsJson,
    color: color ?? this.color,
    width: width ?? this.width,
    opacity: opacity ?? this.opacity,
  );
  BoardStroke copyWithCompanion(BoardStrokesCompanion data) {
    return BoardStroke(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      tool: data.tool.present ? data.tool.value : this.tool,
      pointsJson: data.pointsJson.present
          ? data.pointsJson.value
          : this.pointsJson,
      color: data.color.present ? data.color.value : this.color,
      width: data.width.present ? data.width.value : this.width,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardStroke(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('tool: $tool, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('color: $color, ')
          ..write('width: $width, ')
          ..write('opacity: $opacity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, boardId, tool, pointsJson, color, width, opacity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardStroke &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.tool == this.tool &&
          other.pointsJson == this.pointsJson &&
          other.color == this.color &&
          other.width == this.width &&
          other.opacity == this.opacity);
}

class BoardStrokesCompanion extends UpdateCompanion<BoardStroke> {
  final Value<int> id;
  final Value<int> boardId;
  final Value<String> tool;
  final Value<String> pointsJson;
  final Value<String> color;
  final Value<double> width;
  final Value<double> opacity;
  const BoardStrokesCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.tool = const Value.absent(),
    this.pointsJson = const Value.absent(),
    this.color = const Value.absent(),
    this.width = const Value.absent(),
    this.opacity = const Value.absent(),
  });
  BoardStrokesCompanion.insert({
    this.id = const Value.absent(),
    required int boardId,
    required String tool,
    required String pointsJson,
    required String color,
    required double width,
    this.opacity = const Value.absent(),
  }) : boardId = Value(boardId),
       tool = Value(tool),
       pointsJson = Value(pointsJson),
       color = Value(color),
       width = Value(width);
  static Insertable<BoardStroke> custom({
    Expression<int>? id,
    Expression<int>? boardId,
    Expression<String>? tool,
    Expression<String>? pointsJson,
    Expression<String>? color,
    Expression<double>? width,
    Expression<double>? opacity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (tool != null) 'tool': tool,
      if (pointsJson != null) 'points_json': pointsJson,
      if (color != null) 'color': color,
      if (width != null) 'width': width,
      if (opacity != null) 'opacity': opacity,
    });
  }

  BoardStrokesCompanion copyWith({
    Value<int>? id,
    Value<int>? boardId,
    Value<String>? tool,
    Value<String>? pointsJson,
    Value<String>? color,
    Value<double>? width,
    Value<double>? opacity,
  }) {
    return BoardStrokesCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      tool: tool ?? this.tool,
      pointsJson: pointsJson ?? this.pointsJson,
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<int>(boardId.value);
    }
    if (tool.present) {
      map['tool'] = Variable<String>(tool.value);
    }
    if (pointsJson.present) {
      map['points_json'] = Variable<String>(pointsJson.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<double>(opacity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardStrokesCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('tool: $tool, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('color: $color, ')
          ..write('width: $width, ')
          ..write('opacity: $opacity')
          ..write(')'))
        .toString();
  }
}

class $BoardShapesTable extends BoardShapes
    with TableInfo<$BoardShapesTable, BoardShape> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardShapesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<int> boardId = GeneratedColumn<int>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wMeta = const VerificationMeta('w');
  @override
  late final GeneratedColumn<double> w = GeneratedColumn<double>(
    'w',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hMeta = const VerificationMeta('h');
  @override
  late final GeneratedColumn<double> h = GeneratedColumn<double>(
    'h',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _styleJsonMeta = const VerificationMeta(
    'styleJson',
  );
  @override
  late final GeneratedColumn<String> styleJson = GeneratedColumn<String>(
    'style_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardId,
    kind,
    x,
    y,
    w,
    h,
    label,
    styleJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_shapes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardShape> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('w')) {
      context.handle(_wMeta, w.isAcceptableOrUnknown(data['w']!, _wMeta));
    } else if (isInserting) {
      context.missing(_wMeta);
    }
    if (data.containsKey('h')) {
      context.handle(_hMeta, h.isAcceptableOrUnknown(data['h']!, _hMeta));
    } else if (isInserting) {
      context.missing(_hMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('style_json')) {
      context.handle(
        _styleJsonMeta,
        styleJson.isAcceptableOrUnknown(data['style_json']!, _styleJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoardShape map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardShape(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      w: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}w'],
      )!,
      h: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}h'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      styleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_json'],
      )!,
    );
  }

  @override
  $BoardShapesTable createAlias(String alias) {
    return $BoardShapesTable(attachedDatabase, alias);
  }
}

class BoardShape extends DataClass implements Insertable<BoardShape> {
  final int id;
  final int boardId;
  final String kind;
  final double x;
  final double y;
  final double w;
  final double h;
  final String label;
  final String styleJson;
  const BoardShape({
    required this.id,
    required this.boardId,
    required this.kind,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.label,
    required this.styleJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['board_id'] = Variable<int>(boardId);
    map['kind'] = Variable<String>(kind);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['w'] = Variable<double>(w);
    map['h'] = Variable<double>(h);
    map['label'] = Variable<String>(label);
    map['style_json'] = Variable<String>(styleJson);
    return map;
  }

  BoardShapesCompanion toCompanion(bool nullToAbsent) {
    return BoardShapesCompanion(
      id: Value(id),
      boardId: Value(boardId),
      kind: Value(kind),
      x: Value(x),
      y: Value(y),
      w: Value(w),
      h: Value(h),
      label: Value(label),
      styleJson: Value(styleJson),
    );
  }

  factory BoardShape.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardShape(
      id: serializer.fromJson<int>(json['id']),
      boardId: serializer.fromJson<int>(json['boardId']),
      kind: serializer.fromJson<String>(json['kind']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      w: serializer.fromJson<double>(json['w']),
      h: serializer.fromJson<double>(json['h']),
      label: serializer.fromJson<String>(json['label']),
      styleJson: serializer.fromJson<String>(json['styleJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boardId': serializer.toJson<int>(boardId),
      'kind': serializer.toJson<String>(kind),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'w': serializer.toJson<double>(w),
      'h': serializer.toJson<double>(h),
      'label': serializer.toJson<String>(label),
      'styleJson': serializer.toJson<String>(styleJson),
    };
  }

  BoardShape copyWith({
    int? id,
    int? boardId,
    String? kind,
    double? x,
    double? y,
    double? w,
    double? h,
    String? label,
    String? styleJson,
  }) => BoardShape(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    kind: kind ?? this.kind,
    x: x ?? this.x,
    y: y ?? this.y,
    w: w ?? this.w,
    h: h ?? this.h,
    label: label ?? this.label,
    styleJson: styleJson ?? this.styleJson,
  );
  BoardShape copyWithCompanion(BoardShapesCompanion data) {
    return BoardShape(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      kind: data.kind.present ? data.kind.value : this.kind,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      w: data.w.present ? data.w.value : this.w,
      h: data.h.present ? data.h.value : this.h,
      label: data.label.present ? data.label.value : this.label,
      styleJson: data.styleJson.present ? data.styleJson.value : this.styleJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardShape(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('kind: $kind, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('w: $w, ')
          ..write('h: $h, ')
          ..write('label: $label, ')
          ..write('styleJson: $styleJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, boardId, kind, x, y, w, h, label, styleJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardShape &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.kind == this.kind &&
          other.x == this.x &&
          other.y == this.y &&
          other.w == this.w &&
          other.h == this.h &&
          other.label == this.label &&
          other.styleJson == this.styleJson);
}

class BoardShapesCompanion extends UpdateCompanion<BoardShape> {
  final Value<int> id;
  final Value<int> boardId;
  final Value<String> kind;
  final Value<double> x;
  final Value<double> y;
  final Value<double> w;
  final Value<double> h;
  final Value<String> label;
  final Value<String> styleJson;
  const BoardShapesCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.kind = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.w = const Value.absent(),
    this.h = const Value.absent(),
    this.label = const Value.absent(),
    this.styleJson = const Value.absent(),
  });
  BoardShapesCompanion.insert({
    this.id = const Value.absent(),
    required int boardId,
    required String kind,
    required double x,
    required double y,
    required double w,
    required double h,
    this.label = const Value.absent(),
    this.styleJson = const Value.absent(),
  }) : boardId = Value(boardId),
       kind = Value(kind),
       x = Value(x),
       y = Value(y),
       w = Value(w),
       h = Value(h);
  static Insertable<BoardShape> custom({
    Expression<int>? id,
    Expression<int>? boardId,
    Expression<String>? kind,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? w,
    Expression<double>? h,
    Expression<String>? label,
    Expression<String>? styleJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (kind != null) 'kind': kind,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (w != null) 'w': w,
      if (h != null) 'h': h,
      if (label != null) 'label': label,
      if (styleJson != null) 'style_json': styleJson,
    });
  }

  BoardShapesCompanion copyWith({
    Value<int>? id,
    Value<int>? boardId,
    Value<String>? kind,
    Value<double>? x,
    Value<double>? y,
    Value<double>? w,
    Value<double>? h,
    Value<String>? label,
    Value<String>? styleJson,
  }) {
    return BoardShapesCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      kind: kind ?? this.kind,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      label: label ?? this.label,
      styleJson: styleJson ?? this.styleJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<int>(boardId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (w.present) {
      map['w'] = Variable<double>(w.value);
    }
    if (h.present) {
      map['h'] = Variable<double>(h.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (styleJson.present) {
      map['style_json'] = Variable<String>(styleJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardShapesCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('kind: $kind, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('w: $w, ')
          ..write('h: $h, ')
          ..write('label: $label, ')
          ..write('styleJson: $styleJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskListsTable taskLists = $TaskListsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $CalendarFeedsTable calendarFeeds = $CalendarFeedsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $NoteLabelsTable noteLabels = $NoteLabelsTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitChecksTable habitChecks = $HabitChecksTable(this);
  late final $FlashDecksTable flashDecks = $FlashDecksTable(this);
  late final $FlashCardsTable flashCards = $FlashCardsTable(this);
  late final $StudyBoardsTable studyBoards = $StudyBoardsTable(this);
  late final $BoardWidgetsTable boardWidgets = $BoardWidgetsTable(this);
  late final $BoardStrokesTable boardStrokes = $BoardStrokesTable(this);
  late final $BoardShapesTable boardShapes = $BoardShapesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    taskLists,
    outboxOps,
    events,
    calendarFeeds,
    notes,
    labels,
    noteLabels,
    checklistItems,
    habits,
    habitChecks,
    flashDecks,
    flashCards,
    studyBoards,
    boardWidgets,
    boardStrokes,
    boardShapes,
  ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> notes,
  Value<String> project,
  Value<int> priority,
  Value<bool> done,
  Value<DateTime?> dueAt,
  Value<int> listId,
  Value<int?> parentId,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<bool> dirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> notes,
  Value<String> project,
  Value<int> priority,
  Value<bool> done,
  Value<DateTime?> dueAt,
  Value<int> listId,
  Value<int?> parentId,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<bool> dirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
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

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
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

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get project =>
      $composableBuilder(column: $table.project, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> project = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                project: project,
                priority: priority,
                done: done,
                dueAt: dueAt,
                listId: listId,
                parentId: parentId,
                deletedAt: deletedAt,
                version: version,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String> project = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                project: project,
                priority: priority,
                done: done,
                dueAt: dueAt,
                listId: listId,
                parentId: parentId,
                deletedAt: deletedAt,
                version: version,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskListsTableCreateCompanionBuilder = TaskListsCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$TaskListsTableUpdateCompanionBuilder = TaskListsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

class $$TaskListsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskListsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaskListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskListsTable,
          TaskList,
          $$TaskListsTableFilterComposer,
          $$TaskListsTableOrderingComposer,
          $$TaskListsTableAnnotationComposer,
          $$TaskListsTableCreateCompanionBuilder,
          $$TaskListsTableUpdateCompanionBuilder,
          (TaskList, BaseReferences<_$AppDatabase, $TaskListsTable, TaskList>),
          TaskList,
          PrefetchHooks Function()
        > {
  $$TaskListsTableTableManager(_$AppDatabase db, $TaskListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => TaskListsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskListsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskListsTable, TaskList>(table),
                  BaseReferences<_$AppDatabase, $TaskListsTable, TaskList>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskListsTable,
      TaskList,
      $$TaskListsTableFilterComposer,
      $$TaskListsTableOrderingComposer,
      $$TaskListsTableAnnotationComposer,
      $$TaskListsTableCreateCompanionBuilder,
      $$TaskListsTableUpdateCompanionBuilder,
      (TaskList, BaseReferences<_$AppDatabase, $TaskListsTable, TaskList>),
      TaskList,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> id,
  required String kind,
  required int entityId,
  required String op,
  Value<String> payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<int> entityId,
  Value<String> op,
  Value<String> payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
});

class $$OutboxOpsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxOp,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (OutboxOp, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxOp>),
          OutboxOp,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxOpsCompanion(
                id: id,
                kind: kind,
                entityId: entityId,
                op: op,
                payloadJson: payloadJson,
                attempts: attempts,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required int entityId,
                required String op,
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxOpsCompanion.insert(
                id: id,
                kind: kind,
                entityId: entityId,
                op: op,
                payloadJson: payloadJson,
                attempts: attempts,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxOp>(table),
                  BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxOp>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxOp,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxOp, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxOp>),
      OutboxOp,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  Value<String?> location,
  required DateTime start,
  required DateTime end,
  Value<bool> allDay,
  Value<int> colorId,
  Value<int> feedId,
  Value<String> uid,
  Value<String> guests,
  Value<bool> busy,
  Value<String> visibility,
  Value<String> reminders,
  Value<int> guestFlags,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<bool> dirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<String?> location,
  Value<DateTime> start,
  Value<DateTime> end,
  Value<bool> allDay,
  Value<int> colorId,
  Value<int> feedId,
  Value<String> uid,
  Value<String> guests,
  Value<bool> busy,
  Value<String> visibility,
  Value<String> reminders,
  Value<int> guestFlags,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<bool> dirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get busy => $composableBuilder(
    column: $table.busy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminders => $composableBuilder(
    column: $table.reminders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guestFlags => $composableBuilder(
    column: $table.guestFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
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

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get busy => $composableBuilder(
    column: $table.busy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminders => $composableBuilder(
    column: $table.reminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guestFlags => $composableBuilder(
    column: $table.guestFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
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

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<bool> get allDay =>
      $composableBuilder(column: $table.allDay, builder: (column) => column);

  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<int> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<bool> get busy =>
      $composableBuilder(column: $table.busy, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => column);

  GeneratedColumn<int> get guestFlags => $composableBuilder(
    column: $table.guestFlags,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> start = const Value.absent(),
                Value<DateTime> end = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<int> feedId = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<bool> busy = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<String> reminders = const Value.absent(),
                Value<int> guestFlags = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                title: title,
                description: description,
                location: location,
                start: start,
                end: end,
                allDay: allDay,
                colorId: colorId,
                feedId: feedId,
                uid: uid,
                guests: guests,
                busy: busy,
                visibility: visibility,
                reminders: reminders,
                guestFlags: guestFlags,
                deletedAt: deletedAt,
                version: version,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime start,
                required DateTime end,
                Value<bool> allDay = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<int> feedId = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<bool> busy = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<String> reminders = const Value.absent(),
                Value<int> guestFlags = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                title: title,
                description: description,
                location: location,
                start: start,
                end: end,
                allDay: allDay,
                colorId: colorId,
                feedId: feedId,
                uid: uid,
                guests: guests,
                busy: busy,
                visibility: visibility,
                reminders: reminders,
                guestFlags: guestFlags,
                deletedAt: deletedAt,
                version: version,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, Event>(table),
                  BaseReferences<_$AppDatabase, $EventsTable, Event>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;
typedef $$CalendarFeedsTableCreateCompanionBuilder =
    CalendarFeedsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> url,
      Value<int> colorId,
      Value<bool> enabled,
      Value<DateTime?> lastSyncAt,
      Value<DateTime> createdAt,
    });
typedef $$CalendarFeedsTableUpdateCompanionBuilder =
    CalendarFeedsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> url,
      Value<int> colorId,
      Value<bool> enabled,
      Value<DateTime?> lastSyncAt,
      Value<DateTime> createdAt,
    });

class $$CalendarFeedsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarFeedsTable> {
  $$CalendarFeedsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarFeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarFeedsTable> {
  $$CalendarFeedsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarFeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarFeedsTable> {
  $$CalendarFeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CalendarFeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarFeedsTable,
          CalendarFeed,
          $$CalendarFeedsTableFilterComposer,
          $$CalendarFeedsTableOrderingComposer,
          $$CalendarFeedsTableAnnotationComposer,
          $$CalendarFeedsTableCreateCompanionBuilder,
          $$CalendarFeedsTableUpdateCompanionBuilder,
          (
            CalendarFeed,
            BaseReferences<_$AppDatabase, $CalendarFeedsTable, CalendarFeed>,
          ),
          CalendarFeed,
          PrefetchHooks Function()
        > {
  $$CalendarFeedsTableTableManager(_$AppDatabase db, $CalendarFeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarFeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarFeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarFeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CalendarFeedsCompanion(
                id: id,
                name: name,
                url: url,
                colorId: colorId,
                enabled: enabled,
                lastSyncAt: lastSyncAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> url = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CalendarFeedsCompanion.insert(
                id: id,
                name: name,
                url: url,
                colorId: colorId,
                enabled: enabled,
                lastSyncAt: lastSyncAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarFeedsTable, CalendarFeed>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CalendarFeedsTable,
                    CalendarFeed
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarFeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarFeedsTable,
      CalendarFeed,
      $$CalendarFeedsTableFilterComposer,
      $$CalendarFeedsTableOrderingComposer,
      $$CalendarFeedsTableAnnotationComposer,
      $$CalendarFeedsTableCreateCompanionBuilder,
      $$CalendarFeedsTableUpdateCompanionBuilder,
      (
        CalendarFeed,
        BaseReferences<_$AppDatabase, $CalendarFeedsTable, CalendarFeed>,
      ),
      CalendarFeed,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> body,
  Value<int> colorId,
  Value<bool> pinned,
  Value<bool> archived,
  Value<bool> trashed,
  Value<DateTime?> trashedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> body,
  Value<int> colorId,
  Value<bool> pinned,
  Value<bool> archived,
  Value<bool> trashed,
  Value<DateTime?> trashedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trashed => $composableBuilder(
    column: $table.trashed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trashedAt => $composableBuilder(
    column: $table.trashedAt,
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

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trashed => $composableBuilder(
    column: $table.trashed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trashedAt => $composableBuilder(
    column: $table.trashedAt,
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

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<bool> get trashed =>
      $composableBuilder(column: $table.trashed, builder: (column) => column);

  GeneratedColumn<DateTime> get trashedAt =>
      $composableBuilder(column: $table.trashedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> trashed = const Value.absent(),
                Value<DateTime?> trashedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                body: body,
                colorId: colorId,
                pinned: pinned,
                archived: archived,
                trashed: trashed,
                trashedAt: trashedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> trashed = const Value.absent(),
                Value<DateTime?> trashedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                body: body,
                colorId: colorId,
                pinned: pinned,
                archived: archived,
                trashed: trashed,
                trashedAt: trashedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  BaseReferences<_$AppDatabase, $NotesTable, Note>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$LabelsTableCreateCompanionBuilder = LabelsCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$LabelsTableUpdateCompanionBuilder = LabelsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

class $$LabelsTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTable,
          Label,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (Label, BaseReferences<_$AppDatabase, $LabelsTable, Label>),
          Label,
          PrefetchHooks Function()
        > {
  $$LabelsTableTableManager(_$AppDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => LabelsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => LabelsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LabelsTable, Label>(table),
                  BaseReferences<_$AppDatabase, $LabelsTable, Label>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTable,
      Label,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (Label, BaseReferences<_$AppDatabase, $LabelsTable, Label>),
      Label,
      PrefetchHooks Function()
    >;
typedef $$NoteLabelsTableCreateCompanionBuilder = NoteLabelsCompanion Function({
  required int noteId,
  required int labelId,
  Value<int> rowid,
});
typedef $$NoteLabelsTableUpdateCompanionBuilder = NoteLabelsCompanion Function({
  Value<int> noteId,
  Value<int> labelId,
  Value<int> rowid,
});

class $$NoteLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteLabelsTable> {
  $$NoteLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteLabelsTable> {
  $$NoteLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteLabelsTable> {
  $$NoteLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);
}

class $$NoteLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteLabelsTable,
          NoteLabel,
          $$NoteLabelsTableFilterComposer,
          $$NoteLabelsTableOrderingComposer,
          $$NoteLabelsTableAnnotationComposer,
          $$NoteLabelsTableCreateCompanionBuilder,
          $$NoteLabelsTableUpdateCompanionBuilder,
          (
            NoteLabel,
            BaseReferences<_$AppDatabase, $NoteLabelsTable, NoteLabel>,
          ),
          NoteLabel,
          PrefetchHooks Function()
        > {
  $$NoteLabelsTableTableManager(_$AppDatabase db, $NoteLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> noteId = const Value.absent(),
                Value<int> labelId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteLabelsCompanion(
                noteId: noteId,
                labelId: labelId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int noteId,
                required int labelId,
                Value<int> rowid = const Value.absent(),
              }) => NoteLabelsCompanion.insert(
                noteId: noteId,
                labelId: labelId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteLabelsTable, NoteLabel>(table),
                  BaseReferences<_$AppDatabase, $NoteLabelsTable, NoteLabel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteLabelsTable,
      NoteLabel,
      $$NoteLabelsTableFilterComposer,
      $$NoteLabelsTableOrderingComposer,
      $$NoteLabelsTableAnnotationComposer,
      $$NoteLabelsTableCreateCompanionBuilder,
      $$NoteLabelsTableUpdateCompanionBuilder,
      (NoteLabel, BaseReferences<_$AppDatabase, $NoteLabelsTable, NoteLabel>),
      NoteLabel,
      PrefetchHooks Function()
    >;
typedef $$ChecklistItemsTableCreateCompanionBuilder =
    ChecklistItemsCompanion Function({
      Value<int> id,
      required int noteId,
      required String content,
      Value<bool> done,
      Value<int> position,
    });
typedef $$ChecklistItemsTableUpdateCompanionBuilder =
    ChecklistItemsCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<String> content,
      Value<bool> done,
      Value<int> position,
    });

class $$ChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableFilterComposer({
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

  ColumnFilters<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableOrderingComposer({
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

  ColumnOrderings<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$ChecklistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChecklistItemsTable,
          ChecklistItem,
          $$ChecklistItemsTableFilterComposer,
          $$ChecklistItemsTableOrderingComposer,
          $$ChecklistItemsTableAnnotationComposer,
          $$ChecklistItemsTableCreateCompanionBuilder,
          $$ChecklistItemsTableUpdateCompanionBuilder,
          (
            ChecklistItem,
            BaseReferences<_$AppDatabase, $ChecklistItemsTable, ChecklistItem>,
          ),
          ChecklistItem,
          PrefetchHooks Function()
        > {
  $$ChecklistItemsTableTableManager(
    _$AppDatabase db,
    $ChecklistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ChecklistItemsCompanion(
                id: id,
                noteId: noteId,
                content: content,
                done: done,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required String content,
                Value<bool> done = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ChecklistItemsCompanion.insert(
                id: id,
                noteId: noteId,
                content: content,
                done: done,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChecklistItemsTable, ChecklistItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChecklistItemsTable,
                    ChecklistItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChecklistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChecklistItemsTable,
      ChecklistItem,
      $$ChecklistItemsTableFilterComposer,
      $$ChecklistItemsTableOrderingComposer,
      $$ChecklistItemsTableAnnotationComposer,
      $$ChecklistItemsTableCreateCompanionBuilder,
      $$ChecklistItemsTableUpdateCompanionBuilder,
      (
        ChecklistItem,
        BaseReferences<_$AppDatabase, $ChecklistItemsTable, ChecklistItem>,
      ),
      ChecklistItem,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> description,
  Value<int> colorId,
  Value<String> kind,
  Value<int> weeklyDays,
  Value<int> timesPerWeek,
  Value<int> intervalDays,
  Value<DateTime> anchor,
  Value<int?> reminderMinutes,
  Value<double> score,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> description,
  Value<int> colorId,
  Value<String> kind,
  Value<int> weeklyDays,
  Value<int> timesPerWeek,
  Value<int> intervalDays,
  Value<DateTime> anchor,
  Value<int?> reminderMinutes,
  Value<double> score,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyDays => $composableBuilder(
    column: $table.weeklyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
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

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyDays => $composableBuilder(
    column: $table.weeklyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
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

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get weeklyDays => $composableBuilder(
    column: $table.weeklyDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> weeklyDays = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime> anchor = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                description: description,
                colorId: colorId,
                kind: kind,
                weeklyDays: weeklyDays,
                timesPerWeek: timesPerWeek,
                intervalDays: intervalDays,
                anchor: anchor,
                reminderMinutes: reminderMinutes,
                score: score,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> weeklyDays = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime> anchor = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                description: description,
                colorId: colorId,
                kind: kind,
                weeklyDays: weeklyDays,
                timesPerWeek: timesPerWeek,
                intervalDays: intervalDays,
                anchor: anchor,
                reminderMinutes: reminderMinutes,
                score: score,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  BaseReferences<_$AppDatabase, $HabitsTable, Habit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitChecksTableCreateCompanionBuilder =
    HabitChecksCompanion Function({
      required int habitId,
      required DateTime day,
      Value<bool> done,
      Value<bool> skipped,
      Value<int> rowid,
    });
typedef $$HabitChecksTableUpdateCompanionBuilder =
    HabitChecksCompanion Function({
      Value<int> habitId,
      Value<DateTime> day,
      Value<bool> done,
      Value<bool> skipped,
      Value<int> rowid,
    });

class $$HabitChecksTableFilterComposer
    extends Composer<_$AppDatabase, $HabitChecksTable> {
  $$HabitChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitChecksTable> {
  $$HabitChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitChecksTable> {
  $$HabitChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);
}

class $$HabitChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitChecksTable,
          HabitCheck,
          $$HabitChecksTableFilterComposer,
          $$HabitChecksTableOrderingComposer,
          $$HabitChecksTableAnnotationComposer,
          $$HabitChecksTableCreateCompanionBuilder,
          $$HabitChecksTableUpdateCompanionBuilder,
          (
            HabitCheck,
            BaseReferences<_$AppDatabase, $HabitChecksTable, HabitCheck>,
          ),
          HabitCheck,
          PrefetchHooks Function()
        > {
  $$HabitChecksTableTableManager(_$AppDatabase db, $HabitChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> habitId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitChecksCompanion(
                habitId: habitId,
                day: day,
                done: done,
                skipped: skipped,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int habitId,
                required DateTime day,
                Value<bool> done = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitChecksCompanion.insert(
                habitId: habitId,
                day: day,
                done: done,
                skipped: skipped,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitChecksTable, HabitCheck>(table),
                  BaseReferences<_$AppDatabase, $HabitChecksTable, HabitCheck>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitChecksTable,
      HabitCheck,
      $$HabitChecksTableFilterComposer,
      $$HabitChecksTableOrderingComposer,
      $$HabitChecksTableAnnotationComposer,
      $$HabitChecksTableCreateCompanionBuilder,
      $$HabitChecksTableUpdateCompanionBuilder,
      (
        HabitCheck,
        BaseReferences<_$AppDatabase, $HabitChecksTable, HabitCheck>,
      ),
      HabitCheck,
      PrefetchHooks Function()
    >;
typedef $$FlashDecksTableCreateCompanionBuilder = FlashDecksCompanion Function({
  Value<int> id,
  required String title,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$FlashDecksTableUpdateCompanionBuilder = FlashDecksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FlashDecksTableFilterComposer
    extends Composer<_$AppDatabase, $FlashDecksTable> {
  $$FlashDecksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
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

class $$FlashDecksTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashDecksTable> {
  $$FlashDecksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
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

class $$FlashDecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashDecksTable> {
  $$FlashDecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlashDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashDecksTable,
          FlashDeck,
          $$FlashDecksTableFilterComposer,
          $$FlashDecksTableOrderingComposer,
          $$FlashDecksTableAnnotationComposer,
          $$FlashDecksTableCreateCompanionBuilder,
          $$FlashDecksTableUpdateCompanionBuilder,
          (
            FlashDeck,
            BaseReferences<_$AppDatabase, $FlashDecksTable, FlashDeck>,
          ),
          FlashDeck,
          PrefetchHooks Function()
        > {
  $$FlashDecksTableTableManager(_$AppDatabase db, $FlashDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FlashDecksCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FlashDecksCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlashDecksTable, FlashDeck>(table),
                  BaseReferences<_$AppDatabase, $FlashDecksTable, FlashDeck>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashDecksTable,
      FlashDeck,
      $$FlashDecksTableFilterComposer,
      $$FlashDecksTableOrderingComposer,
      $$FlashDecksTableAnnotationComposer,
      $$FlashDecksTableCreateCompanionBuilder,
      $$FlashDecksTableUpdateCompanionBuilder,
      (FlashDeck, BaseReferences<_$AppDatabase, $FlashDecksTable, FlashDeck>),
      FlashDeck,
      PrefetchHooks Function()
    >;
typedef $$FlashCardsTableCreateCompanionBuilder = FlashCardsCompanion Function({
  Value<int> id,
  required int deckId,
  required String term,
  required String definition,
  Value<String?> imageTerm,
  Value<String?> imageDef,
  Value<int> position,
  Value<String> type,
  Value<String> highlights,
  Value<String> options,
  Value<int> answerIndex,
  Value<DateTime> createdAt,
});
typedef $$FlashCardsTableUpdateCompanionBuilder = FlashCardsCompanion Function({
  Value<int> id,
  Value<int> deckId,
  Value<String> term,
  Value<String> definition,
  Value<String?> imageTerm,
  Value<String?> imageDef,
  Value<int> position,
  Value<String> type,
  Value<String> highlights,
  Value<String> options,
  Value<int> answerIndex,
  Value<DateTime> createdAt,
});

class $$FlashCardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashCardsTable> {
  $$FlashCardsTableFilterComposer({
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

  ColumnFilters<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageTerm => $composableBuilder(
    column: $table.imageTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageDef => $composableBuilder(
    column: $table.imageDef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get highlights => $composableBuilder(
    column: $table.highlights,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answerIndex => $composableBuilder(
    column: $table.answerIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlashCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashCardsTable> {
  $$FlashCardsTableOrderingComposer({
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

  ColumnOrderings<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageTerm => $composableBuilder(
    column: $table.imageTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageDef => $composableBuilder(
    column: $table.imageDef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get highlights => $composableBuilder(
    column: $table.highlights,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answerIndex => $composableBuilder(
    column: $table.answerIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlashCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashCardsTable> {
  $$FlashCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageTerm =>
      $composableBuilder(column: $table.imageTerm, builder: (column) => column);

  GeneratedColumn<String> get imageDef =>
      $composableBuilder(column: $table.imageDef, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get highlights => $composableBuilder(
    column: $table.highlights,
    builder: (column) => column,
  );

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get answerIndex => $composableBuilder(
    column: $table.answerIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FlashCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashCardsTable,
          FlashCard,
          $$FlashCardsTableFilterComposer,
          $$FlashCardsTableOrderingComposer,
          $$FlashCardsTableAnnotationComposer,
          $$FlashCardsTableCreateCompanionBuilder,
          $$FlashCardsTableUpdateCompanionBuilder,
          (
            FlashCard,
            BaseReferences<_$AppDatabase, $FlashCardsTable, FlashCard>,
          ),
          FlashCard,
          PrefetchHooks Function()
        > {
  $$FlashCardsTableTableManager(_$AppDatabase db, $FlashCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> imageTerm = const Value.absent(),
                Value<String?> imageDef = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> highlights = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<int> answerIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FlashCardsCompanion(
                id: id,
                deckId: deckId,
                term: term,
                definition: definition,
                imageTerm: imageTerm,
                imageDef: imageDef,
                position: position,
                type: type,
                highlights: highlights,
                options: options,
                answerIndex: answerIndex,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required String term,
                required String definition,
                Value<String?> imageTerm = const Value.absent(),
                Value<String?> imageDef = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> highlights = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<int> answerIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FlashCardsCompanion.insert(
                id: id,
                deckId: deckId,
                term: term,
                definition: definition,
                imageTerm: imageTerm,
                imageDef: imageDef,
                position: position,
                type: type,
                highlights: highlights,
                options: options,
                answerIndex: answerIndex,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlashCardsTable, FlashCard>(table),
                  BaseReferences<_$AppDatabase, $FlashCardsTable, FlashCard>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashCardsTable,
      FlashCard,
      $$FlashCardsTableFilterComposer,
      $$FlashCardsTableOrderingComposer,
      $$FlashCardsTableAnnotationComposer,
      $$FlashCardsTableCreateCompanionBuilder,
      $$FlashCardsTableUpdateCompanionBuilder,
      (FlashCard, BaseReferences<_$AppDatabase, $FlashCardsTable, FlashCard>),
      FlashCard,
      PrefetchHooks Function()
    >;
typedef $$StudyBoardsTableCreateCompanionBuilder =
    StudyBoardsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> updatedAt,
    });
typedef $$StudyBoardsTableUpdateCompanionBuilder =
    StudyBoardsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> updatedAt,
    });

class $$StudyBoardsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyBoardsTable> {
  $$StudyBoardsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyBoardsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyBoardsTable> {
  $$StudyBoardsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyBoardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyBoardsTable> {
  $$StudyBoardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudyBoardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyBoardsTable,
          StudyBoard,
          $$StudyBoardsTableFilterComposer,
          $$StudyBoardsTableOrderingComposer,
          $$StudyBoardsTableAnnotationComposer,
          $$StudyBoardsTableCreateCompanionBuilder,
          $$StudyBoardsTableUpdateCompanionBuilder,
          (
            StudyBoard,
            BaseReferences<_$AppDatabase, $StudyBoardsTable, StudyBoard>,
          ),
          StudyBoard,
          PrefetchHooks Function()
        > {
  $$StudyBoardsTableTableManager(_$AppDatabase db, $StudyBoardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyBoardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyBoardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyBoardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StudyBoardsCompanion(
                id: id,
                title: title,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StudyBoardsCompanion.insert(
                id: id,
                title: title,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyBoardsTable, StudyBoard>(table),
                  BaseReferences<_$AppDatabase, $StudyBoardsTable, StudyBoard>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyBoardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyBoardsTable,
      StudyBoard,
      $$StudyBoardsTableFilterComposer,
      $$StudyBoardsTableOrderingComposer,
      $$StudyBoardsTableAnnotationComposer,
      $$StudyBoardsTableCreateCompanionBuilder,
      $$StudyBoardsTableUpdateCompanionBuilder,
      (
        StudyBoard,
        BaseReferences<_$AppDatabase, $StudyBoardsTable, StudyBoard>,
      ),
      StudyBoard,
      PrefetchHooks Function()
    >;
typedef $$BoardWidgetsTableCreateCompanionBuilder =
    BoardWidgetsCompanion Function({
      Value<int> id,
      required int boardId,
      required String type,
      Value<double> x,
      Value<double> y,
      Value<double> w,
      Value<double> h,
      Value<String> payloadJson,
      Value<int> z,
    });
typedef $$BoardWidgetsTableUpdateCompanionBuilder =
    BoardWidgetsCompanion Function({
      Value<int> id,
      Value<int> boardId,
      Value<String> type,
      Value<double> x,
      Value<double> y,
      Value<double> w,
      Value<double> h,
      Value<String> payloadJson,
      Value<int> z,
    });

class $$BoardWidgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardWidgetsTable> {
  $$BoardWidgetsTableFilterComposer({
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

  ColumnFilters<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get w => $composableBuilder(
    column: $table.w,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get h => $composableBuilder(
    column: $table.h,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardWidgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardWidgetsTable> {
  $$BoardWidgetsTableOrderingComposer({
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

  ColumnOrderings<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get w => $composableBuilder(
    column: $table.w,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get h => $composableBuilder(
    column: $table.h,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardWidgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardWidgetsTable> {
  $$BoardWidgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get w =>
      $composableBuilder(column: $table.w, builder: (column) => column);

  GeneratedColumn<double> get h =>
      $composableBuilder(column: $table.h, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get z =>
      $composableBuilder(column: $table.z, builder: (column) => column);
}

class $$BoardWidgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardWidgetsTable,
          BoardWidget,
          $$BoardWidgetsTableFilterComposer,
          $$BoardWidgetsTableOrderingComposer,
          $$BoardWidgetsTableAnnotationComposer,
          $$BoardWidgetsTableCreateCompanionBuilder,
          $$BoardWidgetsTableUpdateCompanionBuilder,
          (
            BoardWidget,
            BaseReferences<_$AppDatabase, $BoardWidgetsTable, BoardWidget>,
          ),
          BoardWidget,
          PrefetchHooks Function()
        > {
  $$BoardWidgetsTableTableManager(_$AppDatabase db, $BoardWidgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardWidgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardWidgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardWidgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> boardId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> w = const Value.absent(),
                Value<double> h = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> z = const Value.absent(),
              }) => BoardWidgetsCompanion(
                id: id,
                boardId: boardId,
                type: type,
                x: x,
                y: y,
                w: w,
                h: h,
                payloadJson: payloadJson,
                z: z,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int boardId,
                required String type,
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> w = const Value.absent(),
                Value<double> h = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> z = const Value.absent(),
              }) => BoardWidgetsCompanion.insert(
                id: id,
                boardId: boardId,
                type: type,
                x: x,
                y: y,
                w: w,
                h: h,
                payloadJson: payloadJson,
                z: z,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoardWidgetsTable, BoardWidget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BoardWidgetsTable,
                    BoardWidget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardWidgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardWidgetsTable,
      BoardWidget,
      $$BoardWidgetsTableFilterComposer,
      $$BoardWidgetsTableOrderingComposer,
      $$BoardWidgetsTableAnnotationComposer,
      $$BoardWidgetsTableCreateCompanionBuilder,
      $$BoardWidgetsTableUpdateCompanionBuilder,
      (
        BoardWidget,
        BaseReferences<_$AppDatabase, $BoardWidgetsTable, BoardWidget>,
      ),
      BoardWidget,
      PrefetchHooks Function()
    >;
typedef $$BoardStrokesTableCreateCompanionBuilder =
    BoardStrokesCompanion Function({
      Value<int> id,
      required int boardId,
      required String tool,
      required String pointsJson,
      required String color,
      required double width,
      Value<double> opacity,
    });
typedef $$BoardStrokesTableUpdateCompanionBuilder =
    BoardStrokesCompanion Function({
      Value<int> id,
      Value<int> boardId,
      Value<String> tool,
      Value<String> pointsJson,
      Value<String> color,
      Value<double> width,
      Value<double> opacity,
    });

class $$BoardStrokesTableFilterComposer
    extends Composer<_$AppDatabase, $BoardStrokesTable> {
  $$BoardStrokesTableFilterComposer({
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

  ColumnFilters<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tool => $composableBuilder(
    column: $table.tool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardStrokesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardStrokesTable> {
  $$BoardStrokesTableOrderingComposer({
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

  ColumnOrderings<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tool => $composableBuilder(
    column: $table.tool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardStrokesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardStrokesTable> {
  $$BoardStrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get tool =>
      $composableBuilder(column: $table.tool, builder: (column) => column);

  GeneratedColumn<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get opacity =>
      $composableBuilder(column: $table.opacity, builder: (column) => column);
}

class $$BoardStrokesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardStrokesTable,
          BoardStroke,
          $$BoardStrokesTableFilterComposer,
          $$BoardStrokesTableOrderingComposer,
          $$BoardStrokesTableAnnotationComposer,
          $$BoardStrokesTableCreateCompanionBuilder,
          $$BoardStrokesTableUpdateCompanionBuilder,
          (
            BoardStroke,
            BaseReferences<_$AppDatabase, $BoardStrokesTable, BoardStroke>,
          ),
          BoardStroke,
          PrefetchHooks Function()
        > {
  $$BoardStrokesTableTableManager(_$AppDatabase db, $BoardStrokesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardStrokesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardStrokesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardStrokesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> boardId = const Value.absent(),
                Value<String> tool = const Value.absent(),
                Value<String> pointsJson = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> opacity = const Value.absent(),
              }) => BoardStrokesCompanion(
                id: id,
                boardId: boardId,
                tool: tool,
                pointsJson: pointsJson,
                color: color,
                width: width,
                opacity: opacity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int boardId,
                required String tool,
                required String pointsJson,
                required String color,
                required double width,
                Value<double> opacity = const Value.absent(),
              }) => BoardStrokesCompanion.insert(
                id: id,
                boardId: boardId,
                tool: tool,
                pointsJson: pointsJson,
                color: color,
                width: width,
                opacity: opacity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoardStrokesTable, BoardStroke>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BoardStrokesTable,
                    BoardStroke
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardStrokesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardStrokesTable,
      BoardStroke,
      $$BoardStrokesTableFilterComposer,
      $$BoardStrokesTableOrderingComposer,
      $$BoardStrokesTableAnnotationComposer,
      $$BoardStrokesTableCreateCompanionBuilder,
      $$BoardStrokesTableUpdateCompanionBuilder,
      (
        BoardStroke,
        BaseReferences<_$AppDatabase, $BoardStrokesTable, BoardStroke>,
      ),
      BoardStroke,
      PrefetchHooks Function()
    >;
typedef $$BoardShapesTableCreateCompanionBuilder =
    BoardShapesCompanion Function({
      Value<int> id,
      required int boardId,
      required String kind,
      required double x,
      required double y,
      required double w,
      required double h,
      Value<String> label,
      Value<String> styleJson,
    });
typedef $$BoardShapesTableUpdateCompanionBuilder =
    BoardShapesCompanion Function({
      Value<int> id,
      Value<int> boardId,
      Value<String> kind,
      Value<double> x,
      Value<double> y,
      Value<double> w,
      Value<double> h,
      Value<String> label,
      Value<String> styleJson,
    });

class $$BoardShapesTableFilterComposer
    extends Composer<_$AppDatabase, $BoardShapesTable> {
  $$BoardShapesTableFilterComposer({
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

  ColumnFilters<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get w => $composableBuilder(
    column: $table.w,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get h => $composableBuilder(
    column: $table.h,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleJson => $composableBuilder(
    column: $table.styleJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardShapesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardShapesTable> {
  $$BoardShapesTableOrderingComposer({
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

  ColumnOrderings<int> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get w => $composableBuilder(
    column: $table.w,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get h => $composableBuilder(
    column: $table.h,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleJson => $composableBuilder(
    column: $table.styleJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardShapesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardShapesTable> {
  $$BoardShapesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get w =>
      $composableBuilder(column: $table.w, builder: (column) => column);

  GeneratedColumn<double> get h =>
      $composableBuilder(column: $table.h, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get styleJson =>
      $composableBuilder(column: $table.styleJson, builder: (column) => column);
}

class $$BoardShapesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardShapesTable,
          BoardShape,
          $$BoardShapesTableFilterComposer,
          $$BoardShapesTableOrderingComposer,
          $$BoardShapesTableAnnotationComposer,
          $$BoardShapesTableCreateCompanionBuilder,
          $$BoardShapesTableUpdateCompanionBuilder,
          (
            BoardShape,
            BaseReferences<_$AppDatabase, $BoardShapesTable, BoardShape>,
          ),
          BoardShape,
          PrefetchHooks Function()
        > {
  $$BoardShapesTableTableManager(_$AppDatabase db, $BoardShapesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardShapesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardShapesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardShapesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> boardId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> w = const Value.absent(),
                Value<double> h = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> styleJson = const Value.absent(),
              }) => BoardShapesCompanion(
                id: id,
                boardId: boardId,
                kind: kind,
                x: x,
                y: y,
                w: w,
                h: h,
                label: label,
                styleJson: styleJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int boardId,
                required String kind,
                required double x,
                required double y,
                required double w,
                required double h,
                Value<String> label = const Value.absent(),
                Value<String> styleJson = const Value.absent(),
              }) => BoardShapesCompanion.insert(
                id: id,
                boardId: boardId,
                kind: kind,
                x: x,
                y: y,
                w: w,
                h: h,
                label: label,
                styleJson: styleJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoardShapesTable, BoardShape>(table),
                  BaseReferences<_$AppDatabase, $BoardShapesTable, BoardShape>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardShapesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardShapesTable,
      BoardShape,
      $$BoardShapesTableFilterComposer,
      $$BoardShapesTableOrderingComposer,
      $$BoardShapesTableAnnotationComposer,
      $$BoardShapesTableCreateCompanionBuilder,
      $$BoardShapesTableUpdateCompanionBuilder,
      (
        BoardShape,
        BaseReferences<_$AppDatabase, $BoardShapesTable, BoardShape>,
      ),
      BoardShape,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskListsTableTableManager get taskLists =>
      $$TaskListsTableTableManager(_db, _db.taskLists);
  $$OutboxOpsTableTableManager get outboxOps =>
      $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$CalendarFeedsTableTableManager get calendarFeeds =>
      $$CalendarFeedsTableTableManager(_db, _db.calendarFeeds);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$NoteLabelsTableTableManager get noteLabels =>
      $$NoteLabelsTableTableManager(_db, _db.noteLabels);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(_db, _db.checklistItems);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitChecksTableTableManager get habitChecks =>
      $$HabitChecksTableTableManager(_db, _db.habitChecks);
  $$FlashDecksTableTableManager get flashDecks =>
      $$FlashDecksTableTableManager(_db, _db.flashDecks);
  $$FlashCardsTableTableManager get flashCards =>
      $$FlashCardsTableTableManager(_db, _db.flashCards);
  $$StudyBoardsTableTableManager get studyBoards =>
      $$StudyBoardsTableTableManager(_db, _db.studyBoards);
  $$BoardWidgetsTableTableManager get boardWidgets =>
      $$BoardWidgetsTableTableManager(_db, _db.boardWidgets);
  $$BoardStrokesTableTableManager get boardStrokes =>
      $$BoardStrokesTableTableManager(_db, _db.boardStrokes);
  $$BoardShapesTableTableManager get boardShapes =>
      $$BoardShapesTableTableManager(_db, _db.boardShapes);
}
