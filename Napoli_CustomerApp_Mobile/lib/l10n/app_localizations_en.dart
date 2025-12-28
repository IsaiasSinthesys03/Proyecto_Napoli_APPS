// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pizzeria UI';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Enter your credentials to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get signInTab => 'SIGN IN';

  @override
  String get signUpTab => 'SIGN UP';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginAction => 'Login';

  @override
  String get registerAction => 'Register';

  @override
  String get homeAddress => 'Mexico City, Mexico';

  @override
  String get searchHint => 'SEARCH PIZZAS, PASTAS...';

  @override
  String get specialOffers => 'SPECIAL OFFERS';

  @override
  String get specialOfferDesc => '2x1 on selected pizzas';

  @override
  String get catAll => 'All';

  @override
  String get catPizzas => 'Pizzas';

  @override
  String get catPastas => 'Pastas';

  @override
  String get catDrinks => 'Drinks';

  @override
  String get catDesserts => 'Desserts';

  @override
  String get recommendations => 'Recommendations for you';

  @override
  String get fullMenu => 'Full Menu';

  @override
  String get cartTitle => 'My Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyDesc => 'Add delicious pizzas!';

  @override
  String get exploreMenu => 'Explore Menu';

  @override
  String get extrasLabel => 'Extras: ';

  @override
  String get estimatedTime => 'Estimated time: 25-35 min';

  @override
  String get couponHint => 'Coupon code';

  @override
  String get applyCoupon => 'Apply';

  @override
  String couponApplied(String code, String desc) {
    return 'Coupon $code applied: $desc';
  }

  @override
  String get enterCoupon => 'Please enter a coupon code';

  @override
  String get couponRemoved => 'Coupon removed';

  @override
  String get subtotal => 'Subtotal:';

  @override
  String get deliveryFee => 'Delivery:';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total:';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get appSettings => 'App Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Toggle between light and dark mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Configure push notifications';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'English';

  @override
  String get comingSoonLanguage => 'Coming soon: Language change';

  @override
  String get preferences => 'Preferences';

  @override
  String get savedAddresses => 'Saved Addresses';

  @override
  String get savedAddressesSubtitle => 'Manage delivery addresses';

  @override
  String get purchaseHistory => 'Purchase History';

  @override
  String get purchaseHistorySubtitle => 'View past orders and favorites';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get helpCenterSubtitle => 'FAQ and support';

  @override
  String get comingSoonHelp => 'Coming soon: Help center';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get logout => 'Logout';

  @override
  String get logoutSubtitle => 'Exit the application';

  @override
  String get aboutDescription => 'Pizza ordering app for Napoli Restaurant.';

  @override
  String get aboutFooter => 'Developed with Flutter and lots of ❤️';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get sessionClosed => 'Session closed';

  @override
  String get save => 'Save';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get photo => 'Photo';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get phone => 'Phone *';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get address => 'Main Address';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get photoPermissionTitle =>
      '\"Napoli Pizza\" wants to access your photos';

  @override
  String get photoPermissionDesc =>
      'So you can take or select a profile photo from your device.';

  @override
  String get deny => 'Deny';

  @override
  String get allow => 'Allow';

  @override
  String get photoPermissionNote => 'We will only access photos you select';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get takePhotoSubtitle => 'Use device camera';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get chooseGallerySubtitle => 'Select from your photos';

  @override
  String get useInitials => 'Use initials';

  @override
  String get useInitialsSubtitle => 'Revert to initials avatar';

  @override
  String get photoCaptured => 'Photo captured successfully';

  @override
  String get photoSelected => 'Photo selected from gallery';

  @override
  String get usingInitials => 'Using initials as avatar';

  @override
  String get myOrders => 'My Orders';

  @override
  String get noOrders => 'You haven\'t placed any orders';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String orderDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String orderItem(int quantity, String name) {
    return '${quantity}x $name';
  }

  @override
  String moreItems(int count) {
    return '+ $count more...';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Our chefs are preparing your food with love.';

  @override
  String get statusDelivering => 'Delivering';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get quantity => 'Quantity';

  @override
  String get customizeOrder => 'Customize your order';

  @override
  String get specialInstructions => 'Special Instructions';

  @override
  String get specialInstructionsHint => 'Ex: No onions, well done, etc.';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String errorProcessingOrder(String error) {
    return 'Error processing order: $error';
  }

  @override
  String get selectAddressOrManual =>
      'Please select a saved address or complete the address manually';

  @override
  String get enterPhoneNumber => 'Please complete the phone number';

  @override
  String get completeTransferData =>
      'Please complete the transfer data and attach the receipt';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String extras(String extras) {
    return 'Extras: $extras';
  }

  @override
  String discountWithCode(String code) {
    return 'Discount ($code):';
  }

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get change => 'Change';

  @override
  String get useDifferentAddress => 'Use different address';

  @override
  String get useSavedAddresses => 'Use saved addresses';

  @override
  String get phoneHint => 'Ex: +52 55 1234-5678';

  @override
  String get specialNotes => 'Special notes (optional)';

  @override
  String get specialNotesHint => 'Ex: Ring bell 3 times, leave at door, etc.';

  @override
  String get defaultLabel => 'Default';

  @override
  String get manualAddressInfo =>
      'Filling out an address different from your saved addresses';

  @override
  String get street => 'Street *';

  @override
  String get streetHint => 'Ex: Main Street';

  @override
  String get number => 'Number *';

  @override
  String get numberHint => 'Ex: 123';

  @override
  String get apartment => 'Apt/Dept (optional)';

  @override
  String get apartmentHint => 'Ex: Apt 5B';

  @override
  String get simulationMessage =>
      'This is a simulation payment. No charge will be made.';

  @override
  String get orderDelivered => 'Order Delivered!';

  @override
  String get rateExperience => 'How was your experience?';

  @override
  String get later => 'Later';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get exitTracking => 'Exit tracking?';

  @override
  String get exitTrackingMessage =>
      'Your order will continue in process. You can return at any time.';

  @override
  String get realTimeMap => 'Real-time map';

  @override
  String get yourDeliveryMan => 'Your delivery person';

  @override
  String get statusReceived => 'Thanks for your order! We are working on it.';

  @override
  String get statusOnWay => 'Almost there! Your food is on the way.';

  @override
  String get statusEnjoy => 'Enjoy your delicious food!';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get instructions => 'Instructions';

  @override
  String get transferInstructions =>
      'Make the transfer with the provided bank details and attach the receipt to confirm your order.';

  @override
  String get transferAmount => 'Amount to Transfer';

  @override
  String get bankData => 'Bank Details';

  @override
  String get bank => 'Bank';

  @override
  String get holder => 'Holder';

  @override
  String get clabe => 'CLABE';

  @override
  String get account => 'Account';

  @override
  String get concept => 'Concept';

  @override
  String get transferReceipt => 'Transfer Receipt';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get receiptAttached => 'Receipt Attached';

  @override
  String get receiptLoaded => 'Your receipt has been uploaded successfully';

  @override
  String get important =>
      'Important: Your order will be processed once we validate your transfer. This may take between 5 and 30 minutes.';

  @override
  String get confirmTransfer => 'Confirm Transfer';

  @override
  String get attachReceiptError => 'Please attach the transfer receipt';

  @override
  String clipboardCopied(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get imagePickerPlaceholder =>
      'Image function available when image_picker is installed';

  @override
  String get cameraPlaceholder =>
      'Camera function available when image_picker is installed';

  @override
  String get outOfHours => 'Out of Hours';

  @override
  String get bankDataUnavailable =>
      'Bank details are only available during our business hours.';

  @override
  String get nextOpening => 'Next opening:';

  @override
  String get back => 'Back';

  @override
  String get exit => 'Exit';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordMinLength => 'Minimum 6 characters';

  @override
  String get registerScreenTitle => 'Register';

  @override
  String get confirmPasswordRequired => 'Confirm your password';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get splashTitle => 'Napoli Pizzeria';

  @override
  String get splashSlogan => 'The best pizzas in town';

  @override
  String get general => 'General';

  @override
  String get permissionRequired =>
      'To receive notifications, you need to grant system permissions.';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get allNotificationsSubtitle => 'Enable or disable all notifications';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderUpdatesSubtitle => 'Order status and deliveries';

  @override
  String get promotions => 'Promotions';

  @override
  String get promotionsSubtitle => 'Discounts and special offers';

  @override
  String get newProducts => 'New Products';

  @override
  String get newProductsSubtitle => 'Alerts for new menu products';

  @override
  String get deliveryReminders => 'Delivery Reminders';

  @override
  String get deliveryRemindersSubtitle => 'Alerts when order is nearby';

  @override
  String get chatMessages => 'Chat Messages';

  @override
  String get chatMessagesSubtitle => 'Customer service notifications';

  @override
  String get weeklyOffers => 'Weekly Offers';

  @override
  String get weeklyOffersSubtitle => 'Special weekend promotions';

  @override
  String get appUpdates => 'App Updates';

  @override
  String get appUpdatesSubtitle => 'New versions and features';

  @override
  String get soundVibration => 'Sound & Vibration';

  @override
  String get sound => 'Sound';

  @override
  String get soundSubtitle => 'Play sound with notifications';

  @override
  String get notificationTone => 'Notification Tone';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Vibrate with notifications';

  @override
  String get doNotDisturb => 'Do Not Disturb';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get quietHoursSubtitle =>
      'Do not receive notifications during certain hours';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get importantNotificationsInfo =>
      'Important notifications like order updates will always be shown, even in silent mode.';

  @override
  String get defaultTone => 'Default';

  @override
  String get bellTone => 'Bell';

  @override
  String get chimeTone => 'Chime';

  @override
  String get selectTone => 'Select Tone';

  @override
  String get notificationLabel => 'Notification';

  @override
  String get addAddress => 'Add Address';

  @override
  String get noSavedAddresses => 'No saved addresses';

  @override
  String get noSavedAddressesDesc => 'Add addresses to order faster';

  @override
  String get addFirstAddress => 'Add First Address';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAddressTitle => 'Delete address';

  @override
  String deleteAddressConfirmation(String label) {
    return 'Are you sure you want to delete \"$label\"?';
  }

  @override
  String addressDeleted(String label) {
    return 'Address \"$label\" deleted';
  }

  @override
  String get editAddressTitle => 'Edit Address';

  @override
  String get addAddressTitle => 'Add Address';

  @override
  String get labelLabel => 'Label *';

  @override
  String get labelHint => 'Ex: Home, Work, University, etc.';

  @override
  String get addressLabel => 'Address *';

  @override
  String get addressHint => 'Street, number, colony';

  @override
  String get cityLabel => 'City *';

  @override
  String get cityHint => 'City, State';

  @override
  String get detailsLabel => 'Additional details';

  @override
  String get detailsHint => 'References, house color, etc.';

  @override
  String get setAsDefaultLabel => 'Set as default';

  @override
  String get updateAction => 'Update';

  @override
  String get addAction => 'Add';

  @override
  String get addressUpdated => 'Address updated';

  @override
  String get addressAdded => 'Address added';

  @override
  String addressSetAsDefault(String label) {
    return '$label is now your default address';
  }

  @override
  String get paymentMethodsTitle => 'Payment Methods';

  @override
  String get addCard => 'Add Card';

  @override
  String get noPaymentMethods => 'No payment methods';

  @override
  String get noPaymentMethodsDesc => 'Add a card to pay faster';

  @override
  String get addFirstCard => 'Add First Card';

  @override
  String get alternativeMethods => 'Alternative Methods';

  @override
  String get cash => 'Cash';

  @override
  String get cashSubtitle => 'Pay upon delivery';

  @override
  String get cashAvailable => 'Cash payment available upon ordering';

  @override
  String get bankTransferSubtitle => 'SPEI and instant transfers';

  @override
  String get bankTransferComingSoon => 'Coming Soon: Transfer payments';

  @override
  String get cardHolderLabel => 'CARD HOLDER';

  @override
  String get expiryLabel => 'EXPIRES';

  @override
  String get deletePaymentMethodTitle => 'Delete payment method';

  @override
  String deletePaymentMethodConfirmation(String brand, String last4) {
    return 'Are you sure you want to delete the $brand card ending in $last4?';
  }

  @override
  String paymentMethodDeleted(String brand) {
    return 'Card $brand deleted';
  }

  @override
  String get editCardTitle => 'Edit Card';

  @override
  String get addCardTitle => 'Add Card';

  @override
  String get cardNumberLabel => 'Card number *';

  @override
  String get cardHolderNameLabel => 'Cardholder name *';

  @override
  String get expiryDateLabel => 'Expiry *';

  @override
  String get cvvLabel => 'CVV *';

  @override
  String get securityInfo =>
      'Your data is protected with bank-level encryption';

  @override
  String get cardUpdated => 'Card updated';

  @override
  String get cardAdded => 'Card added successfully';

  @override
  String cardSetAsDefault(String brand, String last4) {
    return '$brand ending in $last4 is now default';
  }

  @override
  String get purchaseHistoryTitle => 'Purchase History';

  @override
  String get recentTab => 'Recent';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get filterAll => 'All';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get filterInProgress => 'In Progress';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get noOrdersInProgress => 'No orders in progress';

  @override
  String get noOrdersCancelled => 'No cancelled orders';

  @override
  String get noOrdersDelivered => 'No delivered orders';

  @override
  String get ordersEmptyDesc => 'When you place orders they will appear here';

  @override
  String moreProducts(int count) {
    return '+ $count more product(s)';
  }

  @override
  String get totalLabel => 'Total: ';

  @override
  String get rateOrder => 'Rate order';

  @override
  String yourRating(int rating) {
    return 'Your rating: $rating/5';
  }

  @override
  String get trackOrder => 'Track';

  @override
  String get orderAgain => 'Order Again';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String orderedTimes(int count) {
    return 'Ordered $count times';
  }

  @override
  String get yourFavorites => 'Your Favorites';

  @override
  String get favoritesDesc => 'Products you\'ve ordered more than once';

  @override
  String get orderFavorites => 'Order My Favorites';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String get confirmTitle => 'Confirm';

  @override
  String get clearHistoryConfirmation =>
      'Do you want to clear all coupon history?';

  @override
  String get clearAll => 'Clear All';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get discount10 => '10% discount';

  @override
  String get discount20 => '20% discount';

  @override
  String get discount50 => '50% discount';

  @override
  String get specialCoupon => 'Special Coupon';

  @override
  String get myCoupons => 'My Coupons';

  @override
  String get clearHistoryTooltip => 'Clear history';

  @override
  String get noCouponsTitle => 'You haven\'t won any coupons yet';

  @override
  String get noCouponsSubtitle => 'Use \"Scratch & Win\" to get coupons';

  @override
  String couponsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coupons',
      one: '1 coupon',
    );
    return 'You have won $_temp0';
  }

  @override
  String wonDate(String date) {
    return 'Won: $date';
  }

  @override
  String get activeStatus => 'Active';

  @override
  String get mapViewTitle => 'Map View';

  @override
  String get mapsDisabled => '(Google Maps integration disabled)';

  @override
  String get errorTitle => 'Error';

  @override
  String get noProductsAvailable => 'No products available at the moment';
}
