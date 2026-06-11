import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/sync_provider.dart';
import '../../../models/measurement.dart';
import '../../../models/style_preference.dart';
import '../../../core/services/hive_service.dart';
import '../../../widgets/common/sync_indicator.dart';
import 'step1_info.dart';
import 'step2_measurements.dart';
import 'step3_style.dart';

/// New Order — 3-step wizard: Info → Measurements → Style → Save
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  int _step = 0;

  // ── Step 1 fields ──────────────────────────────────────────
  String? _customerId;
  DateTime _orderDate = DateTime.now();
  DateTime? _deliveryDate;
  String? _garmentType;
  bool _isUrgent = false;
  double _totalAmount = 0;
  double _advancePaid = 0;
  String? _fabricNotes;
  String? _orderNotes;

  // ── Step 2 & 3 objects ─────────────────────────────────────
  late Measurement _measurement;
  late StylePreference _style;

  @override
  void initState() {
    super.initState();
    final sid = HiveService.shopId ?? '';
    _measurement = Measurement(id: '', orderId: '', shopId: sid);
    _style = StylePreference(id: '', orderId: '', shopId: sid);
  }

  // ─── Step 1 → 2 ───────────────────────────────────────────
  void _onStep1(Map<String, dynamic> data) {
    setState(() {
      _customerId = data['customerId'];
      _orderDate = data['orderDate'];
      _deliveryDate = data['deliveryDate'];
      _garmentType = data['garmentType'];
      _isUrgent = data['isUrgent'];
      _totalAmount = data['totalAmount'];
      _advancePaid = data['advancePaid'];
      _fabricNotes = data['fabricNotes'];
      _orderNotes = data['orderNotes'];
      _step = 1;
    });
  }

  // ─── Step 2 → 3 ───────────────────────────────────────────
  void _onStep2(Measurement m) {
    setState(() {
      _measurement = m;
      _step = 2;
    });
  }

  // ─── Step 3 → Save ────────────────────────────────────────
  Future<void> _onStep3(StylePreference style) async {
    _style = style;

    if (_customerId == null || _garmentType == null || _deliveryDate == null) {
      _snack('Please complete all required fields', isError: true);
      return;
    }

    // Only pass measurement if it has at least one real value
    final hasMeasurement = _measurement.kameezLength != null ||
        _measurement.sleeve != null ||
        _measurement.shoulder != null ||
        _measurement.chest != null ||
        _measurement.waist != null ||
        _measurement.hem != null ||
        _measurement.neck != null ||
        _measurement.shalwarLength != null ||
        _measurement.legOpening != null ||
        _measurement.cuff != null;

    // Only pass style if it has at least one real selection
    final hasStyle = style.collar != null ||
        style.pockets.isNotEmpty ||
        style.daman != null ||
        style.cuffs != null ||
        style.stitching != null ||
        style.buttons != null ||
        style.shalwarStyle != null ||
        style.suitStyle.isNotEmpty ||
        style.silkThread;

    try {
      final order = await context.read<OrderProvider>().createOrder(
            customerId: _customerId!,
            garmentType: _garmentType!,
            orderDate: _orderDate,
            deliveryDate: _deliveryDate!,
            isUrgent: _isUrgent,
            totalAmount: _totalAmount,
            advancePaid: _advancePaid,
            fabricNotes: _fabricNotes,
            orderNotes: _orderNotes,
            measurement: hasMeasurement ? _measurement : null,
            stylePreference: hasStyle ? _style : null,
          );

      // Trigger immediate sync to Supabase
      if (mounted) context.read<SyncProvider>().syncNow();

      if (mounted) {
        _snack('Order #${order.orderNumber} created!');
        Navigator.pushReplacementNamed(context, '/orders/${order.id}');
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? kError : kPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Order Info', 'Measurements', 'Style'];
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          const SyncIndicator(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'New Order — ${titles[_step]}',
                      style: AppTextStyles.headlineSm,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Step progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step ? kPrimary : kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),

          // Step content
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Step1Info(
          customerId: _customerId,
          orderDate: _orderDate,
          deliveryDate: _deliveryDate,
          garmentType: _garmentType,
          isUrgent: _isUrgent,
          totalAmount: _totalAmount,
          advancePaid: _advancePaid,
          fabricNotes: _fabricNotes,
          onNext: _onStep1,
        );
      case 1:
        return Step2Measurements(
          customerId: _customerId,
          measurement: _measurement,
          onNext: _onStep2,
          onBack: () => setState(() => _step = 0),
        );
      case 2:
        return Step3Style(
          stylePreference: _style,
          onSave: _onStep3,
          onBack: () => setState(() => _step = 1),
        );
      default:
        return const SizedBox();
    }
  }
}
