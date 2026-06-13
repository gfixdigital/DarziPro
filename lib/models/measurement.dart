import 'package:hive/hive.dart';

part 'measurement.g.dart';

@HiveType(typeId: 2)
class Measurement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String orderId;

  @HiveField(2)
  String shopId;

  @HiveField(3)
  double? kameezLength;

  @HiveField(4)
  double? sleeve;

  @HiveField(5)
  double? shoulder;

  @HiveField(6)
  double? neck;

  @HiveField(7)
  double? hem;

  @HiveField(8)
  double? chest;

  @HiveField(9)
  double? waist;

  @HiveField(10)
  double? shalwarLength;

  @HiveField(11)
  double? legOpening;

  @HiveField(12)
  double? cuff;

  @HiveField(13)
  String? fitNotes;

  @HiveField(14)
  bool isSynced;

  Measurement({
    required this.id,
    required this.orderId,
    required this.shopId,
    this.kameezLength,
    this.sleeve,
    this.shoulder,
    this.neck,
    this.hem,
    this.chest,
    this.waist,
    this.shalwarLength,
    this.legOpening,
    this.cuff,
    this.fitNotes,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'shop_id': shopId,
        'kameez_length': kameezLength,
        'sleeve': sleeve,
        'shoulder': shoulder,
        'neck': neck,
        'hem': hem,
        'chest': chest,
        'waist': waist,
        'shalwar_length': shalwarLength,
        'leg_opening': legOpening,
        'cuff': cuff,
        'fit_notes': fitNotes,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        id: json['id'] as String? ?? '',
        orderId: json['order_id'] as String? ?? '',
        shopId: json['shop_id'] as String? ?? '',
        kameezLength: (json['kameez_length'] as num?)?.toDouble(),
        sleeve: (json['sleeve'] as num?)?.toDouble(),
        shoulder: (json['shoulder'] as num?)?.toDouble(),
        neck: (json['neck'] as num?)?.toDouble(),
        hem: (json['hem'] as num?)?.toDouble(),
        chest: (json['chest'] as num?)?.toDouble(),
        waist: (json['waist'] as num?)?.toDouble(),
        shalwarLength: (json['shalwar_length'] as num?)?.toDouble(),
        legOpening: (json['leg_opening'] as num?)?.toDouble(),
        cuff: (json['cuff'] as num?)?.toDouble(),
        fitNotes: json['fit_notes'] as String?,
        isSynced: true,
      );

  /// Returns a map of label → value for display
  Map<String, double?> get displayMap => {
        'Kameez Length': kameezLength,
        'Sleeve': sleeve,
        'Shoulder': shoulder,
        'Neck': neck,
        'Chest': chest,
        'Waist': waist,
        'Hem': hem,
        'Shalwar Length': shalwarLength,
        'Leg Opening': legOpening,
        'Cuff': cuff,
      };
}
