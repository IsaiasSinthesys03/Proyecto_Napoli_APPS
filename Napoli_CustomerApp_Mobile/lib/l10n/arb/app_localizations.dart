import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// El título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Pizzeria UI'**
  String get appTitle;

  /// Título de la pantalla de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get loginTitle;

  /// Subtítulo de la pantalla de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus credenciales para continuar'**
  String get loginSubtitle;

  /// Etiqueta para el campo de correo electrónico
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// Etiqueta para el campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// Texto del botón de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// Texto para recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// Texto para usuarios sin cuenta
  ///
  /// In es, this message translates to:
  /// **'¿No tienes una cuenta?'**
  String get dontHaveAccount;

  /// Texto del enlace de registro
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// No description provided for @welcomeTo.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a'**
  String get welcomeTo;

  /// No description provided for @signInTab.
  ///
  /// In es, this message translates to:
  /// **'INICIAR'**
  String get signInTab;

  /// No description provided for @signUpTab.
  ///
  /// In es, this message translates to:
  /// **'REGISTRARSE'**
  String get signUpTab;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get nameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @orLoginWith.
  ///
  /// In es, this message translates to:
  /// **'O inicia sesión con'**
  String get orLoginWith;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginAction.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginAction;

  /// No description provided for @registerAction.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get registerAction;

  /// No description provided for @homeAddress.
  ///
  /// In es, this message translates to:
  /// **'Ciudad de México, México'**
  String get homeAddress;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'BUSCAR PIZZAS, PASTAS...'**
  String get searchHint;

  /// No description provided for @specialOffers.
  ///
  /// In es, this message translates to:
  /// **'OFERTAS ESPECIALES'**
  String get specialOffers;

  /// No description provided for @specialOfferDesc.
  ///
  /// In es, this message translates to:
  /// **'2x1 en pizzas seleccionadas'**
  String get specialOfferDesc;

  /// No description provided for @catAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get catAll;

  /// No description provided for @catPizzas.
  ///
  /// In es, this message translates to:
  /// **'Pizzas'**
  String get catPizzas;

  /// No description provided for @catPastas.
  ///
  /// In es, this message translates to:
  /// **'Pastas'**
  String get catPastas;

  /// No description provided for @catDrinks.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get catDrinks;

  /// No description provided for @catDesserts.
  ///
  /// In es, this message translates to:
  /// **'Postres'**
  String get catDesserts;

  /// No description provided for @recommendations.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones para ti'**
  String get recommendations;

  /// No description provided for @fullMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú Completo'**
  String get fullMenu;

  /// No description provided for @cartTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Carrito'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío'**
  String get cartEmpty;

  /// No description provided for @cartEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'¡Agrega deliciosas pizzas!'**
  String get cartEmptyDesc;

  /// No description provided for @exploreMenu.
  ///
  /// In es, this message translates to:
  /// **'Explorar menú'**
  String get exploreMenu;

  /// No description provided for @extrasLabel.
  ///
  /// In es, this message translates to:
  /// **'Extras: '**
  String get extrasLabel;

  /// No description provided for @estimatedTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo estimado: 25-35 min'**
  String get estimatedTime;

  /// No description provided for @couponHint.
  ///
  /// In es, this message translates to:
  /// **'Código de cupón'**
  String get couponHint;

  /// No description provided for @applyCoupon.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get applyCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In es, this message translates to:
  /// **'Cupón {code} aplicado: {desc}'**
  String couponApplied(String code, String desc);

  /// No description provided for @enterCoupon.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un código de cupón'**
  String get enterCoupon;

  /// No description provided for @couponRemoved.
  ///
  /// In es, this message translates to:
  /// **'Cupón eliminado'**
  String get couponRemoved;

  /// No description provided for @subtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal:'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In es, this message translates to:
  /// **'Envío:'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In es, this message translates to:
  /// **'Descuento'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @confirmOrder.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Pedido'**
  String get confirmOrder;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// No description provided for @appSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración de la App'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar entre tema claro y oscuro'**
  String get darkModeSubtitle;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar notificaciones push'**
  String get notificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSubtitle;

  /// No description provided for @comingSoonLanguage.
  ///
  /// In es, this message translates to:
  /// **'Próximamente: Cambio de idioma'**
  String get comingSoonLanguage;

  /// No description provided for @preferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// No description provided for @savedAddresses.
  ///
  /// In es, this message translates to:
  /// **'Direcciones Guardadas'**
  String get savedAddresses;

  /// No description provided for @savedAddressesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar direcciones de entrega'**
  String get savedAddressesSubtitle;

  /// No description provided for @purchaseHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de Compras'**
  String get purchaseHistory;

  /// No description provided for @purchaseHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ver pedidos anteriores y favoritos'**
  String get purchaseHistorySubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y Soporte'**
  String get helpSupport;

  /// No description provided for @helpCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de Ayuda'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes y soporte'**
  String get helpCenterSubtitle;

  /// No description provided for @comingSoonHelp.
  ///
  /// In es, this message translates to:
  /// **'Próximamente: Centro de ayuda'**
  String get comingSoonHelp;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String version(String version);

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Salir de la aplicación'**
  String get logoutSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In es, this message translates to:
  /// **'Aplicación de pedidos de pizza para Napoli Restaurant.'**
  String get aboutDescription;

  /// No description provided for @aboutFooter.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado con Flutter y mucho ❤️'**
  String get aboutFooter;

  /// No description provided for @logoutConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @sessionClosed.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada'**
  String get sessionClosed;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get changePhoto;

  /// No description provided for @photo.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get photo;

  /// No description provided for @personalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get nameRequired;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'El email es requerido'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un email válido'**
  String get emailInvalid;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono *'**
  String get phone;

  /// No description provided for @phoneRequired.
  ///
  /// In es, this message translates to:
  /// **'El teléfono es requerido'**
  String get phoneRequired;

  /// No description provided for @address.
  ///
  /// In es, this message translates to:
  /// **'Dirección principal'**
  String get address;

  /// No description provided for @addressRequired.
  ///
  /// In es, this message translates to:
  /// **'La dirección es requerida'**
  String get addressRequired;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get profileUpdated;

  /// No description provided for @photoPermissionTitle.
  ///
  /// In es, this message translates to:
  /// **'\"Napoli Pizza\" quiere acceder a tus fotos'**
  String get photoPermissionTitle;

  /// No description provided for @photoPermissionDesc.
  ///
  /// In es, this message translates to:
  /// **'Para que puedas tomar o seleccionar una foto de perfil desde tu dispositivo.'**
  String get photoPermissionDesc;

  /// No description provided for @deny.
  ///
  /// In es, this message translates to:
  /// **'No permitir'**
  String get deny;

  /// No description provided for @allow.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get allow;

  /// No description provided for @photoPermissionNote.
  ///
  /// In es, this message translates to:
  /// **'Solo accederemos a las fotos que selecciones'**
  String get photoPermissionNote;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto de perfil'**
  String get changeProfilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @takePhotoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usar la cámara del dispositivo'**
  String get takePhotoSubtitle;

  /// No description provided for @chooseGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get chooseGallery;

  /// No description provided for @chooseGallerySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar de tus fotos'**
  String get chooseGallerySubtitle;

  /// No description provided for @useInitials.
  ///
  /// In es, this message translates to:
  /// **'Usar iniciales'**
  String get useInitials;

  /// No description provided for @useInitialsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Volver al avatar con iniciales'**
  String get useInitialsSubtitle;

  /// No description provided for @photoCaptured.
  ///
  /// In es, this message translates to:
  /// **'Foto capturada con éxito'**
  String get photoCaptured;

  /// No description provided for @photoSelected.
  ///
  /// In es, this message translates to:
  /// **'Foto seleccionada de galería'**
  String get photoSelected;

  /// No description provided for @usingInitials.
  ///
  /// In es, this message translates to:
  /// **'Usando iniciales como avatar'**
  String get usingInitials;

  /// No description provided for @myOrders.
  ///
  /// In es, this message translates to:
  /// **'Mis Pedidos'**
  String get myOrders;

  /// No description provided for @noOrders.
  ///
  /// In es, this message translates to:
  /// **'No has realizado ningún pedido'**
  String get noOrders;

  /// No description provided for @orderNumber.
  ///
  /// In es, this message translates to:
  /// **'Pedido #{id}'**
  String orderNumber(String id);

  /// No description provided for @orderDate.
  ///
  /// In es, this message translates to:
  /// **'{date}'**
  String orderDate(DateTime date);

  /// No description provided for @orderItem.
  ///
  /// In es, this message translates to:
  /// **'{quantity}x {name}'**
  String orderItem(int quantity, String name);

  /// No description provided for @moreItems.
  ///
  /// In es, this message translates to:
  /// **'+ {count} más...'**
  String moreItems(int count);

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get statusConfirmed;

  /// No description provided for @statusPreparing.
  ///
  /// In es, this message translates to:
  /// **'Nuestros chefs están preparando tu comida con amor.'**
  String get statusPreparing;

  /// No description provided for @statusDelivering.
  ///
  /// In es, this message translates to:
  /// **'En camino'**
  String get statusDelivering;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get statusCancelled;

  /// No description provided for @addedToCart.
  ///
  /// In es, this message translates to:
  /// **'Añadido al carrito'**
  String get addedToCart;

  /// No description provided for @productNotFound.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado'**
  String get productNotFound;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @customizeOrder.
  ///
  /// In es, this message translates to:
  /// **'Personaliza tu pedido'**
  String get customizeOrder;

  /// No description provided for @specialInstructions.
  ///
  /// In es, this message translates to:
  /// **'Instrucciones especiales'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Sin cebolla, bien cocida, etc.'**
  String get specialInstructionsHint;

  /// No description provided for @addToCart.
  ///
  /// In es, this message translates to:
  /// **'Añadir al carrito'**
  String get addToCart;

  /// No description provided for @errorProcessingOrder.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar el pedido: {error}'**
  String errorProcessingOrder(String error);

  /// No description provided for @selectAddressOrManual.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona una dirección guardada o completa la dirección manualmente'**
  String get selectAddressOrManual;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Por favor completa el número de teléfono'**
  String get enterPhoneNumber;

  /// No description provided for @completeTransferData.
  ///
  /// In es, this message translates to:
  /// **'Por favor completa los datos de transferencia y adjunta el comprobante'**
  String get completeTransferData;

  /// No description provided for @orderSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen del Pedido'**
  String get orderSummary;

  /// No description provided for @extras.
  ///
  /// In es, this message translates to:
  /// **'Extras: {extras}'**
  String extras(String extras);

  /// No description provided for @discountWithCode.
  ///
  /// In es, this message translates to:
  /// **'Descuento ({code}):'**
  String discountWithCode(String code);

  /// No description provided for @deliveryAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección de Envío'**
  String get deliveryAddress;

  /// No description provided for @change.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get change;

  /// No description provided for @useDifferentAddress.
  ///
  /// In es, this message translates to:
  /// **'Usar dirección diferente'**
  String get useDifferentAddress;

  /// No description provided for @useSavedAddresses.
  ///
  /// In es, this message translates to:
  /// **'Usar direcciones guardadas'**
  String get useSavedAddresses;

  /// No description provided for @phoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: +52 55 1234-5678'**
  String get phoneHint;

  /// No description provided for @specialNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas especiales (opcional)'**
  String get specialNotes;

  /// No description provided for @specialNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Tocar timbre 3 veces, dejar en puerta, etc.'**
  String get specialNotesHint;

  /// No description provided for @defaultLabel.
  ///
  /// In es, this message translates to:
  /// **'Predeterminada'**
  String get defaultLabel;

  /// No description provided for @manualAddressInfo.
  ///
  /// In es, this message translates to:
  /// **'Completando una dirección diferente a tus direcciones guardadas'**
  String get manualAddressInfo;

  /// No description provided for @street.
  ///
  /// In es, this message translates to:
  /// **'Calle *'**
  String get street;

  /// No description provided for @streetHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Calle Principal'**
  String get streetHint;

  /// No description provided for @number.
  ///
  /// In es, this message translates to:
  /// **'Número *'**
  String get number;

  /// No description provided for @numberHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 123'**
  String get numberHint;

  /// No description provided for @apartment.
  ///
  /// In es, this message translates to:
  /// **'Apto/Depto (opcional)'**
  String get apartment;

  /// No description provided for @apartmentHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Apto 5B'**
  String get apartmentHint;

  /// No description provided for @simulationMessage.
  ///
  /// In es, this message translates to:
  /// **'Este es un pago de simulación. No se realizará ningún cargo.'**
  String get simulationMessage;

  /// No description provided for @orderDelivered.
  ///
  /// In es, this message translates to:
  /// **'¡Pedido Entregado!'**
  String get orderDelivered;

  /// No description provided for @rateExperience.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo fue tu experiencia?'**
  String get rateExperience;

  /// No description provided for @later.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get later;

  /// No description provided for @orderStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del Pedido'**
  String get orderStatus;

  /// No description provided for @exitTracking.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del seguimiento?'**
  String get exitTracking;

  /// No description provided for @exitTrackingMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu pedido seguirá en proceso. Puedes volver en cualquier momento.'**
  String get exitTrackingMessage;

  /// No description provided for @realTimeMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa en tiempo real'**
  String get realTimeMap;

  /// No description provided for @yourDeliveryMan.
  ///
  /// In es, this message translates to:
  /// **'Tu repartidor'**
  String get yourDeliveryMan;

  /// No description provided for @statusReceived.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu pedido! Estamos trabajando en ello.'**
  String get statusReceived;

  /// No description provided for @statusOnWay.
  ///
  /// In es, this message translates to:
  /// **'¡Ya casi llega! Tu comida está en camino.'**
  String get statusOnWay;

  /// No description provided for @statusEnjoy.
  ///
  /// In es, this message translates to:
  /// **'¡Disfruta tu comida deliciosa!'**
  String get statusEnjoy;

  /// No description provided for @bankTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia Bancaria'**
  String get bankTransfer;

  /// No description provided for @instructions.
  ///
  /// In es, this message translates to:
  /// **'Instrucciones'**
  String get instructions;

  /// No description provided for @transferInstructions.
  ///
  /// In es, this message translates to:
  /// **'Realiza la transferencia con los datos bancarios proporcionados y adjunta el comprobante para confirmar tu pedido.'**
  String get transferInstructions;

  /// No description provided for @transferAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto a Transferir'**
  String get transferAmount;

  /// No description provided for @bankData.
  ///
  /// In es, this message translates to:
  /// **'Datos Bancarios'**
  String get bankData;

  /// No description provided for @bank.
  ///
  /// In es, this message translates to:
  /// **'Banco'**
  String get bank;

  /// No description provided for @holder.
  ///
  /// In es, this message translates to:
  /// **'Titular'**
  String get holder;

  /// No description provided for @clabe.
  ///
  /// In es, this message translates to:
  /// **'CLABE'**
  String get clabe;

  /// No description provided for @account.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// No description provided for @concept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get concept;

  /// No description provided for @transferReceipt.
  ///
  /// In es, this message translates to:
  /// **'Comprobante de Transferencia'**
  String get transferReceipt;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @receiptAttached.
  ///
  /// In es, this message translates to:
  /// **'Comprobante Adjuntado'**
  String get receiptAttached;

  /// No description provided for @receiptLoaded.
  ///
  /// In es, this message translates to:
  /// **'Tu comprobante ha sido cargado correctamente'**
  String get receiptLoaded;

  /// No description provided for @important.
  ///
  /// In es, this message translates to:
  /// **'Importante: Tu pedido será procesado una vez que validemos tu transferencia. Esto puede tardar entre 5 y 30 minutos.'**
  String get important;

  /// No description provided for @confirmTransfer.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Transferencia'**
  String get confirmTransfer;

  /// No description provided for @attachReceiptError.
  ///
  /// In es, this message translates to:
  /// **'Por favor adjunta el comprobante de transferencia'**
  String get attachReceiptError;

  /// No description provided for @clipboardCopied.
  ///
  /// In es, this message translates to:
  /// **'{label} copiado al portapapeles'**
  String clipboardCopied(String label);

  /// No description provided for @imagePickerPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Función de imagen disponible cuando se instale image_picker'**
  String get imagePickerPlaceholder;

  /// No description provided for @cameraPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Función de cámara disponible cuando se instale image_picker'**
  String get cameraPlaceholder;

  /// No description provided for @outOfHours.
  ///
  /// In es, this message translates to:
  /// **'Fuera de Horario'**
  String get outOfHours;

  /// No description provided for @bankDataUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Los datos bancarios solo están disponibles durante nuestro horario de atención.'**
  String get bankDataUnavailable;

  /// No description provided for @nextOpening.
  ///
  /// In es, this message translates to:
  /// **'Próxima apertura:'**
  String get nextOpening;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @exit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exit;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @enterPassword.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @registerScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerScreenTitle;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmPasswordRequired;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'CREAR CUENTA'**
  String get createAccount;

  /// No description provided for @splashTitle.
  ///
  /// In es, this message translates to:
  /// **'Napoli Pizzeria'**
  String get splashTitle;

  /// No description provided for @splashSlogan.
  ///
  /// In es, this message translates to:
  /// **'Las mejores pizzas de la ciudad'**
  String get splashSlogan;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @permissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Para recibir notificaciones, necesitas otorgar permisos del sistema.'**
  String get permissionRequired;

  /// No description provided for @allNotifications.
  ///
  /// In es, this message translates to:
  /// **'Todas las Notificaciones'**
  String get allNotifications;

  /// No description provided for @allNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activar o desactivar todas las notificaciones'**
  String get allNotificationsSubtitle;

  /// No description provided for @notificationTypes.
  ///
  /// In es, this message translates to:
  /// **'Tipos de Notificaciones'**
  String get notificationTypes;

  /// No description provided for @orderUpdates.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones de Pedidos'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Estados del pedido y entregas'**
  String get orderUpdatesSubtitle;

  /// No description provided for @promotions.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get promotions;

  /// No description provided for @promotionsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descuentos y ofertas especiales'**
  String get promotionsSubtitle;

  /// No description provided for @newProducts.
  ///
  /// In es, this message translates to:
  /// **'Nuevos Productos'**
  String get newProducts;

  /// No description provided for @newProductsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas de nuevos productos en el menú'**
  String get newProductsSubtitle;

  /// No description provided for @deliveryReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de Entrega'**
  String get deliveryReminders;

  /// No description provided for @deliveryRemindersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas cuando el pedido está cerca'**
  String get deliveryRemindersSubtitle;

  /// No description provided for @chatMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes de Chat'**
  String get chatMessages;

  /// No description provided for @chatMessagesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones del servicio al cliente'**
  String get chatMessagesSubtitle;

  /// No description provided for @weeklyOffers.
  ///
  /// In es, this message translates to:
  /// **'Ofertas Semanales'**
  String get weeklyOffers;

  /// No description provided for @weeklyOffersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Promociones especiales de fin de semana'**
  String get weeklyOffersSubtitle;

  /// No description provided for @appUpdates.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones de App'**
  String get appUpdates;

  /// No description provided for @appUpdatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevas versiones y características'**
  String get appUpdatesSubtitle;

  /// No description provided for @soundVibration.
  ///
  /// In es, this message translates to:
  /// **'Sonido y Vibración'**
  String get soundVibration;

  /// No description provided for @sound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get sound;

  /// No description provided for @soundSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reproducir sonido con las notificaciones'**
  String get soundSubtitle;

  /// No description provided for @notificationTone.
  ///
  /// In es, this message translates to:
  /// **'Tono de Notificación'**
  String get notificationTone;

  /// No description provided for @vibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vibrar con las notificaciones'**
  String get vibrationSubtitle;

  /// No description provided for @doNotDisturb.
  ///
  /// In es, this message translates to:
  /// **'No Molestar'**
  String get doNotDisturb;

  /// No description provided for @quietHours.
  ///
  /// In es, this message translates to:
  /// **'Horario de Silencio'**
  String get quietHours;

  /// No description provided for @quietHoursSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No recibir notificaciones en ciertos horarios'**
  String get quietHoursSubtitle;

  /// No description provided for @startTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de Inicio'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de Fin'**
  String get endTime;

  /// No description provided for @importantNotificationsInfo.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones importantes como actualizaciones de pedidos siempre se mostrarán, incluso en modo silencioso.'**
  String get importantNotificationsInfo;

  /// No description provided for @defaultTone.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get defaultTone;

  /// No description provided for @bellTone.
  ///
  /// In es, this message translates to:
  /// **'Campana'**
  String get bellTone;

  /// No description provided for @chimeTone.
  ///
  /// In es, this message translates to:
  /// **'Campanilla'**
  String get chimeTone;

  /// No description provided for @selectTone.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Tono'**
  String get selectTone;

  /// No description provided for @notificationLabel.
  ///
  /// In es, this message translates to:
  /// **'Notificación'**
  String get notificationLabel;

  /// No description provided for @addAddress.
  ///
  /// In es, this message translates to:
  /// **'Agregar Dirección'**
  String get addAddress;

  /// No description provided for @noSavedAddresses.
  ///
  /// In es, this message translates to:
  /// **'No hay direcciones guardadas'**
  String get noSavedAddresses;

  /// No description provided for @noSavedAddressesDesc.
  ///
  /// In es, this message translates to:
  /// **'Agrega direcciones para hacer tus pedidos más rápido'**
  String get noSavedAddressesDesc;

  /// No description provided for @addFirstAddress.
  ///
  /// In es, this message translates to:
  /// **'Agregar Primera Dirección'**
  String get addFirstAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In es, this message translates to:
  /// **'Hacer predeterminada'**
  String get setAsDefault;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteAddressTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar dirección'**
  String get deleteAddressTitle;

  /// No description provided for @deleteAddressConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar \"{label}\"?'**
  String deleteAddressConfirmation(String label);

  /// No description provided for @addressDeleted.
  ///
  /// In es, this message translates to:
  /// **'Dirección \"{label}\" eliminada'**
  String addressDeleted(String label);

  /// No description provided for @editAddressTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Dirección'**
  String get editAddressTitle;

  /// No description provided for @addAddressTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar Dirección'**
  String get addAddressTitle;

  /// No description provided for @labelLabel.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta *'**
  String get labelLabel;

  /// No description provided for @labelHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Casa, Trabajo, Universidad, etc.'**
  String get labelHint;

  /// No description provided for @addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección *'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In es, this message translates to:
  /// **'Calle, número, colonia'**
  String get addressHint;

  /// No description provided for @cityLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciudad *'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In es, this message translates to:
  /// **'Ciudad, Estado'**
  String get cityHint;

  /// No description provided for @detailsLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalles adicionales'**
  String get detailsLabel;

  /// No description provided for @detailsHint.
  ///
  /// In es, this message translates to:
  /// **'Referencias, color de casa, etc.'**
  String get detailsHint;

  /// No description provided for @setAsDefaultLabel.
  ///
  /// In es, this message translates to:
  /// **'Establecer como predeterminada'**
  String get setAsDefaultLabel;

  /// No description provided for @updateAction.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get updateAction;

  /// No description provided for @addAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get addAction;

  /// No description provided for @addressUpdated.
  ///
  /// In es, this message translates to:
  /// **'Dirección actualizada'**
  String get addressUpdated;

  /// No description provided for @addressAdded.
  ///
  /// In es, this message translates to:
  /// **'Dirección agregada'**
  String get addressAdded;

  /// No description provided for @addressSetAsDefault.
  ///
  /// In es, this message translates to:
  /// **'{label} es ahora tu dirección predeterminada'**
  String addressSetAsDefault(String label);

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In es, this message translates to:
  /// **'Métodos de Pago'**
  String get paymentMethodsTitle;

  /// No description provided for @addCard.
  ///
  /// In es, this message translates to:
  /// **'Agregar Tarjeta'**
  String get addCard;

  /// No description provided for @noPaymentMethods.
  ///
  /// In es, this message translates to:
  /// **'No hay métodos de pago'**
  String get noPaymentMethods;

  /// No description provided for @noPaymentMethodsDesc.
  ///
  /// In es, this message translates to:
  /// **'Agrega una tarjeta para realizar pagos más rápido'**
  String get noPaymentMethodsDesc;

  /// No description provided for @addFirstCard.
  ///
  /// In es, this message translates to:
  /// **'Agregar Primera Tarjeta'**
  String get addFirstCard;

  /// No description provided for @alternativeMethods.
  ///
  /// In es, this message translates to:
  /// **'Métodos Alternativos'**
  String get alternativeMethods;

  /// No description provided for @cash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get cash;

  /// No description provided for @cashSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Pagar al recibir el pedido'**
  String get cashSubtitle;

  /// No description provided for @cashAvailable.
  ///
  /// In es, this message translates to:
  /// **'Pago en efectivo disponible al realizar pedido'**
  String get cashAvailable;

  /// No description provided for @bankTransferSubtitle.
  ///
  /// In es, this message translates to:
  /// **'SPEI y transferencias instantáneas'**
  String get bankTransferSubtitle;

  /// No description provided for @bankTransferComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente: Pagos por transferencia'**
  String get bankTransferComingSoon;

  /// No description provided for @cardHolderLabel.
  ///
  /// In es, this message translates to:
  /// **'TITULAR'**
  String get cardHolderLabel;

  /// No description provided for @expiryLabel.
  ///
  /// In es, this message translates to:
  /// **'EXPIRA'**
  String get expiryLabel;

  /// No description provided for @deletePaymentMethodTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar método de pago'**
  String get deletePaymentMethodTitle;

  /// No description provided for @deletePaymentMethodConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar la tarjeta {brand} terminada en {last4}?'**
  String deletePaymentMethodConfirmation(String brand, String last4);

  /// No description provided for @paymentMethodDeleted.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta {brand} eliminada'**
  String paymentMethodDeleted(String brand);

  /// No description provided for @editCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Tarjeta'**
  String get editCardTitle;

  /// No description provided for @addCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar Tarjeta'**
  String get addCardTitle;

  /// No description provided for @cardNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta *'**
  String get cardNumberLabel;

  /// No description provided for @cardHolderNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del titular *'**
  String get cardHolderNameLabel;

  /// No description provided for @expiryDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Expiración *'**
  String get expiryDateLabel;

  /// No description provided for @cvvLabel.
  ///
  /// In es, this message translates to:
  /// **'CVV *'**
  String get cvvLabel;

  /// No description provided for @securityInfo.
  ///
  /// In es, this message translates to:
  /// **'Tus datos están protegidos con encriptación de nivel bancario'**
  String get securityInfo;

  /// No description provided for @cardUpdated.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta actualizada'**
  String get cardUpdated;

  /// No description provided for @cardAdded.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta agregada correctamente'**
  String get cardAdded;

  /// No description provided for @cardSetAsDefault.
  ///
  /// In es, this message translates to:
  /// **'{brand} terminada en {last4} es ahora predeterminada'**
  String cardSetAsDefault(String brand, String last4);

  /// No description provided for @purchaseHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de Compras'**
  String get purchaseHistoryTitle;

  /// No description provided for @recentTab.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get recentTab;

  /// No description provided for @favoritesTab.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritesTab;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregados'**
  String get filterDelivered;

  /// No description provided for @filterInProgress.
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get filterInProgress;

  /// No description provided for @filterCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelados'**
  String get filterCancelled;

  /// No description provided for @noOrdersInProgress.
  ///
  /// In es, this message translates to:
  /// **'No tienes órdenes en progreso'**
  String get noOrdersInProgress;

  /// No description provided for @noOrdersCancelled.
  ///
  /// In es, this message translates to:
  /// **'No tienes órdenes canceladas'**
  String get noOrdersCancelled;

  /// No description provided for @noOrdersDelivered.
  ///
  /// In es, this message translates to:
  /// **'No tienes órdenes entregadas'**
  String get noOrdersDelivered;

  /// No description provided for @ordersEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Cuando realices pedidos aparecerán aquí'**
  String get ordersEmptyDesc;

  /// No description provided for @moreProducts.
  ///
  /// In es, this message translates to:
  /// **'+ {count} producto(s) más'**
  String moreProducts(int count);

  /// No description provided for @totalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total: '**
  String get totalLabel;

  /// No description provided for @rateOrder.
  ///
  /// In es, this message translates to:
  /// **'Calificar pedido'**
  String get rateOrder;

  /// No description provided for @yourRating.
  ///
  /// In es, this message translates to:
  /// **'Tu calificación: {rating}/5'**
  String yourRating(int rating);

  /// No description provided for @trackOrder.
  ///
  /// In es, this message translates to:
  /// **'Rastrear'**
  String get trackOrder;

  /// No description provided for @orderAgain.
  ///
  /// In es, this message translates to:
  /// **'Pedir Otra Vez'**
  String get orderAgain;

  /// No description provided for @orderCancelled.
  ///
  /// In es, this message translates to:
  /// **'Pedido cancelado'**
  String get orderCancelled;

  /// No description provided for @statusDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get statusDelivered;

  /// No description provided for @statusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get statusInProgress;

  /// No description provided for @orderedTimes.
  ///
  /// In es, this message translates to:
  /// **'Pedido {count} veces'**
  String orderedTimes(int count);

  /// No description provided for @yourFavorites.
  ///
  /// In es, this message translates to:
  /// **'Tus Favoritos'**
  String get yourFavorites;

  /// No description provided for @favoritesDesc.
  ///
  /// In es, this message translates to:
  /// **'Productos que has pedido más de una vez'**
  String get favoritesDesc;

  /// No description provided for @orderFavorites.
  ///
  /// In es, this message translates to:
  /// **'Pedir Mis Favoritos'**
  String get orderFavorites;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours}h'**
  String timeAgoHours(int hours);

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @timeAgoDays.
  ///
  /// In es, this message translates to:
  /// **'Hace {days} días'**
  String timeAgoDays(int days);

  /// No description provided for @confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmTitle;

  /// No description provided for @clearHistoryConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas borrar todo el historial de cupones?'**
  String get clearHistoryConfirmation;

  /// No description provided for @clearAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar Todo'**
  String get clearAll;

  /// No description provided for @historyCleared.
  ///
  /// In es, this message translates to:
  /// **'Historial borrado'**
  String get historyCleared;

  /// No description provided for @discount10.
  ///
  /// In es, this message translates to:
  /// **'10% de descuento'**
  String get discount10;

  /// No description provided for @discount20.
  ///
  /// In es, this message translates to:
  /// **'20% de descuento'**
  String get discount20;

  /// No description provided for @discount50.
  ///
  /// In es, this message translates to:
  /// **'50% de descuento'**
  String get discount50;

  /// No description provided for @specialCoupon.
  ///
  /// In es, this message translates to:
  /// **'Cupón especial'**
  String get specialCoupon;

  /// No description provided for @myCoupons.
  ///
  /// In es, this message translates to:
  /// **'Mis Cupones'**
  String get myCoupons;

  /// No description provided for @clearHistoryTooltip.
  ///
  /// In es, this message translates to:
  /// **'Borrar historial'**
  String get clearHistoryTooltip;

  /// No description provided for @noCouponsTitle.
  ///
  /// In es, this message translates to:
  /// **'No has ganado cupones aún'**
  String get noCouponsTitle;

  /// No description provided for @noCouponsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa \"Rasca y Gana\" para obtener cupones'**
  String get noCouponsSubtitle;

  /// No description provided for @couponsWon.
  ///
  /// In es, this message translates to:
  /// **'Has ganado {count, plural, =1{1 cupón} other{{count} cupones}}'**
  String couponsWon(int count);

  /// No description provided for @wonDate.
  ///
  /// In es, this message translates to:
  /// **'Ganado: {date}'**
  String wonDate(String date);

  /// No description provided for @activeStatus.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get activeStatus;

  /// No description provided for @mapViewTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista de Mapa'**
  String get mapViewTitle;

  /// No description provided for @mapsDisabled.
  ///
  /// In es, this message translates to:
  /// **'(Integración de Google Maps deshabilitada)'**
  String get mapsDisabled;

  /// No description provided for @errorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @noProductsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay productos disponibles en este momento'**
  String get noProductsAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
