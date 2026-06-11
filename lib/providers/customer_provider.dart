import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/hive_service.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../models/style_preference.dart';

/// Customer state management
class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  String _searchQuery = '';

  List<Customer> get customers {
    if (_searchQuery.isEmpty) return _customers;
    final query = _searchQuery.toLowerCase();
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.phone.contains(query))
        .toList();
  }

  String get searchQuery => _searchQuery;

  /// Load all active customers from Hive
  void loadCustomers() {
    _customers = HiveService.getActiveCustomers();
    // Reconstruct default measurements/styles from synced customer notes
    for (final customer in _customers) {
      HiveService.extractAndSaveDefaultMetadata(customer);
    }
    notifyListeners();
  }

  /// Search customers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Add a new customer with optional measurements and style preferences
  Future<Customer> addCustomer({
    required String name,
    required String phone,
    String? address,
    String? notes,
    Map<String, double?>? measurements,
    String? fitNotes,
    Map<String, dynamic>? stylePreferences,
  }) async {
    final uuid = const Uuid();
    final shopId = HiveService.shopId ?? '';

    final customer = Customer(
      id: uuid.v4(),
      shopId: shopId,
      name: name,
      phone: phone,
      address: address,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await HiveService.saveCustomer(customer);

    // Save default measurements if any values were entered
    if (measurements != null) {
      final hasMeasurements =
          measurements.values.any((v) => v != null && v > 0);
      if (hasMeasurements || (fitNotes != null && fitNotes.isNotEmpty)) {
        final m = Measurement(
          id: uuid.v4(),
          orderId: '', // will be set by saveCustomerDefaultMeasurement
          shopId: shopId,
          kameezLength: measurements['kameezLength'],
          sleeve: measurements['sleeve'],
          shoulder: measurements['shoulder'],
          neck: measurements['neck'],
          hem: measurements['hem'],
          chest: measurements['chest'],
          waist: measurements['waist'],
          shalwarLength: measurements['shalwarLength'],
          legOpening: measurements['legOpening'],
          cuff: measurements['cuff'],
          fitNotes: fitNotes,
        );
        await HiveService.saveCustomerDefaultMeasurement(customer.id, m);
      }
    }

    // Save default style preferences if any were selected
    if (stylePreferences != null) {
      final pockets = stylePreferences['pockets'] as List<String>? ?? [];
      final suitStyle = stylePreferences['suitStyle'] as List<String>? ?? [];
      final hasStyle = stylePreferences['collar'] != null ||
          pockets.isNotEmpty ||
          stylePreferences['daman'] != null ||
          stylePreferences['cuffs'] != null ||
          (stylePreferences['silkThread'] as bool? ?? false) ||
          stylePreferences['stitching'] != null ||
          stylePreferences['buttons'] != null ||
          suitStyle.isNotEmpty ||
          stylePreferences['shalwarStyle'] != null;

      if (hasStyle) {
        final sp = StylePreference(
          id: uuid.v4(),
          orderId: '', // will be set by saveCustomerDefaultStyle
          shopId: shopId,
          collar: stylePreferences['collar'] as String?,
          pockets: pockets,
          daman: stylePreferences['daman'] as String?,
          cuffs: stylePreferences['cuffs'] as String?,
          silkThread: stylePreferences['silkThread'] as bool? ?? false,
          stitching: stylePreferences['stitching'] as String?,
          buttons: stylePreferences['buttons'] as String?,
          suitStyle: suitStyle,
          shalwarStyle: stylePreferences['shalwarStyle'] as String?,
        );
        await HiveService.saveCustomerDefaultStyle(customer.id, sp);
      }
    }

    loadCustomers();
    return customer;
  }

  /// Update an existing customer
  Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    await customer.save();
    loadCustomers();
  }

  /// Delete a customer (soft delete)
  Future<void> deleteCustomer(Customer customer) async {
    customer.isDeleted = true;
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    await customer.save();
    loadCustomers();
  }

  /// Get a single customer by ID
  Customer? getCustomerById(String id) {
    return HiveService.getCustomerById(id);
  }

  /// Get order count for a customer
  int getOrderCount(String customerId) {
    return HiveService.getOrdersForCustomer(customerId).length;
  }

  /// Get the saved default measurements for a customer
  Measurement? getCustomerMeasurements(String customerId) {
    return HiveService.getLatestMeasurementForCustomer(customerId);
  }

  /// Get the saved default style preferences for a customer
  StylePreference? getCustomerStyle(String customerId) {
    return HiveService.getCustomerDefaultStyle(customerId);
  }
}
