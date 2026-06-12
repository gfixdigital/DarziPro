import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/hive_service.dart';
import '../models/order.dart';
import '../models/measurement.dart';
import '../models/style_preference.dart';

/// Order state management
class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String _filterStatus = 'all';

  List<Order> get orders {
    if (_filterStatus == 'all') {
      return _orders.where((o) => o.status != 'delivered').toList();
    }
    return _orders.where((o) => o.status == _filterStatus).toList();
  }

  List<Order> get allOrders => _orders;
  String get filterStatus => _filterStatus;

  // ─── Dashboard Stats ────────────────────────────────────
  int get todaysOrders => HiveService.getTodaysOrderCount();
  int get pendingDelivery => HiveService.getPendingDeliveryCount();
  double get paymentsDue => HiveService.getPaymentsDue();
  List<Order> get recentOrders => HiveService.getRecentOrders();

  /// Load all active orders from Hive
  void loadOrders() {
    _orders = HiveService.getActiveOrders();
    notifyListeners();
  }

  /// Set filter status
  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Create a new order with measurements and style preferences
  Future<Order> createOrder({
    required String customerId,
    required String garmentType,
    required DateTime orderDate,
    required DateTime deliveryDate,
    required bool isUrgent,
    required double totalAmount,
    required double advancePaid,
    String? fabricNotes,
    String? orderNotes,
    Measurement? measurement,
    StylePreference? stylePreference,
  }) async {
    final uuid = const Uuid();
    final shopId = HiveService.shopId ?? '';
    final orderNumber = HiveService.generateOrderNumber();
    final orderId = uuid.v4();

    // Create order
    final order = Order(
      id: orderId,
      shopId: shopId,
      customerId: customerId,
      orderNumber: orderNumber,
      garmentType: garmentType,
      orderDate: orderDate,
      deliveryDate: deliveryDate,
      isUrgent: isUrgent,
      status: 'pending',
      totalAmount: totalAmount,
      advancePaid: advancePaid,
      fabricNotes: fabricNotes,
      orderNotes: orderNotes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await HiveService.saveOrder(order);

    // CRITICAL: Create FRESH instances — never mutate an existing Hive object
    // with a new key (causes HiveError: same instance stored with two different keys)
    if (measurement != null) {
      final freshMeasurement = Measurement(
        id: uuid.v4(),
        orderId: orderId,
        shopId: shopId,
        kameezLength: measurement.kameezLength,
        sleeve: measurement.sleeve,
        shoulder: measurement.shoulder,
        neck: measurement.neck,
        hem: measurement.hem,
        chest: measurement.chest,
        waist: measurement.waist,
        shalwarLength: measurement.shalwarLength,
        legOpening: measurement.legOpening,
        cuff: measurement.cuff,
        fitNotes: measurement.fitNotes,
        isSynced: false,
      );
      await HiveService.saveMeasurement(freshMeasurement);
    }

    if (stylePreference != null) {
      final freshStyle = StylePreference(
        id: uuid.v4(),
        orderId: orderId,
        shopId: shopId,
        collar: stylePreference.collar,
        pockets: List<String>.from(stylePreference.pockets),
        daman: stylePreference.daman,
        cuffs: stylePreference.cuffs,
        silkThread: stylePreference.silkThread,
        stitching: stylePreference.stitching,
        buttons: stylePreference.buttons,
        suitStyle: List<String>.from(stylePreference.suitStyle),
        shalwarStyle: stylePreference.shalwarStyle,
        isSynced: false,
      );
      await HiveService.saveStylePreference(freshStyle);
    }

    loadOrders();
    return order;
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final order = HiveService.getOrderById(orderId);
    if (order != null) {
      order.status = newStatus;
      order.updatedAt = DateTime.now();
      order.isSynced = false;
      await order.save();
      loadOrders();
    }
  }

  /// Collect payment for an order
  Future<void> collectPayment(String orderId, double amount) async {
    final order = HiveService.getOrderById(orderId);
    if (order != null) {
      order.advancePaid = order.advancePaid + amount;
      if (order.advancePaid >= order.totalAmount) {
        order.balancePaid = true;
      }
      order.updatedAt = DateTime.now();
      order.isSynced = false;
      await order.save();
      loadOrders();
    }
  }

  /// Get order by ID
  Order? getOrderById(String id) => HiveService.getOrderById(id);

  /// Get measurement for an order
  Measurement? getMeasurementForOrder(String orderId) =>
      HiveService.getMeasurementForOrder(orderId);

  /// Get style preference for an order
  StylePreference? getStyleForOrder(String orderId) =>
      HiveService.getStyleForOrder(orderId);

  /// Get orders for a specific customer
  List<Order> getOrdersForCustomer(String customerId) =>
      HiveService.getOrdersForCustomer(customerId);
}
