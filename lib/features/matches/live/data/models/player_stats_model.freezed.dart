// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayerStatsModel _$PlayerStatsModelFromJson(Map<String, dynamic> json) {
  return _PlayerStatsModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerStatsModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_id')
  String get playerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  @JsonKey(name: 'ft_made')
  int get ftMade => throw _privateConstructorUsedError;
  @JsonKey(name: 'ft_attempted')
  int get ftAttempted => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg2_made')
  int get fg2Made => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg2_attempted')
  int get fg2Attempted => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg3_made')
  int get fg3Made => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg3_attempted')
  int get fg3Attempted => throw _privateConstructorUsedError;
  int get assists => throw _privateConstructorUsedError;
  @JsonKey(name: 'offensive_rebounds')
  int get offensiveRebounds => throw _privateConstructorUsedError;
  @JsonKey(name: 'defensive_rebounds')
  int get defensiveRebounds => throw _privateConstructorUsedError;
  int get steals => throw _privateConstructorUsedError;
  int get turnovers => throw _privateConstructorUsedError;
  int get blocks => throw _privateConstructorUsedError;
  int get fouls => throw _privateConstructorUsedError;
  @JsonKey(name: 'shot_zones')
  Map<String, dynamic> get shotZones => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_seconds_played')
  int get totalSecondsPlayed => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerStatsModelCopyWith<PlayerStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerStatsModelCopyWith<$Res> {
  factory $PlayerStatsModelCopyWith(
          PlayerStatsModel value, $Res Function(PlayerStatsModel) then) =
      _$PlayerStatsModelCopyWithImpl<$Res, PlayerStatsModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      int points,
      @JsonKey(name: 'ft_made') int ftMade,
      @JsonKey(name: 'ft_attempted') int ftAttempted,
      @JsonKey(name: 'fg2_made') int fg2Made,
      @JsonKey(name: 'fg2_attempted') int fg2Attempted,
      @JsonKey(name: 'fg3_made') int fg3Made,
      @JsonKey(name: 'fg3_attempted') int fg3Attempted,
      int assists,
      @JsonKey(name: 'offensive_rebounds') int offensiveRebounds,
      @JsonKey(name: 'defensive_rebounds') int defensiveRebounds,
      int steals,
      int turnovers,
      int blocks,
      int fouls,
      @JsonKey(name: 'shot_zones') Map<String, dynamic> shotZones,
      @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$PlayerStatsModelCopyWithImpl<$Res, $Val extends PlayerStatsModel>
    implements $PlayerStatsModelCopyWith<$Res> {
  _$PlayerStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? points = null,
    Object? ftMade = null,
    Object? ftAttempted = null,
    Object? fg2Made = null,
    Object? fg2Attempted = null,
    Object? fg3Made = null,
    Object? fg3Attempted = null,
    Object? assists = null,
    Object? offensiveRebounds = null,
    Object? defensiveRebounds = null,
    Object? steals = null,
    Object? turnovers = null,
    Object? blocks = null,
    Object? fouls = null,
    Object? shotZones = null,
    Object? totalSecondsPlayed = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      ftMade: null == ftMade
          ? _value.ftMade
          : ftMade // ignore: cast_nullable_to_non_nullable
              as int,
      ftAttempted: null == ftAttempted
          ? _value.ftAttempted
          : ftAttempted // ignore: cast_nullable_to_non_nullable
              as int,
      fg2Made: null == fg2Made
          ? _value.fg2Made
          : fg2Made // ignore: cast_nullable_to_non_nullable
              as int,
      fg2Attempted: null == fg2Attempted
          ? _value.fg2Attempted
          : fg2Attempted // ignore: cast_nullable_to_non_nullable
              as int,
      fg3Made: null == fg3Made
          ? _value.fg3Made
          : fg3Made // ignore: cast_nullable_to_non_nullable
              as int,
      fg3Attempted: null == fg3Attempted
          ? _value.fg3Attempted
          : fg3Attempted // ignore: cast_nullable_to_non_nullable
              as int,
      assists: null == assists
          ? _value.assists
          : assists // ignore: cast_nullable_to_non_nullable
              as int,
      offensiveRebounds: null == offensiveRebounds
          ? _value.offensiveRebounds
          : offensiveRebounds // ignore: cast_nullable_to_non_nullable
              as int,
      defensiveRebounds: null == defensiveRebounds
          ? _value.defensiveRebounds
          : defensiveRebounds // ignore: cast_nullable_to_non_nullable
              as int,
      steals: null == steals
          ? _value.steals
          : steals // ignore: cast_nullable_to_non_nullable
              as int,
      turnovers: null == turnovers
          ? _value.turnovers
          : turnovers // ignore: cast_nullable_to_non_nullable
              as int,
      blocks: null == blocks
          ? _value.blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as int,
      fouls: null == fouls
          ? _value.fouls
          : fouls // ignore: cast_nullable_to_non_nullable
              as int,
      shotZones: null == shotZones
          ? _value.shotZones
          : shotZones // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      totalSecondsPlayed: null == totalSecondsPlayed
          ? _value.totalSecondsPlayed
          : totalSecondsPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerStatsModelImplCopyWith<$Res>
    implements $PlayerStatsModelCopyWith<$Res> {
  factory _$$PlayerStatsModelImplCopyWith(_$PlayerStatsModelImpl value,
          $Res Function(_$PlayerStatsModelImpl) then) =
      __$$PlayerStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      int points,
      @JsonKey(name: 'ft_made') int ftMade,
      @JsonKey(name: 'ft_attempted') int ftAttempted,
      @JsonKey(name: 'fg2_made') int fg2Made,
      @JsonKey(name: 'fg2_attempted') int fg2Attempted,
      @JsonKey(name: 'fg3_made') int fg3Made,
      @JsonKey(name: 'fg3_attempted') int fg3Attempted,
      int assists,
      @JsonKey(name: 'offensive_rebounds') int offensiveRebounds,
      @JsonKey(name: 'defensive_rebounds') int defensiveRebounds,
      int steals,
      int turnovers,
      int blocks,
      int fouls,
      @JsonKey(name: 'shot_zones') Map<String, dynamic> shotZones,
      @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlayerStatsModelImplCopyWithImpl<$Res>
    extends _$PlayerStatsModelCopyWithImpl<$Res, _$PlayerStatsModelImpl>
    implements _$$PlayerStatsModelImplCopyWith<$Res> {
  __$$PlayerStatsModelImplCopyWithImpl(_$PlayerStatsModelImpl _value,
      $Res Function(_$PlayerStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayerStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? points = null,
    Object? ftMade = null,
    Object? ftAttempted = null,
    Object? fg2Made = null,
    Object? fg2Attempted = null,
    Object? fg3Made = null,
    Object? fg3Attempted = null,
    Object? assists = null,
    Object? offensiveRebounds = null,
    Object? defensiveRebounds = null,
    Object? steals = null,
    Object? turnovers = null,
    Object? blocks = null,
    Object? fouls = null,
    Object? shotZones = null,
    Object? totalSecondsPlayed = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlayerStatsModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      ftMade: null == ftMade
          ? _value.ftMade
          : ftMade // ignore: cast_nullable_to_non_nullable
              as int,
      ftAttempted: null == ftAttempted
          ? _value.ftAttempted
          : ftAttempted // ignore: cast_nullable_to_non_nullable
              as int,
      fg2Made: null == fg2Made
          ? _value.fg2Made
          : fg2Made // ignore: cast_nullable_to_non_nullable
              as int,
      fg2Attempted: null == fg2Attempted
          ? _value.fg2Attempted
          : fg2Attempted // ignore: cast_nullable_to_non_nullable
              as int,
      fg3Made: null == fg3Made
          ? _value.fg3Made
          : fg3Made // ignore: cast_nullable_to_non_nullable
              as int,
      fg3Attempted: null == fg3Attempted
          ? _value.fg3Attempted
          : fg3Attempted // ignore: cast_nullable_to_non_nullable
              as int,
      assists: null == assists
          ? _value.assists
          : assists // ignore: cast_nullable_to_non_nullable
              as int,
      offensiveRebounds: null == offensiveRebounds
          ? _value.offensiveRebounds
          : offensiveRebounds // ignore: cast_nullable_to_non_nullable
              as int,
      defensiveRebounds: null == defensiveRebounds
          ? _value.defensiveRebounds
          : defensiveRebounds // ignore: cast_nullable_to_non_nullable
              as int,
      steals: null == steals
          ? _value.steals
          : steals // ignore: cast_nullable_to_non_nullable
              as int,
      turnovers: null == turnovers
          ? _value.turnovers
          : turnovers // ignore: cast_nullable_to_non_nullable
              as int,
      blocks: null == blocks
          ? _value.blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as int,
      fouls: null == fouls
          ? _value.fouls
          : fouls // ignore: cast_nullable_to_non_nullable
              as int,
      shotZones: null == shotZones
          ? _value._shotZones
          : shotZones // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      totalSecondsPlayed: null == totalSecondsPlayed
          ? _value.totalSecondsPlayed
          : totalSecondsPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerStatsModelImpl implements _PlayerStatsModel {
  const _$PlayerStatsModelImpl(
      {required this.id,
      @JsonKey(name: 'player_id') required this.playerId,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'jersey_number') required this.jerseyNumber,
      this.points = 0,
      @JsonKey(name: 'ft_made') this.ftMade = 0,
      @JsonKey(name: 'ft_attempted') this.ftAttempted = 0,
      @JsonKey(name: 'fg2_made') this.fg2Made = 0,
      @JsonKey(name: 'fg2_attempted') this.fg2Attempted = 0,
      @JsonKey(name: 'fg3_made') this.fg3Made = 0,
      @JsonKey(name: 'fg3_attempted') this.fg3Attempted = 0,
      this.assists = 0,
      @JsonKey(name: 'offensive_rebounds') this.offensiveRebounds = 0,
      @JsonKey(name: 'defensive_rebounds') this.defensiveRebounds = 0,
      this.steals = 0,
      this.turnovers = 0,
      this.blocks = 0,
      this.fouls = 0,
      @JsonKey(name: 'shot_zones')
      final Map<String, dynamic> shotZones = const {},
      @JsonKey(name: 'total_seconds_played') this.totalSecondsPlayed = 0,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt})
      : _shotZones = shotZones;

  factory _$PlayerStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerStatsModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'player_id')
  final String playerId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'jersey_number')
  final int jerseyNumber;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey(name: 'ft_made')
  final int ftMade;
  @override
  @JsonKey(name: 'ft_attempted')
  final int ftAttempted;
  @override
  @JsonKey(name: 'fg2_made')
  final int fg2Made;
  @override
  @JsonKey(name: 'fg2_attempted')
  final int fg2Attempted;
  @override
  @JsonKey(name: 'fg3_made')
  final int fg3Made;
  @override
  @JsonKey(name: 'fg3_attempted')
  final int fg3Attempted;
  @override
  @JsonKey()
  final int assists;
  @override
  @JsonKey(name: 'offensive_rebounds')
  final int offensiveRebounds;
  @override
  @JsonKey(name: 'defensive_rebounds')
  final int defensiveRebounds;
  @override
  @JsonKey()
  final int steals;
  @override
  @JsonKey()
  final int turnovers;
  @override
  @JsonKey()
  final int blocks;
  @override
  @JsonKey()
  final int fouls;
  final Map<String, dynamic> _shotZones;
  @override
  @JsonKey(name: 'shot_zones')
  Map<String, dynamic> get shotZones {
    if (_shotZones is EqualUnmodifiableMapView) return _shotZones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_shotZones);
  }

  @override
  @JsonKey(name: 'total_seconds_played')
  final int totalSecondsPlayed;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlayerStatsModel(id: $id, playerId: $playerId, fullName: $fullName, jerseyNumber: $jerseyNumber, points: $points, ftMade: $ftMade, ftAttempted: $ftAttempted, fg2Made: $fg2Made, fg2Attempted: $fg2Attempted, fg3Made: $fg3Made, fg3Attempted: $fg3Attempted, assists: $assists, offensiveRebounds: $offensiveRebounds, defensiveRebounds: $defensiveRebounds, steals: $steals, turnovers: $turnovers, blocks: $blocks, fouls: $fouls, shotZones: $shotZones, totalSecondsPlayed: $totalSecondsPlayed, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStatsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.jerseyNumber, jerseyNumber) ||
                other.jerseyNumber == jerseyNumber) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.ftMade, ftMade) || other.ftMade == ftMade) &&
            (identical(other.ftAttempted, ftAttempted) ||
                other.ftAttempted == ftAttempted) &&
            (identical(other.fg2Made, fg2Made) || other.fg2Made == fg2Made) &&
            (identical(other.fg2Attempted, fg2Attempted) ||
                other.fg2Attempted == fg2Attempted) &&
            (identical(other.fg3Made, fg3Made) || other.fg3Made == fg3Made) &&
            (identical(other.fg3Attempted, fg3Attempted) ||
                other.fg3Attempted == fg3Attempted) &&
            (identical(other.assists, assists) || other.assists == assists) &&
            (identical(other.offensiveRebounds, offensiveRebounds) ||
                other.offensiveRebounds == offensiveRebounds) &&
            (identical(other.defensiveRebounds, defensiveRebounds) ||
                other.defensiveRebounds == defensiveRebounds) &&
            (identical(other.steals, steals) || other.steals == steals) &&
            (identical(other.turnovers, turnovers) ||
                other.turnovers == turnovers) &&
            (identical(other.blocks, blocks) || other.blocks == blocks) &&
            (identical(other.fouls, fouls) || other.fouls == fouls) &&
            const DeepCollectionEquality()
                .equals(other._shotZones, _shotZones) &&
            (identical(other.totalSecondsPlayed, totalSecondsPlayed) ||
                other.totalSecondsPlayed == totalSecondsPlayed) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        playerId,
        fullName,
        jerseyNumber,
        points,
        ftMade,
        ftAttempted,
        fg2Made,
        fg2Attempted,
        fg3Made,
        fg3Attempted,
        assists,
        offensiveRebounds,
        defensiveRebounds,
        steals,
        turnovers,
        blocks,
        fouls,
        const DeepCollectionEquality().hash(_shotZones),
        totalSecondsPlayed,
        updatedAt
      ]);

  /// Create a copy of PlayerStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStatsModelImplCopyWith<_$PlayerStatsModelImpl> get copyWith =>
      __$$PlayerStatsModelImplCopyWithImpl<_$PlayerStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerStatsModelImplToJson(
      this,
    );
  }
}

abstract class _PlayerStatsModel implements PlayerStatsModel {
  const factory _PlayerStatsModel(
      {required final String id,
      @JsonKey(name: 'player_id') required final String playerId,
      @JsonKey(name: 'full_name') required final String fullName,
      @JsonKey(name: 'jersey_number') required final int jerseyNumber,
      final int points,
      @JsonKey(name: 'ft_made') final int ftMade,
      @JsonKey(name: 'ft_attempted') final int ftAttempted,
      @JsonKey(name: 'fg2_made') final int fg2Made,
      @JsonKey(name: 'fg2_attempted') final int fg2Attempted,
      @JsonKey(name: 'fg3_made') final int fg3Made,
      @JsonKey(name: 'fg3_attempted') final int fg3Attempted,
      final int assists,
      @JsonKey(name: 'offensive_rebounds') final int offensiveRebounds,
      @JsonKey(name: 'defensive_rebounds') final int defensiveRebounds,
      final int steals,
      final int turnovers,
      final int blocks,
      final int fouls,
      @JsonKey(name: 'shot_zones') final Map<String, dynamic> shotZones,
      @JsonKey(name: 'total_seconds_played') final int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$PlayerStatsModelImpl;

  factory _PlayerStatsModel.fromJson(Map<String, dynamic> json) =
      _$PlayerStatsModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'player_id')
  String get playerId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber;
  @override
  int get points;
  @override
  @JsonKey(name: 'ft_made')
  int get ftMade;
  @override
  @JsonKey(name: 'ft_attempted')
  int get ftAttempted;
  @override
  @JsonKey(name: 'fg2_made')
  int get fg2Made;
  @override
  @JsonKey(name: 'fg2_attempted')
  int get fg2Attempted;
  @override
  @JsonKey(name: 'fg3_made')
  int get fg3Made;
  @override
  @JsonKey(name: 'fg3_attempted')
  int get fg3Attempted;
  @override
  int get assists;
  @override
  @JsonKey(name: 'offensive_rebounds')
  int get offensiveRebounds;
  @override
  @JsonKey(name: 'defensive_rebounds')
  int get defensiveRebounds;
  @override
  int get steals;
  @override
  int get turnovers;
  @override
  int get blocks;
  @override
  int get fouls;
  @override
  @JsonKey(name: 'shot_zones')
  Map<String, dynamic> get shotZones;
  @override
  @JsonKey(name: 'total_seconds_played')
  int get totalSecondsPlayed;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PlayerStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerStatsModelImplCopyWith<_$PlayerStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
