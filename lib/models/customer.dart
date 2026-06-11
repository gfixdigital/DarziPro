import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String shopId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String? address;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  bool isDeleted;

  @HiveField(9)
  bool isSynced;

  Customer({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_deleted': isDeleted,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isDeleted: json['is_deleted'] as bool? ?? false,
        isSynced: true,
      );

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? notes,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return Customer(
      id: id,
      shopId: shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
