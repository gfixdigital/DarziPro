import re

file_path = "lib/core/constants/strings.dart"

getters = """  static String get shopPerformanceReport => _translate('shopPerformanceReport', 'Shop Performance Report');
  static String get financialOverview => _translate('financialOverview', 'Financial Overview');
  static String get orderStatistics => _translate('orderStatistics', 'Order Statistics');
  static String get customerBase => _translate('customerBase', 'Customer Base');
  static String get securityAuditLogs => _translate('securityAuditLogs', 'Security & Audit Logs');
  static String get reportsLogs => _translate('reportsLogs', 'Reports & Logs');
  static String get generateShopReport => _translate('generateShopReport', 'Generate Shop Report');
  static String get viewSecurityLogs => _translate('viewSecurityLogs', 'View Security & Audit Logs');
  static String get whatsappNotInstalled => _translate('whatsappNotInstalled', 'WhatsApp not installed');
  static String get whatsappNotAvailable => _translate('whatsappNotAvailable', 'WhatsApp not available');
  static String get orderNotFound => _translate('orderNotFound', 'Order Not Found');
  static String get measurementsInches => _translate('measurementsInches', 'Measurements (inches)');
  static String get fromCustomerProfile => _translate('fromCustomerProfile', 'From customer profile');
  static String get noMeasurementsRecorded => _translate('noMeasurementsRecorded', 'No measurements recorded yet.');
  static String get paymentStatus => _translate('paymentStatus', 'Payment Status');
  static String get depositPaid => _translate('depositPaid', 'Deposit Paid');
  static String get invoice => _translate('invoice', 'Invoice');
  static String get startCutting => _translate('startCutting', 'Start Cutting');
  static String get markInProgress => _translate('markInProgress', 'Mark In Progress');
  static String get markAsReady => _translate('markAsReady', 'Mark as Ready');
  static String get markAsDelivered => _translate('markAsDelivered', 'Mark as Delivered');
  static String get updateStatus => _translate('updateStatus', 'Update Status');
  static String get selectStyleOptions => _translate('selectStyleOptions', 'Select style options for the garment');
  static String get pleaseSelectCustomer => _translate('pleaseSelectCustomer', 'Please select a customer');
  static String get pleaseSelectGarment => _translate('pleaseSelectGarment', 'Please select a garment type');
  static String get pleaseSelectDeliveryDate => _translate('pleaseSelectDeliveryDate', 'Please select a delivery date');
  static String get changeCustomer => _translate('changeCustomer', 'Change Customer');
  static String get quantity => _translate('quantity', 'Quantity');
  static String get urgentOrder => _translate('urgentOrder', 'Urgent Order');
  static String get pricing => _translate('pricing', 'Pricing');
  static String get totalPriceRs => _translate('totalPriceRs', 'Total Price (Rs.) *');
  static String get advanceRs => _translate('advanceRs', 'Advance (Rs.)');
  static String get balanceDue => _translate('balanceDue', 'Balance Due');
  static String get notes => _translate('notes', 'Notes');
  static String get fabricOrderNotes => _translate('fabricOrderNotes', 'Fabric / Order Notes');
  static String get enterValidAmount => _translate('enterValidAmount', 'Enter a valid amount');
  static String get error => _translate('error', 'Error');
  static String get fullBalancePopulated => _translate('fullBalancePopulated', 'Full balance is populated by default');
  static String get noCustomersYet => _translate('noCustomersYet', 'No customers yet');
  static String get addFirstCustomer => _translate('addFirstCustomer', 'Add your first customer');
  static String get measurementsSaved => _translate('measurementsSaved', 'Measurements saved ✓');
  static String get notFound => _translate('notFound', 'Not Found');
  static String get customerNotFound => _translate('customerNotFound', 'Customer not found');
  static String get noOrdersYet => _translate('noOrdersYet', 'No orders yet');
  static String get tapToAddMeasurements => _translate('tapToAddMeasurements', 'Tap to add measurements');
  static String get pleaseEnterCustomerName => _translate('pleaseEnterCustomerName', 'Please enter customer name');
  static String get pleaseEnterPhone => _translate('pleaseEnterPhone', 'Please enter phone number');
  static String get customerAddedSuccess => _translate('customerAddedSuccess', 'Customer added successfully! ✓');
  static String get premiumEmbroidery => _translate('premiumEmbroidery', 'Premium embroidery thread');
  static String get clear => _translate('clear', 'Clear');
  static String get searchCustomer => _translate('searchCustomer', 'Search Customer');
  static String get typeNameOrPhone => _translate('typeNameOrPhone', 'Type name or phone...');
  static String get dates => _translate('dates', 'Dates');
  static String get orderDate => _translate('orderDate', 'Order Date');
  static String get deliveryDate => _translate('deliveryDate', 'Delivery Date *');
  static String get garmentType => _translate('garmentType', 'Garment Type *');
  static String get createNewCustomer => _translate('createNewCustomer', 'Create New Customer');
  static String get customer => _translate('customer', 'Customer');
"""

translations = """    'shopPerformanceReport': 'دکان کی کارکردگی کی رپورٹ',
    'financialOverview': 'مالیاتی جائزہ',
    'orderStatistics': 'آرڈر کے اعداد و شمار',
    'customerBase': 'گاہکوں کی بنیاد',
    'securityAuditLogs': 'سیکیورٹی اور آڈٹ لاگ',
    'reportsLogs': 'رپورٹس اور لاگز',
    'generateShopReport': 'دکان کی رپورٹ تیار کریں',
    'viewSecurityLogs': 'سیکیورٹی اور آڈٹ لاگز دیکھیں',
    'whatsappNotInstalled': 'واٹس ایپ موجود نہیں ہے',
    'whatsappNotAvailable': 'واٹس ایپ دستیاب نہیں ہے',
    'orderNotFound': 'آرڈر نہیں ملا',
    'measurementsInches': 'ناپ (انچ)',
    'fromCustomerProfile': 'گاہک کی پروفائل سے',
    'noMeasurementsRecorded': 'ابھی تک کوئی ناپ درج نہیں ہوا۔',
    'paymentStatus': 'ادائیگی کی صورتحال',
    'depositPaid': 'ایڈوانس جمع شد',
    'invoice': 'رسید',
    'startCutting': 'کٹائی شروع کریں',
    'markInProgress': 'سلائی جاری ہے',
    'markAsReady': 'تیار ہے',
    'markAsDelivered': 'ڈلیور کر دیا گیا',
    'updateStatus': 'اسٹیٹس اپ ڈیٹ کریں',
    'selectStyleOptions': 'کپڑے کے ڈیزائن کا انتخاب کریں',
    'pleaseSelectCustomer': 'براہ کرم گاہک کا انتخاب کریں',
    'pleaseSelectGarment': 'براہ کرم کپڑے کی قسم کا انتخاب کریں',
    'pleaseSelectDeliveryDate': 'براہ کرم ڈلیوری کی تاریخ منتخب کریں',
    'changeCustomer': 'گاہک تبدیل کریں',
    'quantity': 'تعداد',
    'urgentOrder': 'ارجنٹ آرڈر',
    'pricing': 'قیمت',
    'totalPriceRs': 'کل قیمت (روپے) *',
    'advanceRs': 'ایڈوانس (روپے)',
    'balanceDue': 'بقایا رقم',
    'notes': 'نوٹس',
    'fabricOrderNotes': 'کپڑے / آرڈر کے نوٹس',
    'enterValidAmount': 'درست رقم درج کریں',
    'error': 'غلطی',
    'fullBalancePopulated': 'پوری بقایا رقم پہلے سے درج ہے',
    'noCustomersYet': 'ابھی تک کوئی گاہک نہیں',
    'addFirstCustomer': 'اپنا پہلا گاہک شامل کریں',
    'measurementsSaved': 'ناپ محفوظ ہو گئے ✓',
    'notFound': 'نہیں ملا',
    'customerNotFound': 'گاہک نہیں ملا',
    'noOrdersYet': 'ابھی تک کوئی آرڈر نہیں',
    'tapToAddMeasurements': 'ناپ شامل کرنے کے لیے یہاں دبائیں',
    'pleaseEnterCustomerName': 'براہ کرم گاہک کا نام درج کریں',
    'pleaseEnterPhone': 'براہ کرم فون نمبر درج کریں',
    'customerAddedSuccess': 'گاہک کامیابی سے شامل ہو گیا! ✓',
    'premiumEmbroidery': 'پریمیم کڑھائی کا دھاگہ',
    'clear': 'صاف کریں',
    'searchCustomer': 'گاہک تلاش کریں',
    'typeNameOrPhone': 'نام یا فون نمبر ٹائپ کریں...',
    'dates': 'تاریخیں',
    'orderDate': 'آرڈر کی تاریخ',
    'deliveryDate': 'ڈلیوری کی تاریخ *',
    'garmentType': 'کپڑے کی قسم *',
    'createNewCustomer': 'نیا گاہک بنائیں',
    'customer': 'گاہک',
"""

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Insert getters
target_getter = "  static String get comingSoon => _translate('comingSoon', 'Coming Soon');"
if target_getter in content:
    content = content.replace(target_getter, target_getter + "\\n\\n  // Additional Translations\\n" + getters)
else:
    print("Could not find target getter.")

# Insert translations
target_translation = "    'comingSoon': 'جلد آرہا ہے',"
if target_translation in content:
    content = content.replace(target_translation, target_translation + "\\n" + translations)
else:
    print("Could not find target translation.")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated strings.dart successfully!")
