// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style_preference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StylePreferenceAdapter extends TypeAdapter<StylePreference> {
  @override
  final int typeId = 3;

  @override
  StylePreference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StylePreference(
      id: fields[0] as String,
      orderId: fields[1] as String,
      shopId: fields[2] as String,
      collar: fields[3] as String?,
      pockets: (fields[4] as List).cast<String>(),
      daman: fields[5] as String?,
      cuffs: fields[6] as String?,
      silkThread: fields[7] as bool,
      stitching: fields[8] as String?,
      buttons: fields[9] as String?,
      suitStyle: (fields[10] as List).cast<String>(),
      shalwarStyle: fields[11] as String?,
      isSynced: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StylePreference obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.collar)
      ..writeByte(4)
      ..write(obj.pockets)
      ..writeByte(5)
      ..write(obj.daman)
      ..writeByte(6)
      ..write(obj.cuffs)
      ..writeByte(7)
      ..write(obj.silkThread)
      ..writeByte(8)
      ..write(obj.stitching)
      ..writeByte(9)
      ..write(obj.buttons)
      ..writeByte(10)
      ..write(obj.suitStyle)
      ..writeByte(11)
      ..write(obj.shalwarStyle)
      ..writeByte(12)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StylePreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
