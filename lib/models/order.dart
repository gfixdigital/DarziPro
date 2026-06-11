import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 1)
class Order extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String shopId;

  @HiveField(2)
  String customerId;

  @HiveField(3)
  String orderNumber;

  @HiveField(4)
  String garmentType;

  @HiveField(5)
  DateTime orderDate;

  @HiveField(6)
  DateTime deliveryDate;

  @HiveField(7)
  bool isUrgent;

  @HiveField(8)
  String status;

  @HiveField(9)
  double totalAmount;

  @HiveField(10)
  double advancePaid;

  @HiveField(11)
  bool balancePaid;

  @HiveField(12)
  String? fabricNotes;

  @HiveField(13)
  String? orderNotes;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  bool isDeleted;

  @HiveField(17)
  bool isSynced;

  Order({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.orderNumber,
    required this.garmentType,
    required this.orderDate,
    required this.deliveryDate,
    this.isUrgent = false,
    this.status = 'pending',
    required this.totalAmount,
    this.advancePaid = 0,
    this.balancePaid = false,
    this.fabricNotes,
    this.orderNotes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
  });

  double get remainingBalance => totalAmount - advancePaid;

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'customer_id': customerId,
        'order_number': orderNumber,
        'garment_type': garmentType,
        'order_date': orderDate.toIso8601String().split('T')[0],
        'delivery_date': deliveryDate.toIso8601String().split('T')[0],
        'is_urgent': isUrgent,
        'status': status,
        'total_amount': totalAmount,
        'advance_paid': advancePaid,
        'balance_paid': balancePaid,
        'fabric_notes': fabricNotes,
        'order_notes': orderNotes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_deleted': isDeleted,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        customerId: json['customer_id'] as String,
        orderNumber: json['order_number'] as String,
        garmentType: json['garment_type'] as String,
        orderDate: DateTime.parse(json['order_date'] as String),
        deliveryDate: DateTime.parse(json['delivery_date'] as String),
        isUrgent: json['is_urgent'] as bool? ?? false,
        status: json['status'] as String? ?? 'pending',
        totalAmount: (json['total_amount'] as num).toDouble(),
        advancePaid: (json['advance_paid'] as num?)?.toDouble() ?? 0,
        balancePaid: json['balance_paid'] as bool? ?? false,
        fabricNotes: json['fabric_notes'] as String?,
        orderNotes: json['order_notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isDeleted: json['is_deleted'] as bool? ?? false,
        isSynced: true,
      );
}
