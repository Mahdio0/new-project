// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchlistMovieAdapter extends TypeAdapter<WatchlistMovie> {
  @override
  final int typeId = 0;

  @override
  WatchlistMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String?,
      voteAverage: fields[3] as double,
      releaseDate: fields[4] as String,
      addedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistMovie obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.voteAverage)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
