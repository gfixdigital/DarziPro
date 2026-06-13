import 'package:hive/hive.dart';

part 'style_preference.g.dart';

@HiveType(typeId: 3)
class StylePreference extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String orderId;

  @HiveField(2)
  String shopId;

  @HiveField(3)
  String? collar;

  @HiveField(4)
  List<String> pockets;

  @HiveField(5)
  String? daman;

  @HiveField(6)
  String? cuffs;

  @HiveField(7)
  bool silkThread;

  @HiveField(8)
  String? stitching;

  @HiveField(9)
  String? buttons;

  @HiveField(10)
  List<String> suitStyle;

  @HiveField(11)
  String? shalwarStyle;

  @HiveField(12)
  bool isSynced;

  StylePreference({
    required this.id,
    required this.orderId,
    required this.shopId,
    this.collar,
    this.pockets = const [],
    this.daman,
    this.cuffs,
    this.silkThread = false,
    this.stitching,
    this.buttons,
    this.suitStyle = const [],
    this.shalwarStyle,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'shop_id': shopId,
        'collar': collar,
        'pockets': pockets,
        'daman': daman,
        'cuffs': cuffs,
        'silk_thread': silkThread,
        'stitching': stitching,
        'buttons': buttons,
        'suit_style': suitStyle,
        'shalwar_style': shalwarStyle,
      };

  factory StylePreference.fromJson(Map<String, dynamic> json) =>
      StylePreference(
        id: json['id'] as String? ?? '',
        orderId: json['order_id'] as String? ?? '',
        shopId: json['shop_id'] as String? ?? '',
        collar: json['collar'] as String?,
        pockets: (json['pockets'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        daman: json['daman'] as String?,
        cuffs: json['cuffs'] as String?,
        silkThread: json['silk_thread'] as bool? ?? false,
        stitching: json['stitching'] as String?,
        buttons: json['buttons'] as String?,
        suitStyle: (json['suit_style'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        shalwarStyle: json['shalwar_style'] as String?,
        isSynced: true,
      );

  /// Returns a map of all style choices for display
  Map<String, String> get displayMap {
    final map = <String, String>{};
    if (collar != null) map['Collar'] = collar!;
    if (pockets.isNotEmpty) map['Pockets'] = pockets.join(', ');
    if (daman != null) map['Daman'] = daman!;
    if (cuffs != null) map['Cuffs'] = cuffs!;
    map['Silk Thread'] = silkThread ? 'Yes' : 'No';
    if (stitching != null) map['Stitching'] = stitching!;
    if (buttons != null) map['Buttons'] = buttons!;
    if (suitStyle.isNotEmpty) map['Suit Style'] = suitStyle.join(', ');
    if (shalwarStyle != null) map['Shalwar Style'] = shalwarStyle!;
    return map;
  }
}
