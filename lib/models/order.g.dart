// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 1;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as String,
      shopId: fields[1] as String,
      customerId: fields[2] as String,
      orderNumber: fields[3] as String,
      garmentType: fields[4] as String,
      orderDate: fields[5] as DateTime,
      deliveryDate: fields[6] as DateTime,
      isUrgent: fields[7] as bool,
      status: fields[8] as String,
      totalAmount: fields[9] as double,
      advancePaid: fields[10] as double,
      balancePaid: fields[11] as bool,
      fabricNotes: fields[12] as String?,
      orderNotes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      isDeleted: fields[16] as bool,
      isSynced: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.orderNumber)
      ..writeByte(4)
      ..write(obj.garmentType)
      ..writeByte(5)
      ..write(obj.orderDate)
      ..writeByte(6)
      ..write(obj.deliveryDate)
      ..writeByte(7)
      ..write(obj.isUrgent)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.totalAmount)
      ..writeByte(10)
      ..write(obj.advancePaid)
      ..writeByte(11)
      ..write(obj.balancePaid)
      ..writeByte(12)
      ..write(obj.fabricNotes)
      ..writeByte(13)
      ..write(obj.orderNotes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.isDeleted)
      ..writeByte(17)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
