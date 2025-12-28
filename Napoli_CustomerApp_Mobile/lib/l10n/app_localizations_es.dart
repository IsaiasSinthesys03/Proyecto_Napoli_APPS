// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pizzeria UI';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Ingresa tus credenciales para continuar';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get register => 'Regístrate';

  @override
  String get welcomeTo => 'Bienvenido a';

  @override
  String get signInTab => 'INICIAR';

  @override
  String get signUpTab => 'REGISTRARSE';

  @override
  String get nameLabel => 'Nombre completo';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get orLoginWith => 'O inicia sesión con';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get loginAction => 'Inicia sesión';

  @override
  String get registerAction => 'Regístrate';

  @override
  String get homeAddress => 'Ciudad de México, México';

  @override
  String get searchHint => 'BUSCAR PIZZAS, PASTAS...';

  @override
  String get specialOffers => 'OFERTAS ESPECIALES';

  @override
  String get specialOfferDesc => '2x1 en pizzas seleccionadas';

  @override
  String get catAll => 'Todos';

  @override
  String get catPizzas => 'Pizzas';

  @override
  String get catPastas => 'Pastas';

  @override
  String get catDrinks => 'Bebidas';

  @override
  String get catDesserts => 'Postres';

  @override
  String get recommendations => 'Recomendaciones para ti';

  @override
  String get fullMenu => 'Menú Completo';

  @override
  String get cartTitle => 'Mi Carrito';

  @override
  String get cartEmpty => 'Tu carrito está vacío';

  @override
  String get cartEmptyDesc => '¡Agrega deliciosas pizzas!';

  @override
  String get exploreMenu => 'Explorar menú';

  @override
  String get extrasLabel => 'Extras: ';

  @override
  String get estimatedTime => 'Tiempo estimado: 25-35 min';

  @override
  String get couponHint => 'Código de cupón';

  @override
  String get applyCoupon => 'Aplicar';

  @override
  String couponApplied(String code, String desc) {
    return 'Cupón $code aplicado: $desc';
  }

  @override
  String get enterCoupon => 'Por favor ingresa un código de cupón';

  @override
  String get couponRemoved => 'Cupón eliminado';

  @override
  String get subtotal => 'Subtotal:';

  @override
  String get deliveryFee => 'Envío:';

  @override
  String get discount => 'Descuento';

  @override
  String get total => 'Total:';

  @override
  String get confirmOrder => 'Confirmar Pedido';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get appSettings => 'Configuración de la App';

  @override
  String get darkMode => 'Tema Oscuro';

  @override
  String get darkModeSubtitle => 'Cambiar entre tema claro y oscuro';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Configurar notificaciones push';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Español';

  @override
  String get comingSoonLanguage => 'Próximamente: Cambio de idioma';

  @override
  String get preferences => 'Preferencias';

  @override
  String get savedAddresses => 'Direcciones Guardadas';

  @override
  String get savedAddressesSubtitle => 'Gestionar direcciones de entrega';

  @override
  String get purchaseHistory => 'Historial de Compras';

  @override
  String get purchaseHistorySubtitle => 'Ver pedidos anteriores y favoritos';

  @override
  String get helpSupport => 'Ayuda y Soporte';

  @override
  String get helpCenter => 'Centro de Ayuda';

  @override
  String get helpCenterSubtitle => 'Preguntas frecuentes y soporte';

  @override
  String get comingSoonHelp => 'Próximamente: Centro de ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutSubtitle => 'Salir de la aplicación';

  @override
  String get aboutDescription =>
      'Aplicación de pedidos de pizza para Napoli Restaurant.';

  @override
  String get aboutFooter => 'Desarrollado con Flutter y mucho ❤️';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get sessionClosed => 'Sesión cerrada';

  @override
  String get save => 'Guardar';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get photo => 'Foto';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailRequired => 'El email es requerido';

  @override
  String get emailInvalid => 'Ingresa un email válido';

  @override
  String get phone => 'Teléfono *';

  @override
  String get phoneRequired => 'El teléfono es requerido';

  @override
  String get address => 'Dirección principal';

  @override
  String get addressRequired => 'La dirección es requerida';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente';

  @override
  String get photoPermissionTitle =>
      '\"Napoli Pizza\" quiere acceder a tus fotos';

  @override
  String get photoPermissionDesc =>
      'Para que puedas tomar o seleccionar una foto de perfil desde tu dispositivo.';

  @override
  String get deny => 'No permitir';

  @override
  String get allow => 'Permitir';

  @override
  String get photoPermissionNote =>
      'Solo accederemos a las fotos que selecciones';

  @override
  String get changeProfilePhoto => 'Cambiar foto de perfil';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get takePhotoSubtitle => 'Usar la cámara del dispositivo';

  @override
  String get chooseGallery => 'Elegir de galería';

  @override
  String get chooseGallerySubtitle => 'Seleccionar de tus fotos';

  @override
  String get useInitials => 'Usar iniciales';

  @override
  String get useInitialsSubtitle => 'Volver al avatar con iniciales';

  @override
  String get photoCaptured => 'Foto capturada con éxito';

  @override
  String get photoSelected => 'Foto seleccionada de galería';

  @override
  String get usingInitials => 'Usando iniciales como avatar';

  @override
  String get myOrders => 'Mis Pedidos';

  @override
  String get noOrders => 'No has realizado ningún pedido';

  @override
  String orderNumber(String id) {
    return 'Pedido #$id';
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
    return '+ $count más...';
  }

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusPreparing =>
      'Nuestros chefs están preparando tu comida con amor.';

  @override
  String get statusDelivering => 'En camino';

  @override
  String get statusCompleted => 'Entregado';

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String get addedToCart => 'Añadido al carrito';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get quantity => 'Cantidad';

  @override
  String get customizeOrder => 'Personaliza tu pedido';

  @override
  String get specialInstructions => 'Instrucciones especiales';

  @override
  String get specialInstructionsHint => 'Ej: Sin cebolla, bien cocida, etc.';

  @override
  String get addToCart => 'Añadir al carrito';

  @override
  String errorProcessingOrder(String error) {
    return 'Error al procesar el pedido: $error';
  }

  @override
  String get selectAddressOrManual =>
      'Por favor selecciona una dirección guardada o completa la dirección manualmente';

  @override
  String get enterPhoneNumber => 'Por favor completa el número de teléfono';

  @override
  String get completeTransferData =>
      'Por favor completa los datos de transferencia y adjunta el comprobante';

  @override
  String get orderSummary => 'Resumen del Pedido';

  @override
  String extras(String extras) {
    return 'Extras: $extras';
  }

  @override
  String discountWithCode(String code) {
    return 'Descuento ($code):';
  }

  @override
  String get deliveryAddress => 'Dirección de Envío';

  @override
  String get change => 'Cambiar';

  @override
  String get useDifferentAddress => 'Usar dirección diferente';

  @override
  String get useSavedAddresses => 'Usar direcciones guardadas';

  @override
  String get phoneHint => 'Ej: +52 55 1234-5678';

  @override
  String get specialNotes => 'Notas especiales (opcional)';

  @override
  String get specialNotesHint =>
      'Ej: Tocar timbre 3 veces, dejar en puerta, etc.';

  @override
  String get defaultLabel => 'Predeterminada';

  @override
  String get manualAddressInfo =>
      'Completando una dirección diferente a tus direcciones guardadas';

  @override
  String get street => 'Calle *';

  @override
  String get streetHint => 'Ej: Calle Principal';

  @override
  String get number => 'Número *';

  @override
  String get numberHint => 'Ej: 123';

  @override
  String get apartment => 'Apto/Depto (opcional)';

  @override
  String get apartmentHint => 'Ej: Apto 5B';

  @override
  String get simulationMessage =>
      'Este es un pago de simulación. No se realizará ningún cargo.';

  @override
  String get orderDelivered => '¡Pedido Entregado!';

  @override
  String get rateExperience => '¿Cómo fue tu experiencia?';

  @override
  String get later => 'Más tarde';

  @override
  String get orderStatus => 'Estado del Pedido';

  @override
  String get exitTracking => '¿Salir del seguimiento?';

  @override
  String get exitTrackingMessage =>
      'Tu pedido seguirá en proceso. Puedes volver en cualquier momento.';

  @override
  String get realTimeMap => 'Mapa en tiempo real';

  @override
  String get yourDeliveryMan => 'Tu repartidor';

  @override
  String get statusReceived =>
      '¡Gracias por tu pedido! Estamos trabajando en ello.';

  @override
  String get statusOnWay => '¡Ya casi llega! Tu comida está en camino.';

  @override
  String get statusEnjoy => '¡Disfruta tu comida deliciosa!';

  @override
  String get bankTransfer => 'Transferencia Bancaria';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get transferInstructions =>
      'Realiza la transferencia con los datos bancarios proporcionados y adjunta el comprobante para confirmar tu pedido.';

  @override
  String get transferAmount => 'Monto a Transferir';

  @override
  String get bankData => 'Datos Bancarios';

  @override
  String get bank => 'Banco';

  @override
  String get holder => 'Titular';

  @override
  String get clabe => 'CLABE';

  @override
  String get account => 'Cuenta';

  @override
  String get concept => 'Concepto';

  @override
  String get transferReceipt => 'Comprobante de Transferencia';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get receiptAttached => 'Comprobante Adjuntado';

  @override
  String get receiptLoaded => 'Tu comprobante ha sido cargado correctamente';

  @override
  String get important =>
      'Importante: Tu pedido será procesado una vez que validemos tu transferencia. Esto puede tardar entre 5 y 30 minutos.';

  @override
  String get confirmTransfer => 'Confirmar Transferencia';

  @override
  String get attachReceiptError =>
      'Por favor adjunta el comprobante de transferencia';

  @override
  String clipboardCopied(String label) {
    return '$label copiado al portapapeles';
  }

  @override
  String get imagePickerPlaceholder =>
      'Función de imagen disponible cuando se instale image_picker';

  @override
  String get cameraPlaceholder =>
      'Función de cámara disponible cuando se instale image_picker';

  @override
  String get outOfHours => 'Fuera de Horario';

  @override
  String get bankDataUnavailable =>
      'Los datos bancarios solo están disponibles durante nuestro horario de atención.';

  @override
  String get nextOpening => 'Próxima apertura:';

  @override
  String get back => 'Volver';

  @override
  String get exit => 'Salir';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get passwordMinLength => 'Mínimo 6 caracteres';

  @override
  String get registerScreenTitle => 'Registrarse';

  @override
  String get confirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get createAccount => 'CREAR CUENTA';

  @override
  String get splashTitle => 'Napoli Pizzeria';

  @override
  String get splashSlogan => 'Las mejores pizzas de la ciudad';

  @override
  String get general => 'General';

  @override
  String get permissionRequired =>
      'Para recibir notificaciones, necesitas otorgar permisos del sistema.';

  @override
  String get allNotifications => 'Todas las Notificaciones';

  @override
  String get allNotificationsSubtitle =>
      'Activar o desactivar todas las notificaciones';

  @override
  String get notificationTypes => 'Tipos de Notificaciones';

  @override
  String get orderUpdates => 'Actualizaciones de Pedidos';

  @override
  String get orderUpdatesSubtitle => 'Estados del pedido y entregas';

  @override
  String get promotions => 'Promociones';

  @override
  String get promotionsSubtitle => 'Descuentos y ofertas especiales';

  @override
  String get newProducts => 'Nuevos Productos';

  @override
  String get newProductsSubtitle => 'Alertas de nuevos productos en el menú';

  @override
  String get deliveryReminders => 'Recordatorios de Entrega';

  @override
  String get deliveryRemindersSubtitle => 'Alertas cuando el pedido está cerca';

  @override
  String get chatMessages => 'Mensajes de Chat';

  @override
  String get chatMessagesSubtitle => 'Notificaciones del servicio al cliente';

  @override
  String get weeklyOffers => 'Ofertas Semanales';

  @override
  String get weeklyOffersSubtitle => 'Promociones especiales de fin de semana';

  @override
  String get appUpdates => 'Actualizaciones de App';

  @override
  String get appUpdatesSubtitle => 'Nuevas versiones y características';

  @override
  String get soundVibration => 'Sonido y Vibración';

  @override
  String get sound => 'Sonido';

  @override
  String get soundSubtitle => 'Reproducir sonido con las notificaciones';

  @override
  String get notificationTone => 'Tono de Notificación';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationSubtitle => 'Vibrar con las notificaciones';

  @override
  String get doNotDisturb => 'No Molestar';

  @override
  String get quietHours => 'Horario de Silencio';

  @override
  String get quietHoursSubtitle =>
      'No recibir notificaciones en ciertos horarios';

  @override
  String get startTime => 'Hora de Inicio';

  @override
  String get endTime => 'Hora de Fin';

  @override
  String get importantNotificationsInfo =>
      'Las notificaciones importantes como actualizaciones de pedidos siempre se mostrarán, incluso en modo silencioso.';

  @override
  String get defaultTone => 'Predeterminado';

  @override
  String get bellTone => 'Campana';

  @override
  String get chimeTone => 'Campanilla';

  @override
  String get selectTone => 'Seleccionar Tono';

  @override
  String get notificationLabel => 'Notificación';

  @override
  String get addAddress => 'Agregar Dirección';

  @override
  String get noSavedAddresses => 'No hay direcciones guardadas';

  @override
  String get noSavedAddressesDesc =>
      'Agrega direcciones para hacer tus pedidos más rápido';

  @override
  String get addFirstAddress => 'Agregar Primera Dirección';

  @override
  String get setAsDefault => 'Hacer predeterminada';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAddressTitle => 'Eliminar dirección';

  @override
  String deleteAddressConfirmation(String label) {
    return '¿Estás seguro de que quieres eliminar \"$label\"?';
  }

  @override
  String addressDeleted(String label) {
    return 'Dirección \"$label\" eliminada';
  }

  @override
  String get editAddressTitle => 'Editar Dirección';

  @override
  String get addAddressTitle => 'Agregar Dirección';

  @override
  String get labelLabel => 'Etiqueta *';

  @override
  String get labelHint => 'Ej: Casa, Trabajo, Universidad, etc.';

  @override
  String get addressLabel => 'Dirección *';

  @override
  String get addressHint => 'Calle, número, colonia';

  @override
  String get cityLabel => 'Ciudad *';

  @override
  String get cityHint => 'Ciudad, Estado';

  @override
  String get detailsLabel => 'Detalles adicionales';

  @override
  String get detailsHint => 'Referencias, color de casa, etc.';

  @override
  String get setAsDefaultLabel => 'Establecer como predeterminada';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get addAction => 'Agregar';

  @override
  String get addressUpdated => 'Dirección actualizada';

  @override
  String get addressAdded => 'Dirección agregada';

  @override
  String addressSetAsDefault(String label) {
    return '$label es ahora tu dirección predeterminada';
  }

  @override
  String get paymentMethodsTitle => 'Métodos de Pago';

  @override
  String get addCard => 'Agregar Tarjeta';

  @override
  String get noPaymentMethods => 'No hay métodos de pago';

  @override
  String get noPaymentMethodsDesc =>
      'Agrega una tarjeta para realizar pagos más rápido';

  @override
  String get addFirstCard => 'Agregar Primera Tarjeta';

  @override
  String get alternativeMethods => 'Métodos Alternativos';

  @override
  String get cash => 'Efectivo';

  @override
  String get cashSubtitle => 'Pagar al recibir el pedido';

  @override
  String get cashAvailable => 'Pago en efectivo disponible al realizar pedido';

  @override
  String get bankTransferSubtitle => 'SPEI y transferencias instantáneas';

  @override
  String get bankTransferComingSoon => 'Próximamente: Pagos por transferencia';

  @override
  String get cardHolderLabel => 'TITULAR';

  @override
  String get expiryLabel => 'EXPIRA';

  @override
  String get deletePaymentMethodTitle => 'Eliminar método de pago';

  @override
  String deletePaymentMethodConfirmation(String brand, String last4) {
    return '¿Estás seguro de que quieres eliminar la tarjeta $brand terminada en $last4?';
  }

  @override
  String paymentMethodDeleted(String brand) {
    return 'Tarjeta $brand eliminada';
  }

  @override
  String get editCardTitle => 'Editar Tarjeta';

  @override
  String get addCardTitle => 'Agregar Tarjeta';

  @override
  String get cardNumberLabel => 'Número de tarjeta *';

  @override
  String get cardHolderNameLabel => 'Nombre del titular *';

  @override
  String get expiryDateLabel => 'Expiración *';

  @override
  String get cvvLabel => 'CVV *';

  @override
  String get securityInfo =>
      'Tus datos están protegidos con encriptación de nivel bancario';

  @override
  String get cardUpdated => 'Tarjeta actualizada';

  @override
  String get cardAdded => 'Tarjeta agregada correctamente';

  @override
  String cardSetAsDefault(String brand, String last4) {
    return '$brand terminada en $last4 es ahora predeterminada';
  }

  @override
  String get purchaseHistoryTitle => 'Historial de Compras';

  @override
  String get recentTab => 'Recientes';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterDelivered => 'Entregados';

  @override
  String get filterInProgress => 'En Progreso';

  @override
  String get filterCancelled => 'Cancelados';

  @override
  String get noOrdersInProgress => 'No tienes órdenes en progreso';

  @override
  String get noOrdersCancelled => 'No tienes órdenes canceladas';

  @override
  String get noOrdersDelivered => 'No tienes órdenes entregadas';

  @override
  String get ordersEmptyDesc => 'Cuando realices pedidos aparecerán aquí';

  @override
  String moreProducts(int count) {
    return '+ $count producto(s) más';
  }

  @override
  String get totalLabel => 'Total: ';

  @override
  String get rateOrder => 'Calificar pedido';

  @override
  String yourRating(int rating) {
    return 'Tu calificación: $rating/5';
  }

  @override
  String get trackOrder => 'Rastrear';

  @override
  String get orderAgain => 'Pedir Otra Vez';

  @override
  String get orderCancelled => 'Pedido cancelado';

  @override
  String get statusDelivered => 'Entregado';

  @override
  String get statusInProgress => 'En Progreso';

  @override
  String orderedTimes(int count) {
    return 'Pedido $count veces';
  }

  @override
  String get yourFavorites => 'Tus Favoritos';

  @override
  String get favoritesDesc => 'Productos que has pedido más de una vez';

  @override
  String get orderFavorites => 'Pedir Mis Favoritos';

  @override
  String timeAgoMinutes(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String timeAgoHours(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String get yesterday => 'Ayer';

  @override
  String timeAgoDays(int days) {
    return 'Hace $days días';
  }

  @override
  String get confirmTitle => 'Confirmar';

  @override
  String get clearHistoryConfirmation =>
      '¿Deseas borrar todo el historial de cupones?';

  @override
  String get clearAll => 'Borrar Todo';

  @override
  String get historyCleared => 'Historial borrado';

  @override
  String get discount10 => '10% de descuento';

  @override
  String get discount20 => '20% de descuento';

  @override
  String get discount50 => '50% de descuento';

  @override
  String get specialCoupon => 'Cupón especial';

  @override
  String get myCoupons => 'Mis Cupones';

  @override
  String get clearHistoryTooltip => 'Borrar historial';

  @override
  String get noCouponsTitle => 'No has ganado cupones aún';

  @override
  String get noCouponsSubtitle => 'Usa \"Rasca y Gana\" para obtener cupones';

  @override
  String couponsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cupones',
      one: '1 cupón',
    );
    return 'Has ganado $_temp0';
  }

  @override
  String wonDate(String date) {
    return 'Ganado: $date';
  }

  @override
  String get activeStatus => 'Activo';

  @override
  String get mapViewTitle => 'Vista de Mapa';

  @override
  String get mapsDisabled => '(Integración de Google Maps deshabilitada)';

  @override
  String get errorTitle => 'Error';

  @override
  String get noProductsAvailable =>
      'No hay productos disponibles en este momento';
}
