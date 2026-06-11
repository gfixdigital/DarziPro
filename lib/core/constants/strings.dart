import '../services/hive_service.dart';

/// Darzi Pro — String Constants
class AppStrings {
  AppStrings._();

  static String _translate(String key, String englishVal) {
    try {
      if (HiveService.language == 'ur') {
        return _urduTranslations[key] ?? englishVal;
      }
    } catch (_) {}
    return englishVal;
  }

  // App
  static String get appName => _translate('appName', 'Darzi Pro');
  static String get appTagline => _translate('appTagline', 'Welcome back. Let\'s get to work.');
  static String get appFooter => _translate('appFooter', 'Crafted for precision. Built for professionals.');
  static const appVersion = 'v1.0.0';

  // Auth
  static String get loginTitle => _translate('loginTitle', 'Login');
  static String get loginButton => _translate('loginButton', 'Login');
  static String get phonePlaceholder => _translate('phonePlaceholder', 'Phone Number');
  static String get passwordPlaceholder => _translate('passwordPlaceholder', 'Password');
  static const phonePrefix = '+92';

  // Dashboard
  static String get dashboard => _translate('dashboard', 'Dashboard');
  static String get todaysOrders => _translate('todaysOrders', 'Today\'s Orders');
  static String get pendingDelivery => _translate('pendingDelivery', 'Pending Delivery');
  static String get paymentsDue => _translate('paymentsDue', 'Payments Due');
  static String get recentOrders => _translate('recentOrders', 'Recent Orders');
  static String get newOrder => _translate('newOrder', 'New Order');
  static String get addCustomer => _translate('addCustomer', 'Add Customer');

  // Orders
  static String get orders => _translate('orders', 'Orders');
  static String get ordersSubtitle => _translate('ordersSubtitle', 'Manage your active tailoring projects.');
  static String get orderDetails => _translate('orderDetails', 'Order Details');
  static String get newOrderTitle => _translate('newOrderTitle', 'New Order');
  static String get collectPayment => _translate('collectPayment', 'Collect Payment');

  // Order Statuses
  static String get allActive => _translate('allActive', 'All Active');
  static String get pending => _translate('pending', 'Pending');
  static String get cutting => _translate('cutting', 'Cutting');
  static String get inProgress => _translate('inProgress', 'In Progress');
  static String get ready => _translate('ready', 'Ready');
  static String get delivered => _translate('delivered', 'Delivered');

  // Garment Types
  static String get kameezShalwar => _translate('kameezShalwar', 'Kameez Shalwar');
  static String get waistcoat => _translate('waistcoat', 'Waistcoat');
  static String get suit2Piece => _translate('suit2Piece', 'Suit (2 Piece)');

  // New Order Steps
  static String get step1Title => _translate('step1Title', 'Order Info');
  static String get step2Title => _translate('step2Title', 'Measurements');
  static String get step3Title => _translate('step3Title', 'Style Preferences');
  static String get nextMeasurements => _translate('nextMeasurements', 'Next: Measurements →');
  static String get nextDetails => _translate('nextDetails', 'Next: Details →');
  static String get saveOrder => _translate('saveOrder', 'Save Order');

  // Measurements
  static String get addMeasurements => _translate('addMeasurements', 'Add Measurements');
  static String get measurementsSubtitle => _translate('measurementsSubtitle', 'Enter measurements in inches');
  static String get kameezLength => _translate('kameezLength', 'Kameez Length');
  static String get sleeve => _translate('sleeve', 'Sleeve');
  static String get shoulder => _translate('shoulder', 'Shoulder');
  static String get neck => _translate('neck', 'Neck');
  static String get chest => _translate('chest', 'Chest');
  static String get waist => _translate('waist', 'Waist');
  static String get hem => _translate('hem', 'Hem');
  static String get shalwarLength => _translate('shalwarLength', 'Shalwar Length');
  static String get legOpening => _translate('legOpening', 'Leg Opening');
  static String get cuff => _translate('cuff', 'Cuff');
  static String get fitNotes => _translate('fitNotes', 'Fit Notes');

  // Style Preferences
  static String get collar => _translate('collar', 'Collar');
  static String get pockets => _translate('pockets', 'Pockets');
  static String get daman => _translate('daman', 'Daman');
  static String get cuffs => _translate('cuffs', 'Cuffs');
  static String get silkThread => _translate('silkThread', 'Silk Thread');
  static String get stitching => _translate('stitching', 'Stitching');
  static String get buttons => _translate('buttons', 'Buttons');
  static String get suitStyle => _translate('suitStyle', 'Suit Style Features');
  static String get shalwarStyle => _translate('shalwarStyle', 'Shalwar Style');

  // Customers
  static String get customers => _translate('customers', 'Clients');
  static String get customersSubtitle => _translate('customersSubtitle', 'Manage your customer measurements and order history.');
  static String get addNewCustomer => _translate('addNewCustomer', 'Add New Customer');
  static String get customerProfile => _translate('customerProfile', 'Customer Profile');
  static String get editMeasurements => _translate('editMeasurements', 'Edit Measurements');
  static String get orderHistory => _translate('orderHistory', 'Order History');
  static String get savedMeasurements => _translate('savedMeasurements', 'Saved Measurements');

  // Settings
  static String get settings => _translate('settings', 'Settings');
  static String get settingsSubtitle => _translate('settingsSubtitle', 'Manage your shop preferences and account details.');
  static String get profileInfo => _translate('profileInfo', 'Profile Information');
  static String get preferences => _translate('preferences', 'Preferences');
  static String get notifications => _translate('notifications', 'Notifications');
  static String get syncStatus => _translate('syncStatus', 'Sync Status');
  static String get saveChanges => _translate('saveChanges', 'Save Changes');
  static String get logOut => _translate('logOut', 'Log Out');
  static String get syncNow => _translate('syncNow', 'Sync Now');

  // Settings Fields
  static String get shopName => _translate('shopName', 'Shop Name');
  static String get ownerName => _translate('ownerName', 'Owner Name');
  static String get contactNumber => _translate('contactNumber', 'Contact Number');
  static String get appLanguage => _translate('appLanguage', 'Application Language');
  static String get currencyFormat => _translate('currencyFormat', 'Currency Format');
  static String get newOrderAlerts => _translate('newOrderAlerts', 'New Order Alerts');
  static String get measurementReminders => _translate('measurementReminders', 'Measurement Reminders');
  static String get dailySummary => _translate('dailySummary', 'Daily Summary');
  static String get lastSync => _translate('lastSync', 'Last sync');
  static String get neverSynced => _translate('neverSynced', 'Never synced');
  static String get changesPending => _translate('changesPending', 'changes pending');
  static String get logoutConfirm => _translate('logoutConfirm', 'Are you sure you want to log out?');

  // Payment
  static String get totalAmount => _translate('totalAmount', 'Total Amount');
  static String get advancePaid => _translate('advancePaid', 'Advance Paid');
  static String get remainingBalance => _translate('remainingBalance', 'Remaining Balance');
  static String get markAsPaid => _translate('markAsPaid', 'Mark as Paid ✓');
  static String get enterAmountReceived => _translate('enterAmountReceived', 'Enter Amount Received');

  // General
  static String get save => _translate('save', 'Save');
  static String get cancel => _translate('cancel', 'Cancel');
  static String get delete => _translate('delete', 'Delete');
  static String get edit => _translate('edit', 'Edit');
  static String get back => _translate('back', 'Back');
  static String get search => _translate('search', 'Search');
  static String get noData => _translate('noData', 'No data available');
  static String get loading => _translate('loading', 'Loading...');
  static String get offline => _translate('offline', 'You\'re offline — changes will sync when connected');
  static String get syncing => _translate('syncing', 'Syncing...');
  static String get syncPending => _translate('syncPending', 'Some changes pending sync');
  static String get comingSoon => _translate('comingSoon', 'Coming Soon');

  static String get deliveryToday => _translate('deliveryToday', 'Delivery Today');
  static String get deliveryTomorrow => _translate('deliveryTomorrow', 'Delivery Tomorrow');
  static String get pendingSync => _translate('pendingSync', 'Pending Sync');
  static String get viewAll => _translate('viewAll', 'View All');
  static String get createFirstOrder => _translate('createFirstOrder', 'Create your first order to get started');
  static String get client => _translate('client', 'Client');
  static String get goodMorning => _translate('goodMorning', 'Good Morning');
  static String get goodAfternoon => _translate('goodAfternoon', 'Good Afternoon');
  static String get goodEvening => _translate('goodEvening', 'Good Evening');
  static String get noNewNotifications => _translate('noNewNotifications', 'No new notifications');
  static String get offlineSync => _translate('offlineSync', 'You\'re offline — changes will sync when connected');
  static String get unknownCustomer => _translate('unknownCustomer', 'Unknown Customer');
  static String get overdue => _translate('overdue', 'Overdue');
  static String get dueToday => _translate('dueToday', 'Due Today');
  static String get due => _translate('due', 'Due');
  static String get awaitingCustomer => _translate('awaitingCustomer', 'Awaiting Customer');
  static String get lastOrder => _translate('lastOrder', 'LAST ORDER');
  static String get vip => _translate('vip', 'VIP');

  // Additional Translations
  static String get shopPerformanceReport => _translate('shopPerformanceReport', 'Shop Performance Report');
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

  // WhatsApp
  static String whatsAppMessage(String name, String orderNumber) {
    if (HiveService.language == 'ur') {
      return 'السلام علیکم $name! 🎉 آپ کا آرڈر نمبر #$orderNumber تیار ہے۔ براہ کرم جلد از جلد اپنی دکان سے وصول کریں۔ شکریہ! — درزی پرو';
    }
    return 'Assalamu Alaikum $name! 🎉 Your order #$orderNumber is ready for pickup. '
        'Please visit our shop at your earliest convenience. '
        'Thank you! — Darzi Pro';
  }

  static const Map<String, String> _urduTranslations = {
    'appName': 'درزی پرو',
    'appTagline': 'خوش آمدید۔ چلیے کام شروع کریں۔',
    'appFooter': 'شاندار سلائی۔ پیشہ ور افراد کے لیے۔',
    'loginTitle': 'لاگ ان',
    'loginButton': 'لاگ ان',
    'phonePlaceholder': 'فون نمبر',
    'passwordPlaceholder': 'پاس ورڈ',
    'dashboard': 'ڈیش بورڈ',
    'todaysOrders': 'آج کے آرڈر',
    'pendingDelivery': 'باقی ڈلیوری',
    'paymentsDue': 'باقی ادائیگی',
    'recentOrders': 'حالیہ آرڈر',
    'newOrder': 'نیا آرڈر',
    'addCustomer': 'گاہک شامل کریں',
    'orders': 'آرڈر',
    'ordersSubtitle': 'اپنے فعال سلائی کے کاموں کا انتظام کریں۔',
    'orderDetails': 'آرڈر کی تفصیلات',
    'newOrderTitle': 'نیا آرڈر',
    'collectPayment': 'ادائیگی وصول کریں',
    'allActive': 'تمام فعال',
    'pending': 'باقی ہے',
    'cutting': 'کٹائی',
    'inProgress': 'سلائی جاری',
    'ready': 'تیار ہے',
    'delivered': 'ڈلیور ہو گیا',
    'kameezShalwar': 'قمیض شلوار',
    'waistcoat': 'واسکٹ',
    'suit2Piece': 'کوٹ پینٹ (2 پیس)',
    'step1Title': 'آرڈر معلومات',
    'step2Title': 'ناپ',
    'step3Title': 'ڈیزائن ترجیحات',
    'nextMeasurements': 'اگلا: ناپ ←',
    'nextDetails': 'اگلا: تفصیلات ←',
    'saveOrder': 'آرڈر محفوظ کریں',
    'addMeasurements': 'ناپ شامل کریں',
    'measurementsSubtitle': 'انچ میں ناپ درج کریں',
    'kameezLength': 'قمیض لمبائی',
    'sleeve': 'آستین',
    'shoulder': 'تیرا',
    'neck': 'گلا / کالر',
    'chest': 'چھاتی',
    'waist': 'کمر',
    'hem': 'گھیرا',
    'shalwarLength': 'شلوار لمبائی',
    'legOpening': 'پانچہ',
    'cuff': 'کف',
    'fitNotes': 'فٹنگ نوٹ',
    'collar': 'کالر / بین',
    'pockets': 'جیب',
    'daman': 'دامن',
    'cuffs': 'کف',
    'silkThread': 'ریشمی دھاگہ',
    'stitching': 'سلائی',
    'buttons': 'بٹن',
    'suitStyle': 'سوٹ ڈیزائن خصوصیات',
    'shalwarStyle': 'شلوار کا ڈیزائن',
    'customers': 'گاہک',
    'customersSubtitle': 'گاہکوں کے ناپ اور آرڈر ہسٹری کا انتظام کریں۔',
    'addNewCustomer': 'نیا گاہک شامل کریں',
    'customerProfile': 'گاہک کی پروفائل',
    'editMeasurements': 'ناپ تبدیل کریں',
    'orderHistory': 'آرڈرز کی تاریخ',
    'savedMeasurements': 'محفوظ شدہ ناپ',
    'settings': 'سیٹنگز',
    'settingsSubtitle': 'دکان کی معلومات اور اکاؤنٹ کا انتظام کریں۔',
    'profileInfo': 'پروفائل معلومات',
    'preferences': 'ترجیحات',
    'notifications': 'نوٹیفیکیشنز',
    'syncStatus': 'سنک کی حالت',
    'saveChanges': 'تبدیلیاں محفوظ کریں',
    'logOut': 'لاگ آؤٹ',
    'syncNow': 'ابھی سنک کریں',
    'shopName': 'دکان کا نام',
    'ownerName': 'مالک کا نام',
    'contactNumber': 'رابطہ نمبر',
    'appLanguage': 'ایپلی کیشن کی زبان',
    'currencyFormat': 'کرنسی کی قسم',
    'newOrderAlerts': 'نئے آرڈر کے الرٹس',
    'measurementReminders': 'ناپ کی یاد دہانی',
    'dailySummary': 'روزانہ کی رپورٹ',
    'lastSync': 'آخری سنک',
    'neverSynced': 'کبھی سنک نہیں ہوا',
    'changesPending': 'تبدیلیاں باقی ہیں',
    'logoutConfirm': 'کیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟',
    'totalAmount': 'کل رقم',
    'advancePaid': 'پیشگی رقم (ایڈوانس)',
    'remainingBalance': 'باقی رقم',
    'markAsPaid': 'مکمل ادائیگی ✓',
    'enterAmountReceived': 'وصول شدہ رقم درج کریں',
    'save': 'محفوظ کریں',
    'cancel': 'منسوخ کریں',
    'delete': 'حذف کریں',
    'edit': 'تبدیل کریں',
    'back': 'واپس',
    'search': 'تلاش کریں',
    'noData': 'کوئی ڈیٹا موجود نہیں ہے',
    'loading': 'لوڈنگ جاری ہے...',
    'offline': 'آپ آف لائن ہیں - انٹرنیٹ آنے پر سنک ہو جائے گا',
    'syncing': 'سنک ہو رہا ہے...',
    'syncPending': 'کچھ تبدیلیاں سنک ہونا باقی ہیں',
    'comingSoon': 'جلد آرہا ہے',
    'shopPerformanceReport': 'دکان کی کارکردگی کی رپورٹ',
    'deliveryToday': 'آج ڈلیوری ہے',
    'deliveryTomorrow': 'کل ڈلیوری ہے',
    'pendingSync': 'باقی سنک',
    'viewAll': 'سب دیکھیں',
    'createFirstOrder': 'شروع کرنے کے لیے اپنا پہلا آرڈر بنائیں',
    'goodMorning': 'صبح بخیر',
    'goodAfternoon': 'سہ پہر بخیر',
    'goodEvening': 'شب بخیر',
    'noNewNotifications': 'کوئی نئی نوٹیفیکیشن نہیں ہے',
    'client': 'گاہک',
    'offlineSync': 'آپ آف لائن ہیں — منسلک ہونے پر تبدیلیاں سنک ہوں گی',
    'unknownCustomer': 'نامعلوم گاہک',
    'overdue': 'تاخیر کا شکار',
    'dueToday': 'آج ڈلیوری ہے',
    'due': 'ڈلیوری',
    'awaitingCustomer': 'گاہک کا انتظار ہے',
    'lastOrder': 'آخری آرڈر',
    'vip': 'وی آئی پی',
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
  };
}
