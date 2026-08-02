// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalSubjectsTable extends LocalSubjects
    with TableInfo<$LocalSubjectsTable, LocalSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionCountMeta =
      const VerificationMeta('questionCount');
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
      'question_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [serverId, code, name, questionCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_subjects';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSubject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('question_count')) {
      context.handle(
          _questionCountMeta,
          questionCount.isAcceptableOrUnknown(
              data['question_count']!, _questionCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  LocalSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubject(
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      questionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_count'])!,
    );
  }

  @override
  $LocalSubjectsTable createAlias(String alias) {
    return $LocalSubjectsTable(attachedDatabase, alias);
  }
}

class LocalSubject extends DataClass implements Insertable<LocalSubject> {
  final int serverId;
  final String code;
  final String name;
  final int questionCount;
  const LocalSubject(
      {required this.serverId,
      required this.code,
      required this.name,
      required this.questionCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<int>(serverId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['question_count'] = Variable<int>(questionCount);
    return map;
  }

  LocalSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalSubjectsCompanion(
      serverId: Value(serverId),
      code: Value(code),
      name: Value(name),
      questionCount: Value(questionCount),
    );
  }

  factory LocalSubject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubject(
      serverId: serializer.fromJson<int>(json['serverId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<int>(serverId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'questionCount': serializer.toJson<int>(questionCount),
    };
  }

  LocalSubject copyWith(
          {int? serverId, String? code, String? name, int? questionCount}) =>
      LocalSubject(
        serverId: serverId ?? this.serverId,
        code: code ?? this.code,
        name: name ?? this.name,
        questionCount: questionCount ?? this.questionCount,
      );
  LocalSubject copyWithCompanion(LocalSubjectsCompanion data) {
    return LocalSubject(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubject(')
          ..write('serverId: $serverId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('questionCount: $questionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serverId, code, name, questionCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSubject &&
          other.serverId == this.serverId &&
          other.code == this.code &&
          other.name == this.name &&
          other.questionCount == this.questionCount);
}

class LocalSubjectsCompanion extends UpdateCompanion<LocalSubject> {
  final Value<int> serverId;
  final Value<String> code;
  final Value<String> name;
  final Value<int> questionCount;
  const LocalSubjectsCompanion({
    this.serverId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.questionCount = const Value.absent(),
  });
  LocalSubjectsCompanion.insert({
    this.serverId = const Value.absent(),
    required String code,
    required String name,
    this.questionCount = const Value.absent(),
  })  : code = Value(code),
        name = Value(name);
  static Insertable<LocalSubject> custom({
    Expression<int>? serverId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? questionCount,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (questionCount != null) 'question_count': questionCount,
    });
  }

  LocalSubjectsCompanion copyWith(
      {Value<int>? serverId,
      Value<String>? code,
      Value<String>? name,
      Value<int>? questionCount}) {
    return LocalSubjectsCompanion(
      serverId: serverId ?? this.serverId,
      code: code ?? this.code,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubjectsCompanion(')
          ..write('serverId: $serverId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('questionCount: $questionCount')
          ..write(')'))
        .toString();
  }
}

class $LocalPackagesTable extends LocalPackages
    with TableInfo<$LocalPackagesTable, LocalPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta =
      const VerificationMeta('packageId');
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
      'package_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subjectCodeMeta =
      const VerificationMeta('subjectCode');
  @override
  late final GeneratedColumn<String> subjectCode = GeneratedColumn<String>(
      'subject_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _minimumAppVersionMeta =
      const VerificationMeta('minimumAppVersion');
  @override
  late final GeneratedColumn<String> minimumAppVersion =
      GeneratedColumn<String>('minimum_app_version', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _questionCountMeta =
      const VerificationMeta('questionCount');
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
      'question_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        packageId,
        subjectId,
        subjectCode,
        name,
        version,
        checksum,
        minimumAppVersion,
        updatedAt,
        sizeBytes,
        questionCount,
        downloadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_packages';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPackage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(_packageIdMeta,
          packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta));
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('subject_code')) {
      context.handle(
          _subjectCodeMeta,
          subjectCode.isAcceptableOrUnknown(
              data['subject_code']!, _subjectCodeMeta));
    } else if (isInserting) {
      context.missing(_subjectCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('minimum_app_version')) {
      context.handle(
          _minimumAppVersionMeta,
          minimumAppVersion.isAcceptableOrUnknown(
              data['minimum_app_version']!, _minimumAppVersionMeta));
    } else if (isInserting) {
      context.missing(_minimumAppVersionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('question_count')) {
      context.handle(
          _questionCountMeta,
          questionCount.isAcceptableOrUnknown(
              data['question_count']!, _questionCountMeta));
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId};
  @override
  LocalPackage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPackage(
      packageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      subjectCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum'])!,
      minimumAppVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}minimum_app_version'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      questionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_count'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at']),
    );
  }

  @override
  $LocalPackagesTable createAlias(String alias) {
    return $LocalPackagesTable(attachedDatabase, alias);
  }
}

class LocalPackage extends DataClass implements Insertable<LocalPackage> {
  final String packageId;
  final int subjectId;
  final String subjectCode;
  final String name;
  final int version;
  final String checksum;
  final String minimumAppVersion;
  final DateTime updatedAt;
  final int sizeBytes;
  final int questionCount;
  final DateTime? downloadedAt;
  const LocalPackage(
      {required this.packageId,
      required this.subjectId,
      required this.subjectCode,
      required this.name,
      required this.version,
      required this.checksum,
      required this.minimumAppVersion,
      required this.updatedAt,
      required this.sizeBytes,
      required this.questionCount,
      this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['subject_id'] = Variable<int>(subjectId);
    map['subject_code'] = Variable<String>(subjectCode);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['checksum'] = Variable<String>(checksum);
    map['minimum_app_version'] = Variable<String>(minimumAppVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['question_count'] = Variable<int>(questionCount);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    return map;
  }

  LocalPackagesCompanion toCompanion(bool nullToAbsent) {
    return LocalPackagesCompanion(
      packageId: Value(packageId),
      subjectId: Value(subjectId),
      subjectCode: Value(subjectCode),
      name: Value(name),
      version: Value(version),
      checksum: Value(checksum),
      minimumAppVersion: Value(minimumAppVersion),
      updatedAt: Value(updatedAt),
      sizeBytes: Value(sizeBytes),
      questionCount: Value(questionCount),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory LocalPackage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPackage(
      packageId: serializer.fromJson<String>(json['packageId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      subjectCode: serializer.fromJson<String>(json['subjectCode']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      checksum: serializer.fromJson<String>(json['checksum']),
      minimumAppVersion: serializer.fromJson<String>(json['minimumAppVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'subjectId': serializer.toJson<int>(subjectId),
      'subjectCode': serializer.toJson<String>(subjectCode),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'checksum': serializer.toJson<String>(checksum),
      'minimumAppVersion': serializer.toJson<String>(minimumAppVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'questionCount': serializer.toJson<int>(questionCount),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
    };
  }

  LocalPackage copyWith(
          {String? packageId,
          int? subjectId,
          String? subjectCode,
          String? name,
          int? version,
          String? checksum,
          String? minimumAppVersion,
          DateTime? updatedAt,
          int? sizeBytes,
          int? questionCount,
          Value<DateTime?> downloadedAt = const Value.absent()}) =>
      LocalPackage(
        packageId: packageId ?? this.packageId,
        subjectId: subjectId ?? this.subjectId,
        subjectCode: subjectCode ?? this.subjectCode,
        name: name ?? this.name,
        version: version ?? this.version,
        checksum: checksum ?? this.checksum,
        minimumAppVersion: minimumAppVersion ?? this.minimumAppVersion,
        updatedAt: updatedAt ?? this.updatedAt,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        questionCount: questionCount ?? this.questionCount,
        downloadedAt:
            downloadedAt.present ? downloadedAt.value : this.downloadedAt,
      );
  LocalPackage copyWithCompanion(LocalPackagesCompanion data) {
    return LocalPackage(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      subjectCode:
          data.subjectCode.present ? data.subjectCode.value : this.subjectCode,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      minimumAppVersion: data.minimumAppVersion.present
          ? data.minimumAppVersion.value
          : this.minimumAppVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPackage(')
          ..write('packageId: $packageId, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectCode: $subjectCode, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('minimumAppVersion: $minimumAppVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('questionCount: $questionCount, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      packageId,
      subjectId,
      subjectCode,
      name,
      version,
      checksum,
      minimumAppVersion,
      updatedAt,
      sizeBytes,
      questionCount,
      downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPackage &&
          other.packageId == this.packageId &&
          other.subjectId == this.subjectId &&
          other.subjectCode == this.subjectCode &&
          other.name == this.name &&
          other.version == this.version &&
          other.checksum == this.checksum &&
          other.minimumAppVersion == this.minimumAppVersion &&
          other.updatedAt == this.updatedAt &&
          other.sizeBytes == this.sizeBytes &&
          other.questionCount == this.questionCount &&
          other.downloadedAt == this.downloadedAt);
}

class LocalPackagesCompanion extends UpdateCompanion<LocalPackage> {
  final Value<String> packageId;
  final Value<int> subjectId;
  final Value<String> subjectCode;
  final Value<String> name;
  final Value<int> version;
  final Value<String> checksum;
  final Value<String> minimumAppVersion;
  final Value<DateTime> updatedAt;
  final Value<int> sizeBytes;
  final Value<int> questionCount;
  final Value<DateTime?> downloadedAt;
  final Value<int> rowid;
  const LocalPackagesCompanion({
    this.packageId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectCode = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.checksum = const Value.absent(),
    this.minimumAppVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPackagesCompanion.insert({
    required String packageId,
    required int subjectId,
    required String subjectCode,
    required String name,
    required int version,
    required String checksum,
    required String minimumAppVersion,
    required DateTime updatedAt,
    this.sizeBytes = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : packageId = Value(packageId),
        subjectId = Value(subjectId),
        subjectCode = Value(subjectCode),
        name = Value(name),
        version = Value(version),
        checksum = Value(checksum),
        minimumAppVersion = Value(minimumAppVersion),
        updatedAt = Value(updatedAt);
  static Insertable<LocalPackage> custom({
    Expression<String>? packageId,
    Expression<int>? subjectId,
    Expression<String>? subjectCode,
    Expression<String>? name,
    Expression<int>? version,
    Expression<String>? checksum,
    Expression<String>? minimumAppVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? sizeBytes,
    Expression<int>? questionCount,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectCode != null) 'subject_code': subjectCode,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (checksum != null) 'checksum': checksum,
      if (minimumAppVersion != null) 'minimum_app_version': minimumAppVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (questionCount != null) 'question_count': questionCount,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPackagesCompanion copyWith(
      {Value<String>? packageId,
      Value<int>? subjectId,
      Value<String>? subjectCode,
      Value<String>? name,
      Value<int>? version,
      Value<String>? checksum,
      Value<String>? minimumAppVersion,
      Value<DateTime>? updatedAt,
      Value<int>? sizeBytes,
      Value<int>? questionCount,
      Value<DateTime?>? downloadedAt,
      Value<int>? rowid}) {
    return LocalPackagesCompanion(
      packageId: packageId ?? this.packageId,
      subjectId: subjectId ?? this.subjectId,
      subjectCode: subjectCode ?? this.subjectCode,
      name: name ?? this.name,
      version: version ?? this.version,
      checksum: checksum ?? this.checksum,
      minimumAppVersion: minimumAppVersion ?? this.minimumAppVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      questionCount: questionCount ?? this.questionCount,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (subjectCode.present) {
      map['subject_code'] = Variable<String>(subjectCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (minimumAppVersion.present) {
      map['minimum_app_version'] = Variable<String>(minimumAppVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPackagesCompanion(')
          ..write('packageId: $packageId, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectCode: $subjectCode, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('minimumAppVersion: $minimumAppVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('questionCount: $questionCount, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuestionsTable extends LocalQuestions
    with TableInfo<$LocalQuestionsTable, LocalQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _packageIdMeta =
      const VerificationMeta('packageId');
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
      'package_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionTypeMeta =
      const VerificationMeta('questionType');
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
      'question_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _referenceTextMeta =
      const VerificationMeta('referenceText');
  @override
  late final GeneratedColumn<String> referenceText = GeneratedColumn<String>(
      'reference_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        packageId,
        code,
        content,
        questionType,
        categoryId,
        category,
        difficulty,
        topic,
        explanation,
        referenceText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_questions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_id')) {
      context.handle(_packageIdMeta,
          packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta));
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
          _questionTypeMeta,
          questionType.isAcceptableOrUnknown(
              data['question_type']!, _questionTypeMeta));
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    }
    if (data.containsKey('reference_text')) {
      context.handle(
          _referenceTextMeta,
          referenceText.isAcceptableOrUnknown(
              data['reference_text']!, _referenceTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      packageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      questionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_type'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      referenceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_text'])!,
    );
  }

  @override
  $LocalQuestionsTable createAlias(String alias) {
    return $LocalQuestionsTable(attachedDatabase, alias);
  }
}

class LocalQuestion extends DataClass implements Insertable<LocalQuestion> {
  final int id;
  final String packageId;
  final String code;
  final String content;
  final String questionType;
  final int? categoryId;
  final String category;
  final String difficulty;
  final String topic;
  final String explanation;
  final String referenceText;
  const LocalQuestion(
      {required this.id,
      required this.packageId,
      required this.code,
      required this.content,
      required this.questionType,
      this.categoryId,
      required this.category,
      required this.difficulty,
      required this.topic,
      required this.explanation,
      required this.referenceText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_id'] = Variable<String>(packageId);
    map['code'] = Variable<String>(code);
    map['content'] = Variable<String>(content);
    map['question_type'] = Variable<String>(questionType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<String>(difficulty);
    map['topic'] = Variable<String>(topic);
    map['explanation'] = Variable<String>(explanation);
    map['reference_text'] = Variable<String>(referenceText);
    return map;
  }

  LocalQuestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionsCompanion(
      id: Value(id),
      packageId: Value(packageId),
      code: Value(code),
      content: Value(content),
      questionType: Value(questionType),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      category: Value(category),
      difficulty: Value(difficulty),
      topic: Value(topic),
      explanation: Value(explanation),
      referenceText: Value(referenceText),
    );
  }

  factory LocalQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestion(
      id: serializer.fromJson<int>(json['id']),
      packageId: serializer.fromJson<String>(json['packageId']),
      code: serializer.fromJson<String>(json['code']),
      content: serializer.fromJson<String>(json['content']),
      questionType: serializer.fromJson<String>(json['questionType']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      topic: serializer.fromJson<String>(json['topic']),
      explanation: serializer.fromJson<String>(json['explanation']),
      referenceText: serializer.fromJson<String>(json['referenceText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageId': serializer.toJson<String>(packageId),
      'code': serializer.toJson<String>(code),
      'content': serializer.toJson<String>(content),
      'questionType': serializer.toJson<String>(questionType),
      'categoryId': serializer.toJson<int?>(categoryId),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<String>(difficulty),
      'topic': serializer.toJson<String>(topic),
      'explanation': serializer.toJson<String>(explanation),
      'referenceText': serializer.toJson<String>(referenceText),
    };
  }

  LocalQuestion copyWith(
          {int? id,
          String? packageId,
          String? code,
          String? content,
          String? questionType,
          Value<int?> categoryId = const Value.absent(),
          String? category,
          String? difficulty,
          String? topic,
          String? explanation,
          String? referenceText}) =>
      LocalQuestion(
        id: id ?? this.id,
        packageId: packageId ?? this.packageId,
        code: code ?? this.code,
        content: content ?? this.content,
        questionType: questionType ?? this.questionType,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        topic: topic ?? this.topic,
        explanation: explanation ?? this.explanation,
        referenceText: referenceText ?? this.referenceText,
      );
  LocalQuestion copyWithCompanion(LocalQuestionsCompanion data) {
    return LocalQuestion(
      id: data.id.present ? data.id.value : this.id,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      code: data.code.present ? data.code.value : this.code,
      content: data.content.present ? data.content.value : this.content,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      category: data.category.present ? data.category.value : this.category,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      topic: data.topic.present ? data.topic.value : this.topic,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      referenceText: data.referenceText.present
          ? data.referenceText.value
          : this.referenceText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestion(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('code: $code, ')
          ..write('content: $content, ')
          ..write('questionType: $questionType, ')
          ..write('categoryId: $categoryId, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('topic: $topic, ')
          ..write('explanation: $explanation, ')
          ..write('referenceText: $referenceText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packageId, code, content, questionType,
      categoryId, category, difficulty, topic, explanation, referenceText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestion &&
          other.id == this.id &&
          other.packageId == this.packageId &&
          other.code == this.code &&
          other.content == this.content &&
          other.questionType == this.questionType &&
          other.categoryId == this.categoryId &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.topic == this.topic &&
          other.explanation == this.explanation &&
          other.referenceText == this.referenceText);
}

class LocalQuestionsCompanion extends UpdateCompanion<LocalQuestion> {
  final Value<int> id;
  final Value<String> packageId;
  final Value<String> code;
  final Value<String> content;
  final Value<String> questionType;
  final Value<int?> categoryId;
  final Value<String> category;
  final Value<String> difficulty;
  final Value<String> topic;
  final Value<String> explanation;
  final Value<String> referenceText;
  const LocalQuestionsCompanion({
    this.id = const Value.absent(),
    this.packageId = const Value.absent(),
    this.code = const Value.absent(),
    this.content = const Value.absent(),
    this.questionType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.topic = const Value.absent(),
    this.explanation = const Value.absent(),
    this.referenceText = const Value.absent(),
  });
  LocalQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required String packageId,
    required String code,
    required String content,
    required String questionType,
    this.categoryId = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.topic = const Value.absent(),
    this.explanation = const Value.absent(),
    this.referenceText = const Value.absent(),
  })  : packageId = Value(packageId),
        code = Value(code),
        content = Value(content),
        questionType = Value(questionType);
  static Insertable<LocalQuestion> custom({
    Expression<int>? id,
    Expression<String>? packageId,
    Expression<String>? code,
    Expression<String>? content,
    Expression<String>? questionType,
    Expression<int>? categoryId,
    Expression<String>? category,
    Expression<String>? difficulty,
    Expression<String>? topic,
    Expression<String>? explanation,
    Expression<String>? referenceText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageId != null) 'package_id': packageId,
      if (code != null) 'code': code,
      if (content != null) 'content': content,
      if (questionType != null) 'question_type': questionType,
      if (categoryId != null) 'category_id': categoryId,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (topic != null) 'topic': topic,
      if (explanation != null) 'explanation': explanation,
      if (referenceText != null) 'reference_text': referenceText,
    });
  }

  LocalQuestionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? packageId,
      Value<String>? code,
      Value<String>? content,
      Value<String>? questionType,
      Value<int?>? categoryId,
      Value<String>? category,
      Value<String>? difficulty,
      Value<String>? topic,
      Value<String>? explanation,
      Value<String>? referenceText}) {
    return LocalQuestionsCompanion(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      code: code ?? this.code,
      content: content ?? this.content,
      questionType: questionType ?? this.questionType,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      topic: topic ?? this.topic,
      explanation: explanation ?? this.explanation,
      referenceText: referenceText ?? this.referenceText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (referenceText.present) {
      map['reference_text'] = Variable<String>(referenceText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('code: $code, ')
          ..write('content: $content, ')
          ..write('questionType: $questionType, ')
          ..write('categoryId: $categoryId, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('topic: $topic, ')
          ..write('explanation: $explanation, ')
          ..write('referenceText: $referenceText')
          ..write(')'))
        .toString();
  }
}

class $LocalAnswersTable extends LocalAnswers
    with TableInfo<$LocalAnswersTable, LocalAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCorrectMeta =
      const VerificationMeta('isCorrect');
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
      'is_correct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_correct" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, questionId, label, content, isCorrect];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_answers';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnswer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(_isCorrectMeta,
          isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnswer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_correct'])!,
    );
  }

  @override
  $LocalAnswersTable createAlias(String alias) {
    return $LocalAnswersTable(attachedDatabase, alias);
  }
}

class LocalAnswer extends DataClass implements Insertable<LocalAnswer> {
  final int id;
  final int questionId;
  final String label;
  final String content;
  final bool isCorrect;
  const LocalAnswer(
      {required this.id,
      required this.questionId,
      required this.label,
      required this.content,
      required this.isCorrect});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['label'] = Variable<String>(label);
    map['content'] = Variable<String>(content);
    map['is_correct'] = Variable<bool>(isCorrect);
    return map;
  }

  LocalAnswersCompanion toCompanion(bool nullToAbsent) {
    return LocalAnswersCompanion(
      id: Value(id),
      questionId: Value(questionId),
      label: Value(label),
      content: Value(content),
      isCorrect: Value(isCorrect),
    );
  }

  factory LocalAnswer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnswer(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      label: serializer.fromJson<String>(json['label']),
      content: serializer.fromJson<String>(json['content']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'label': serializer.toJson<String>(label),
      'content': serializer.toJson<String>(content),
      'isCorrect': serializer.toJson<bool>(isCorrect),
    };
  }

  LocalAnswer copyWith(
          {int? id,
          int? questionId,
          String? label,
          String? content,
          bool? isCorrect}) =>
      LocalAnswer(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        label: label ?? this.label,
        content: content ?? this.content,
        isCorrect: isCorrect ?? this.isCorrect,
      );
  LocalAnswer copyWithCompanion(LocalAnswersCompanion data) {
    return LocalAnswer(
      id: data.id.present ? data.id.value : this.id,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      label: data.label.present ? data.label.value : this.label,
      content: data.content.present ? data.content.value : this.content,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnswer(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('content: $content, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, label, content, isCorrect);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnswer &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.label == this.label &&
          other.content == this.content &&
          other.isCorrect == this.isCorrect);
}

class LocalAnswersCompanion extends UpdateCompanion<LocalAnswer> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<String> label;
  final Value<String> content;
  final Value<bool> isCorrect;
  const LocalAnswersCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.label = const Value.absent(),
    this.content = const Value.absent(),
    this.isCorrect = const Value.absent(),
  });
  LocalAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required String label,
    required String content,
    this.isCorrect = const Value.absent(),
  })  : questionId = Value(questionId),
        label = Value(label),
        content = Value(content);
  static Insertable<LocalAnswer> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<String>? label,
    Expression<String>? content,
    Expression<bool>? isCorrect,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (label != null) 'label': label,
      if (content != null) 'content': content,
      if (isCorrect != null) 'is_correct': isCorrect,
    });
  }

  LocalAnswersCompanion copyWith(
      {Value<int>? id,
      Value<int>? questionId,
      Value<String>? label,
      Value<String>? content,
      Value<bool>? isCorrect}) {
    return LocalAnswersCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      content: content ?? this.content,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnswersCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('content: $content, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }
}

class $LocalAttemptsTable extends LocalAttempts
    with TableInfo<$LocalAttemptsTable, LocalAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subjectCodeMeta =
      const VerificationMeta('subjectCode');
  @override
  late final GeneratedColumn<String> subjectCode = GeneratedColumn<String>(
      'subject_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('practice'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctAnswersMeta =
      const VerificationMeta('correctAnswers');
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
      'correct_answers', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _answersJsonMeta =
      const VerificationMeta('answersJson');
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
      'answers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        subjectCode,
        mode,
        startedAt,
        completedAt,
        score,
        totalQuestions,
        correctAnswers,
        answersJson,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('subject_code')) {
      context.handle(
          _subjectCodeMeta,
          subjectCode.isAcceptableOrUnknown(
              data['subject_code']!, _subjectCodeMeta));
    } else if (isInserting) {
      context.missing(_subjectCodeMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
          _correctAnswersMeta,
          correctAnswers.isAcceptableOrUnknown(
              data['correct_answers']!, _correctAnswersMeta));
    }
    if (data.containsKey('answers_json')) {
      context.handle(
          _answersJsonMeta,
          answersJson.isAcceptableOrUnknown(
              data['answers_json']!, _answersJsonMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      subjectCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_code'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score']),
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      correctAnswers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_answers'])!,
      answersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answers_json'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $LocalAttemptsTable createAlias(String alias) {
    return $LocalAttemptsTable(attachedDatabase, alias);
  }
}

class LocalAttempt extends DataClass implements Insertable<LocalAttempt> {
  final String id;
  final int subjectId;
  final String subjectCode;
  final String mode;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;
  final int totalQuestions;
  final int correctAnswers;
  final String answersJson;
  final String syncStatus;
  const LocalAttempt(
      {required this.id,
      required this.subjectId,
      required this.subjectCode,
      required this.mode,
      required this.startedAt,
      this.completedAt,
      this.score,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.answersJson,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['subject_code'] = Variable<String>(subjectCode);
    map['mode'] = Variable<String>(mode);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['answers_json'] = Variable<String>(answersJson);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LocalAttemptsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      subjectCode: Value(subjectCode),
      mode: Value(mode),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      totalQuestions: Value(totalQuestions),
      correctAnswers: Value(correctAnswers),
      answersJson: Value(answersJson),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttempt(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      subjectCode: serializer.fromJson<String>(json['subjectCode']),
      mode: serializer.fromJson<String>(json['mode']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      score: serializer.fromJson<double?>(json['score']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'subjectCode': serializer.toJson<String>(subjectCode),
      'mode': serializer.toJson<String>(mode),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'score': serializer.toJson<double?>(score),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'answersJson': serializer.toJson<String>(answersJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalAttempt copyWith(
          {String? id,
          int? subjectId,
          String? subjectCode,
          String? mode,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<double?> score = const Value.absent(),
          int? totalQuestions,
          int? correctAnswers,
          String? answersJson,
          String? syncStatus}) =>
      LocalAttempt(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        subjectCode: subjectCode ?? this.subjectCode,
        mode: mode ?? this.mode,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        score: score.present ? score.value : this.score,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        answersJson: answersJson ?? this.answersJson,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocalAttempt copyWithCompanion(LocalAttemptsCompanion data) {
    return LocalAttempt(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      subjectCode:
          data.subjectCode.present ? data.subjectCode.value : this.subjectCode,
      mode: data.mode.present ? data.mode.value : this.mode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      score: data.score.present ? data.score.value : this.score,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      answersJson:
          data.answersJson.present ? data.answersJson.value : this.answersJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttempt(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectCode: $subjectCode, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('answersJson: $answersJson, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      subjectCode,
      mode,
      startedAt,
      completedAt,
      score,
      totalQuestions,
      correctAnswers,
      answersJson,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttempt &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.subjectCode == this.subjectCode &&
          other.mode == this.mode &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.score == this.score &&
          other.totalQuestions == this.totalQuestions &&
          other.correctAnswers == this.correctAnswers &&
          other.answersJson == this.answersJson &&
          other.syncStatus == this.syncStatus);
}

class LocalAttemptsCompanion extends UpdateCompanion<LocalAttempt> {
  final Value<String> id;
  final Value<int> subjectId;
  final Value<String> subjectCode;
  final Value<String> mode;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<double?> score;
  final Value<int> totalQuestions;
  final Value<int> correctAnswers;
  final Value<String> answersJson;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalAttemptsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectCode = const Value.absent(),
    this.mode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttemptsCompanion.insert({
    required String id,
    required int subjectId,
    required String subjectCode,
    this.mode = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        subjectCode = Value(subjectCode),
        startedAt = Value(startedAt);
  static Insertable<LocalAttempt> custom({
    Expression<String>? id,
    Expression<int>? subjectId,
    Expression<String>? subjectCode,
    Expression<String>? mode,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<double>? score,
    Expression<int>? totalQuestions,
    Expression<int>? correctAnswers,
    Expression<String>? answersJson,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectCode != null) 'subject_code': subjectCode,
      if (mode != null) 'mode': mode,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (answersJson != null) 'answers_json': answersJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttemptsCompanion copyWith(
      {Value<String>? id,
      Value<int>? subjectId,
      Value<String>? subjectCode,
      Value<String>? mode,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<double?>? score,
      Value<int>? totalQuestions,
      Value<int>? correctAnswers,
      Value<String>? answersJson,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return LocalAttemptsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectCode: subjectCode ?? this.subjectCode,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      answersJson: answersJson ?? this.answersJson,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (subjectCode.present) {
      map['subject_code'] = Variable<String>(subjectCode.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectCode: $subjectCode, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('answersJson: $answersJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionNameMeta =
      const VerificationMeta('actionName');
  @override
  late final GeneratedColumn<String> actionName = GeneratedColumn<String>(
      'action_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        actionName,
        payloadJson,
        createdAt,
        retryCount,
        lastError,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action_name')) {
      context.handle(
          _actionNameMeta,
          actionName.isAcceptableOrUnknown(
              data['action_name']!, _actionNameMeta));
    } else if (isInserting) {
      context.missing(_actionNameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      actionName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_name'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final String id;
  final String entityType;
  final String entityId;
  final String actionName;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final String status;
  const SyncQueueItem(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.actionName,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount,
      this.lastError,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action_name'] = Variable<String>(actionName);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      actionName: Value(actionName),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      actionName: serializer.fromJson<String>(json['actionName']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'actionName': serializer.toJson<String>(actionName),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueItem copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? actionName,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          String? status}) =>
      SyncQueueItem(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        actionName: actionName ?? this.actionName,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        status: status ?? this.status,
      );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      actionName:
          data.actionName.present ? data.actionName.value : this.actionName,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionName: $actionName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, actionName,
      payloadJson, createdAt, retryCount, lastError, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.actionName == this.actionName &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> actionName;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> status;
  final Value<int> rowid;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.actionName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String actionName,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        actionName = Value(actionName),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? actionName,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (actionName != null) 'action_name': actionName,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? actionName,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<String>? status,
      Value<int>? rowid}) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      actionName: actionName ?? this.actionName,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (actionName.present) {
      map['action_name'] = Variable<String>(actionName.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionName: $actionName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserProfilesTable extends LocalUserProfiles
    with TableInfo<$LocalUserProfilesTable, LocalUserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [serverId, username, displayName, role, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  LocalUserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserProfile(
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $LocalUserProfilesTable createAlias(String alias) {
    return $LocalUserProfilesTable(attachedDatabase, alias);
  }
}

class LocalUserProfile extends DataClass
    implements Insertable<LocalUserProfile> {
  final int serverId;
  final String username;
  final String displayName;
  final String? role;
  final DateTime cachedAt;
  const LocalUserProfile(
      {required this.serverId,
      required this.username,
      required this.displayName,
      this.role,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<int>(serverId);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalUserProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalUserProfilesCompanion(
      serverId: Value(serverId),
      username: Value(username),
      displayName: Value(displayName),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalUserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserProfile(
      serverId: serializer.fromJson<int>(json['serverId']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String?>(json['role']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<int>(serverId),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String?>(role),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalUserProfile copyWith(
          {int? serverId,
          String? username,
          String? displayName,
          Value<String?> role = const Value.absent(),
          DateTime? cachedAt}) =>
      LocalUserProfile(
        serverId: serverId ?? this.serverId,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        role: role.present ? role.value : this.role,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  LocalUserProfile copyWithCompanion(LocalUserProfilesCompanion data) {
    return LocalUserProfile(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfile(')
          ..write('serverId: $serverId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(serverId, username, displayName, role, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserProfile &&
          other.serverId == this.serverId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.cachedAt == this.cachedAt);
}

class LocalUserProfilesCompanion extends UpdateCompanion<LocalUserProfile> {
  final Value<int> serverId;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String?> role;
  final Value<DateTime> cachedAt;
  const LocalUserProfilesCompanion({
    this.serverId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  LocalUserProfilesCompanion.insert({
    this.serverId = const Value.absent(),
    required String username,
    required String displayName,
    this.role = const Value.absent(),
    required DateTime cachedAt,
  })  : username = Value(username),
        displayName = Value(displayName),
        cachedAt = Value(cachedAt);
  static Insertable<LocalUserProfile> custom({
    Expression<int>? serverId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  LocalUserProfilesCompanion copyWith(
      {Value<int>? serverId,
      Value<String>? username,
      Value<String>? displayName,
      Value<String?>? role,
      Value<DateTime>? cachedAt}) {
    return LocalUserProfilesCompanion(
      serverId: serverId ?? this.serverId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfilesCompanion(')
          ..write('serverId: $serverId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSubjectsTable localSubjects = $LocalSubjectsTable(this);
  late final $LocalPackagesTable localPackages = $LocalPackagesTable(this);
  late final $LocalQuestionsTable localQuestions = $LocalQuestionsTable(this);
  late final $LocalAnswersTable localAnswers = $LocalAnswersTable(this);
  late final $LocalAttemptsTable localAttempts = $LocalAttemptsTable(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $LocalUserProfilesTable localUserProfiles =
      $LocalUserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localSubjects,
        localPackages,
        localQuestions,
        localAnswers,
        localAttempts,
        syncQueueItems,
        appSettings,
        localUserProfiles
      ];
}

typedef $$LocalSubjectsTableCreateCompanionBuilder = LocalSubjectsCompanion
    Function({
  Value<int> serverId,
  required String code,
  required String name,
  Value<int> questionCount,
});
typedef $$LocalSubjectsTableUpdateCompanionBuilder = LocalSubjectsCompanion
    Function({
  Value<int> serverId,
  Value<String> code,
  Value<String> name,
  Value<int> questionCount,
});

class $$LocalSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => ColumnFilters(column));
}

class $$LocalSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionCount => $composableBuilder(
      column: $table.questionCount,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => column);
}

class $$LocalSubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSubjectsTable,
    LocalSubject,
    $$LocalSubjectsTableFilterComposer,
    $$LocalSubjectsTableOrderingComposer,
    $$LocalSubjectsTableAnnotationComposer,
    $$LocalSubjectsTableCreateCompanionBuilder,
    $$LocalSubjectsTableUpdateCompanionBuilder,
    (
      LocalSubject,
      BaseReferences<_$AppDatabase, $LocalSubjectsTable, LocalSubject>
    ),
    LocalSubject,
    PrefetchHooks Function()> {
  $$LocalSubjectsTableTableManager(_$AppDatabase db, $LocalSubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> serverId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> questionCount = const Value.absent(),
          }) =>
              LocalSubjectsCompanion(
            serverId: serverId,
            code: code,
            name: name,
            questionCount: questionCount,
          ),
          createCompanionCallback: ({
            Value<int> serverId = const Value.absent(),
            required String code,
            required String name,
            Value<int> questionCount = const Value.absent(),
          }) =>
              LocalSubjectsCompanion.insert(
            serverId: serverId,
            code: code,
            name: name,
            questionCount: questionCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalSubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSubjectsTable,
    LocalSubject,
    $$LocalSubjectsTableFilterComposer,
    $$LocalSubjectsTableOrderingComposer,
    $$LocalSubjectsTableAnnotationComposer,
    $$LocalSubjectsTableCreateCompanionBuilder,
    $$LocalSubjectsTableUpdateCompanionBuilder,
    (
      LocalSubject,
      BaseReferences<_$AppDatabase, $LocalSubjectsTable, LocalSubject>
    ),
    LocalSubject,
    PrefetchHooks Function()>;
typedef $$LocalPackagesTableCreateCompanionBuilder = LocalPackagesCompanion
    Function({
  required String packageId,
  required int subjectId,
  required String subjectCode,
  required String name,
  required int version,
  required String checksum,
  required String minimumAppVersion,
  required DateTime updatedAt,
  Value<int> sizeBytes,
  Value<int> questionCount,
  Value<DateTime?> downloadedAt,
  Value<int> rowid,
});
typedef $$LocalPackagesTableUpdateCompanionBuilder = LocalPackagesCompanion
    Function({
  Value<String> packageId,
  Value<int> subjectId,
  Value<String> subjectCode,
  Value<String> name,
  Value<int> version,
  Value<String> checksum,
  Value<String> minimumAppVersion,
  Value<DateTime> updatedAt,
  Value<int> sizeBytes,
  Value<int> questionCount,
  Value<DateTime?> downloadedAt,
  Value<int> rowid,
});

class $$LocalPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPackagesTable> {
  $$LocalPackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get minimumAppVersion => $composableBuilder(
      column: $table.minimumAppVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPackagesTable> {
  $$LocalPackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get minimumAppVersion => $composableBuilder(
      column: $table.minimumAppVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionCount => $composableBuilder(
      column: $table.questionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPackagesTable> {
  $$LocalPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get minimumAppVersion => $composableBuilder(
      column: $table.minimumAppVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$LocalPackagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalPackagesTable,
    LocalPackage,
    $$LocalPackagesTableFilterComposer,
    $$LocalPackagesTableOrderingComposer,
    $$LocalPackagesTableAnnotationComposer,
    $$LocalPackagesTableCreateCompanionBuilder,
    $$LocalPackagesTableUpdateCompanionBuilder,
    (
      LocalPackage,
      BaseReferences<_$AppDatabase, $LocalPackagesTable, LocalPackage>
    ),
    LocalPackage,
    PrefetchHooks Function()> {
  $$LocalPackagesTableTableManager(_$AppDatabase db, $LocalPackagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> packageId = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<String> subjectCode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> checksum = const Value.absent(),
            Value<String> minimumAppVersion = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<int> questionCount = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPackagesCompanion(
            packageId: packageId,
            subjectId: subjectId,
            subjectCode: subjectCode,
            name: name,
            version: version,
            checksum: checksum,
            minimumAppVersion: minimumAppVersion,
            updatedAt: updatedAt,
            sizeBytes: sizeBytes,
            questionCount: questionCount,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String packageId,
            required int subjectId,
            required String subjectCode,
            required String name,
            required int version,
            required String checksum,
            required String minimumAppVersion,
            required DateTime updatedAt,
            Value<int> sizeBytes = const Value.absent(),
            Value<int> questionCount = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPackagesCompanion.insert(
            packageId: packageId,
            subjectId: subjectId,
            subjectCode: subjectCode,
            name: name,
            version: version,
            checksum: checksum,
            minimumAppVersion: minimumAppVersion,
            updatedAt: updatedAt,
            sizeBytes: sizeBytes,
            questionCount: questionCount,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalPackagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalPackagesTable,
    LocalPackage,
    $$LocalPackagesTableFilterComposer,
    $$LocalPackagesTableOrderingComposer,
    $$LocalPackagesTableAnnotationComposer,
    $$LocalPackagesTableCreateCompanionBuilder,
    $$LocalPackagesTableUpdateCompanionBuilder,
    (
      LocalPackage,
      BaseReferences<_$AppDatabase, $LocalPackagesTable, LocalPackage>
    ),
    LocalPackage,
    PrefetchHooks Function()>;
typedef $$LocalQuestionsTableCreateCompanionBuilder = LocalQuestionsCompanion
    Function({
  Value<int> id,
  required String packageId,
  required String code,
  required String content,
  required String questionType,
  Value<int?> categoryId,
  Value<String> category,
  Value<String> difficulty,
  Value<String> topic,
  Value<String> explanation,
  Value<String> referenceText,
});
typedef $$LocalQuestionsTableUpdateCompanionBuilder = LocalQuestionsCompanion
    Function({
  Value<int> id,
  Value<String> packageId,
  Value<String> code,
  Value<String> content,
  Value<String> questionType,
  Value<int?> categoryId,
  Value<String> category,
  Value<String> difficulty,
  Value<String> topic,
  Value<String> explanation,
  Value<String> referenceText,
});

class $$LocalQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionType => $composableBuilder(
      column: $table.questionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceText => $composableBuilder(
      column: $table.referenceText, builder: (column) => ColumnFilters(column));
}

class $$LocalQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionType => $composableBuilder(
      column: $table.questionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceText => $composableBuilder(
      column: $table.referenceText,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get questionType => $composableBuilder(
      column: $table.questionType, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get referenceText => $composableBuilder(
      column: $table.referenceText, builder: (column) => column);
}

class $$LocalQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (
      LocalQuestion,
      BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>
    ),
    LocalQuestion,
    PrefetchHooks Function()> {
  $$LocalQuestionsTableTableManager(
      _$AppDatabase db, $LocalQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> packageId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> questionType = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> topic = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<String> referenceText = const Value.absent(),
          }) =>
              LocalQuestionsCompanion(
            id: id,
            packageId: packageId,
            code: code,
            content: content,
            questionType: questionType,
            categoryId: categoryId,
            category: category,
            difficulty: difficulty,
            topic: topic,
            explanation: explanation,
            referenceText: referenceText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String packageId,
            required String code,
            required String content,
            required String questionType,
            Value<int?> categoryId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> topic = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<String> referenceText = const Value.absent(),
          }) =>
              LocalQuestionsCompanion.insert(
            id: id,
            packageId: packageId,
            code: code,
            content: content,
            questionType: questionType,
            categoryId: categoryId,
            category: category,
            difficulty: difficulty,
            topic: topic,
            explanation: explanation,
            referenceText: referenceText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (
      LocalQuestion,
      BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>
    ),
    LocalQuestion,
    PrefetchHooks Function()>;
typedef $$LocalAnswersTableCreateCompanionBuilder = LocalAnswersCompanion
    Function({
  Value<int> id,
  required int questionId,
  required String label,
  required String content,
  Value<bool> isCorrect,
});
typedef $$LocalAnswersTableUpdateCompanionBuilder = LocalAnswersCompanion
    Function({
  Value<int> id,
  Value<int> questionId,
  Value<String> label,
  Value<String> content,
  Value<bool> isCorrect,
});

class $$LocalAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnFilters(column));
}

class $$LocalAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnOrderings(column));
}

class $$LocalAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);
}

class $$LocalAnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalAnswersTable,
    LocalAnswer,
    $$LocalAnswersTableFilterComposer,
    $$LocalAnswersTableOrderingComposer,
    $$LocalAnswersTableAnnotationComposer,
    $$LocalAnswersTableCreateCompanionBuilder,
    $$LocalAnswersTableUpdateCompanionBuilder,
    (
      LocalAnswer,
      BaseReferences<_$AppDatabase, $LocalAnswersTable, LocalAnswer>
    ),
    LocalAnswer,
    PrefetchHooks Function()> {
  $$LocalAnswersTableTableManager(_$AppDatabase db, $LocalAnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> questionId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isCorrect = const Value.absent(),
          }) =>
              LocalAnswersCompanion(
            id: id,
            questionId: questionId,
            label: label,
            content: content,
            isCorrect: isCorrect,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int questionId,
            required String label,
            required String content,
            Value<bool> isCorrect = const Value.absent(),
          }) =>
              LocalAnswersCompanion.insert(
            id: id,
            questionId: questionId,
            label: label,
            content: content,
            isCorrect: isCorrect,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAnswersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalAnswersTable,
    LocalAnswer,
    $$LocalAnswersTableFilterComposer,
    $$LocalAnswersTableOrderingComposer,
    $$LocalAnswersTableAnnotationComposer,
    $$LocalAnswersTableCreateCompanionBuilder,
    $$LocalAnswersTableUpdateCompanionBuilder,
    (
      LocalAnswer,
      BaseReferences<_$AppDatabase, $LocalAnswersTable, LocalAnswer>
    ),
    LocalAnswer,
    PrefetchHooks Function()>;
typedef $$LocalAttemptsTableCreateCompanionBuilder = LocalAttemptsCompanion
    Function({
  required String id,
  required int subjectId,
  required String subjectCode,
  Value<String> mode,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<double?> score,
  Value<int> totalQuestions,
  Value<int> correctAnswers,
  Value<String> answersJson,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$LocalAttemptsTableUpdateCompanionBuilder = LocalAttemptsCompanion
    Function({
  Value<String> id,
  Value<int> subjectId,
  Value<String> subjectCode,
  Value<String> mode,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<double?> score,
  Value<int> totalQuestions,
  Value<int> correctAnswers,
  Value<String> answersJson,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LocalAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctAnswers => $composableBuilder(
      column: $table.correctAnswers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$LocalAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
      column: $table.correctAnswers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocalAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectCode => $composableBuilder(
      column: $table.subjectCode, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
      column: $table.correctAnswers, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$LocalAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalAttemptsTable,
    LocalAttempt,
    $$LocalAttemptsTableFilterComposer,
    $$LocalAttemptsTableOrderingComposer,
    $$LocalAttemptsTableAnnotationComposer,
    $$LocalAttemptsTableCreateCompanionBuilder,
    $$LocalAttemptsTableUpdateCompanionBuilder,
    (
      LocalAttempt,
      BaseReferences<_$AppDatabase, $LocalAttemptsTable, LocalAttempt>
    ),
    LocalAttempt,
    PrefetchHooks Function()> {
  $$LocalAttemptsTableTableManager(_$AppDatabase db, $LocalAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<String> subjectCode = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<double?> score = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int> correctAnswers = const Value.absent(),
            Value<String> answersJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAttemptsCompanion(
            id: id,
            subjectId: subjectId,
            subjectCode: subjectCode,
            mode: mode,
            startedAt: startedAt,
            completedAt: completedAt,
            score: score,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            answersJson: answersJson,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int subjectId,
            required String subjectCode,
            Value<String> mode = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<double?> score = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int> correctAnswers = const Value.absent(),
            Value<String> answersJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAttemptsCompanion.insert(
            id: id,
            subjectId: subjectId,
            subjectCode: subjectCode,
            mode: mode,
            startedAt: startedAt,
            completedAt: completedAt,
            score: score,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            answersJson: answersJson,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalAttemptsTable,
    LocalAttempt,
    $$LocalAttemptsTableFilterComposer,
    $$LocalAttemptsTableOrderingComposer,
    $$LocalAttemptsTableAnnotationComposer,
    $$LocalAttemptsTableCreateCompanionBuilder,
    $$LocalAttemptsTableUpdateCompanionBuilder,
    (
      LocalAttempt,
      BaseReferences<_$AppDatabase, $LocalAttemptsTable, LocalAttempt>
    ),
    LocalAttempt,
    PrefetchHooks Function()>;
typedef $$SyncQueueItemsTableCreateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  required String id,
  required String entityType,
  required String entityId,
  required String actionName,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<String> status,
  Value<int> rowid,
});
typedef $$SyncQueueItemsTableUpdateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> actionName,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<String> status,
  Value<int> rowid,
});

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionName => $composableBuilder(
      column: $table.actionName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionName => $composableBuilder(
      column: $table.actionName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get actionName => $composableBuilder(
      column: $table.actionName, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueItemsTableTableManager(
      _$AppDatabase db, $SyncQueueItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> actionName = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            actionName: actionName,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String actionName,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            actionName: actionName,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$LocalUserProfilesTableCreateCompanionBuilder
    = LocalUserProfilesCompanion Function({
  Value<int> serverId,
  required String username,
  required String displayName,
  Value<String?> role,
  required DateTime cachedAt,
});
typedef $$LocalUserProfilesTableUpdateCompanionBuilder
    = LocalUserProfilesCompanion Function({
  Value<int> serverId,
  Value<String> username,
  Value<String> displayName,
  Value<String?> role,
  Value<DateTime> cachedAt,
});

class $$LocalUserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserProfilesTable> {
  $$LocalUserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserProfilesTable> {
  $$LocalUserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserProfilesTable> {
  $$LocalUserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalUserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUserProfilesTable,
    LocalUserProfile,
    $$LocalUserProfilesTableFilterComposer,
    $$LocalUserProfilesTableOrderingComposer,
    $$LocalUserProfilesTableAnnotationComposer,
    $$LocalUserProfilesTableCreateCompanionBuilder,
    $$LocalUserProfilesTableUpdateCompanionBuilder,
    (
      LocalUserProfile,
      BaseReferences<_$AppDatabase, $LocalUserProfilesTable, LocalUserProfile>
    ),
    LocalUserProfile,
    PrefetchHooks Function()> {
  $$LocalUserProfilesTableTableManager(
      _$AppDatabase db, $LocalUserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserProfilesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> serverId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              LocalUserProfilesCompanion(
            serverId: serverId,
            username: username,
            displayName: displayName,
            role: role,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> serverId = const Value.absent(),
            required String username,
            required String displayName,
            Value<String?> role = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              LocalUserProfilesCompanion.insert(
            serverId: serverId,
            username: username,
            displayName: displayName,
            role: role,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUserProfilesTable,
    LocalUserProfile,
    $$LocalUserProfilesTableFilterComposer,
    $$LocalUserProfilesTableOrderingComposer,
    $$LocalUserProfilesTableAnnotationComposer,
    $$LocalUserProfilesTableCreateCompanionBuilder,
    $$LocalUserProfilesTableUpdateCompanionBuilder,
    (
      LocalUserProfile,
      BaseReferences<_$AppDatabase, $LocalUserProfilesTable, LocalUserProfile>
    ),
    LocalUserProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSubjectsTableTableManager get localSubjects =>
      $$LocalSubjectsTableTableManager(_db, _db.localSubjects);
  $$LocalPackagesTableTableManager get localPackages =>
      $$LocalPackagesTableTableManager(_db, _db.localPackages);
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(_db, _db.localQuestions);
  $$LocalAnswersTableTableManager get localAnswers =>
      $$LocalAnswersTableTableManager(_db, _db.localAnswers);
  $$LocalAttemptsTableTableManager get localAttempts =>
      $$LocalAttemptsTableTableManager(_db, _db.localAttempts);
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$LocalUserProfilesTableTableManager get localUserProfiles =>
      $$LocalUserProfilesTableTableManager(_db, _db.localUserProfiles);
}
