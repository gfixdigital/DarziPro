// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementAdapter extends TypeAdapter<Measurement> {
  @override
  final int typeId = 2;

  @override
  Measurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Measurement(
      id: fields[0] as String,
      orderId: fields[1] as String,
      shopId: fields[2] as String,
      kameezLength: fields[3] as double?,
      sleeve: fields[4] as double?,
      shoulder: fields[5] as double?,
      neck: fields[6] as double?,
      hem: fields[7] as double?,
      chest: fields[8] as double?,
      waist: fields[9] as double?,
      shalwarLength: fields[10] as double?,
      legOpening: fields[11] as double?,
      cuff: fields[12] as double?,
      fitNotes: fields[13] as String?,
      isSynced: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Measurement obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.kameezLength)
      ..writeByte(4)
      ..write(obj.sleeve)
      ..writeByte(5)
      ..write(obj.shoulder)
      ..writeByte(6)
      ..write(obj.neck)
      ..writeByte(7)
      ..write(obj.hem)
      ..writeByte(8)
      ..write(obj.chest)
      ..writeByte(9)
      ..write(obj.waist)
      ..writeByte(10)
      ..write(obj.shalwarLength)
      ..writeByte(11)
      ..write(obj.legOpening)
      ..writeByte(12)
      ..write(obj.cuff)
      ..writeByte(13)
      ..write(obj.fitNotes)
      ..writeByte(14)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
