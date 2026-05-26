/// PawTable billing service — RevenueCat SDK integration (v9.x)
///
/// Wraps [purchases_flutter] with PawTable-specific subscription logic:
/// - Initialize RevenueCat with customer API key
/// - Fetch offerings and subscription products
/// - Purchase flows (monthly, annual, family)
/// - Entitlement checking (premium, family)
/// - Purchase restoration
/// - Customer info stream for real-time status updates
/// - Freemium limit enforcement
/// - User identity management (logIn / logOut)
///
/// RevenueCat product IDs (configure these in RevenueCat dashboard):
/// - Monthly: com.pawtable.monthly
/// - Annual: com.pawtable.annual
/// - Family: com.pawtable.family
///
/// To set up RevenueCat:
/// 1. Create account at https://www.revenuecat.com
/// 2. Create app "PawTable"
/// 3. Add Apple App Store & Google Play Store product mappings
/// 4. Copy API key to REVENUECAT_API_KEY constant
/// 5. Create products: Monthly ($6.99), Annual ($49.99), Family ($9.99)
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// =========================================================================
// REVENUECAT CONFIGURATION
// =========================================================================

/// RevenueCat API key
///
/// TO CONFIGURE: Replace with your actual RevenueCat API key.
/// Get it from: RevenueCat Dashboard > App Settings > API Keys
const String _revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';

// =========================================================================
// PRODUCT IDs
// =========================================================================

/// Monthly subscription product ID
const String productMonthly = 'com.pawtable.monthly';

/// Annual subscription product ID
const String productAnnual = 'com.pawtable.annual';

/// Family subscription product ID
const String productFamily = 'com.pawtable.family';

/// All subscription product IDs
const List<String> allProductIds = [
  productMonthly,
  productAnnual,
  productFamily,
];

/// Subscription plan enum
enum SubscriptionPlan {
  monthly,
  annual,
  family,
}

// =========================================================================
// PLAN INFO
// =========================================================================

/// Subscription plan display info
class PlanInfo {
  final SubscriptionPlan plan;
  final String productId;
  final String title;
  final String description;
  final double priceMonthly;
  final double priceAnnual;
  final double priceFamily;
  final String currency;
  final bool isAnnualDefault;
  final bool isFamily;

  const PlanInfo({
    required this.plan,
    required this.productId,
    required this.title,
    required this.description,
    required this.priceMonthly,
    required this.priceAnnual,
    required this.priceFamily,
    this.currency = 'USD',
    this.isAnnualDefault = false,
    this.isFamily = false,
  });

  double get currentPrice => isFamily
      ? priceFamily
      : priceAnnual;

  static const List<PlanInfo> all = [
    PlanInfo(
      plan: SubscriptionPlan.monthly,
      productId: productMonthly,
      title: 'Monthly Plan',
      description: 'Unlock full pet tracking for just \$6.99/month',
      priceMonthly: 6.99,
      priceAnnual: 49.99 * 12 / 1,
      priceFamily: 9.99 * 12 / 1,
    ),
    PlanInfo(
      plan: SubscriptionPlan.annual,
      productId: productAnnual,
      title: 'Annual Plan',
      description: 'Best value — save 40% with annual billing',
      priceMonthly: 6.99,
      priceAnnual: 49.99,
      priceFamily: 9.99 * 12 / 1,
      isAnnualDefault: true,
    ),
    PlanInfo(
      plan: SubscriptionPlan.family,
      productId: productFamily,
      title: 'Family Plan',
      description: 'Share with your entire family — up to 5 members',
      priceMonthly: 6.99,
      priceAnnual: 49.99,
      priceFamily: 79.99,
      isFamily: true,
    ),
  ];

  static PlanInfo? getByProductId(String productId) {
    return all.firstWhere(
      (p) => p.productId == productId,
      orElse: () => all.first,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan.name,
      'productId': productId,
      'title': title,
      'description': description,
      'priceMonthly': priceMonthly,
      'priceAnnual': priceAnnual,
      'priceFamily': priceFamily,
      'currency': currency,
      'isAnnualDefault': isAnnualDefault,
      'isFamily': isFamily,
    };
  }
}

// =========================================================================
// CUSTOMER INFO WRAPPER
// =========================================================================

/// PawTable subscription status derived from RevenueCat CustomerInfo
class CustomerInfoData {
  final String? userId;
  final bool isActivePremium;
  final bool isActiveFamily;
  final String? currentProductId;
  final DateTime? currentProductExpires;
  final DateTime? currentProductPurchase;
  final List<String> activeProductIds;
  final Map<String, StoreProduct>? productsCache;
  final CustomerInfo? raw;

  const CustomerInfoData({
    this.userId,
    this.isActivePremium = false,
    this.isActiveFamily = false,
    this.currentProductId,
    this.currentProductExpires,
    this.currentProductPurchase,
    this.activeProductIds = const [],
    this.productsCache,
    this.raw,
  });

  /// Get the current plan type
  SubscriptionPlan? get currentPlan {
    if (currentProductId == productFamily) return SubscriptionPlan.family;
    if (currentProductId == productAnnual) return SubscriptionPlan.annual;
    if (currentProductId == productMonthly) return SubscriptionPlan.monthly;
    return null;
  }

  /// Whether user has any active subscription
  bool get isSubscribed => isActivePremium || isActiveFamily;

  /// Get display name for current plan
  String? get planDisplay {
    return currentPlan?.name.toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isActivePremium': isActivePremium,
      'isActiveFamily': isActiveFamily,
      'currentProductId': currentProductId,
      'currentProductExpires': currentProductExpires?.toIso8601String(),
      'currentProductPurchase': currentProductPurchase?.toIso8601String(),
      'activeProductIds': activeProductIds,
      'currentPlan': currentPlan?.name,
      'isSubscribed': isSubscribed,
    };
  }
}

// =========================================================================
// BILLING SERVICE
// =========================================================================

/// RevenueCat billing service for PawTable
///
/// Manages all subscription-related operations:
/// - SDK initialization via [Purchases.configure]
/// - Offering/product fetching via [Purchases.getOfferings] / [Purchases.getProducts]
/// - Purchases via [Purchases.purchase] with [PurchaseParams]
/// - Entitlement checking via [CustomerInfo.entitlements]
/// - Purchase restoration via [Purchases.restorePurchases]
/// - Customer info streaming via [Purchases.addCustomerInfoUpdateListener]
/// - User identity management via [Purchases.logIn] / [Purchases.logOut]
class BillingService {
  BillingService() {
    _initialize();
  }

  bool _initialized = false;
  bool _isInitializing = false;
  CustomerInfoData? _cachedInfo;
  final List<Function(CustomerInfoData)> _listeners = [];
  final List<String> _availableProductIds = [];
  final Map<String, StoreProduct> _productsCache = {};
  CustomerInfoUpdateListener? _customerInfoListener;
  String? _error;

  // =========================================================================
  // INITIALIZATION
  // =========================================================================

  /// Initialize RevenueCat SDK
  ///
  /// Uses [PurchasesConfiguration] to configure the SDK.
  /// Starts as anonymous (no appUserID) — identity is linked via [setAppUserId]
  /// when the user authenticates with Firebase.
  Future<void> _initialize() async {
    if (_initialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Check if we have a real API key (not placeholder)
      if (_revenueCatApiKey.startsWith('YOUR_')) {
        debugPrint(
          '[BillingService] RevenueCat API key is placeholder. '
          'Running in offline mode. Set up RevenueCat at '
          'https://www.revenuecat.com and replace the API key.',
        );
        _initialized = true;
        _isInitializing = false;
        return;
      }

      // Configure RevenueCat SDK
      final configuration = PurchasesConfiguration(_revenueCatApiKey)
        ..appUserID = null; // null = anonymous

      await Purchases.configure(configuration);

      // Set log level (DEBUG for development)
      await Purchases.setLogLevel(LogLevel.debug);

      // Fetch offerings and products
      await _fetchOfferings();

      // Get current customer info
      _cachedInfo = _parseCustomerInfo(await Purchases.getCustomerInfo());

      // Set up customer info listener for real-time updates
      _customerInfoListener = _onCustomerInfoUpdate;
      Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);

      _initialized = true;
      _error = null;

      debugPrint('[BillingService] RevenueCat initialized successfully');
    } on PurchasesError catch (e) {
      _error = e.message;
      debugPrint('[BillingService] RevenueCat init failed: ${e.message}');
      _initialized = true; // Mark as initialized to avoid retry loops
      _isInitializing = false;
    } catch (e) {
      _error = e.toString();
      debugPrint('[BillingService] RevenueCat init error: $e');
      _initialized = true;
      _isInitializing = false;
    }
  }

  // =========================================================================
  // PRODUCT MANAGEMENT
  // =========================================================================

  /// Fetch offerings from RevenueCat
  ///
  /// Offerings provide a flexible way to configure different subscription
  /// options and paywall experiences via the RevenueCat dashboard.
  Future<void> _fetchOfferings() async {
    if (!_initialized) return;

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        _availableProductIds.clear();
        _productsCache.clear();

        for (final package in current.availablePackages) {
          final product = package.storeProduct;
          _availableProductIds.add(product.identifier);
          _productsCache[product.identifier] = product;
        }

        debugPrint(
          '[BillingService] Loaded ${_availableProductIds.length} products '
          'from offering "${current.identifier}": $_availableProductIds',
        );
      } else {
        // Fall back to direct product fetching
        await _fetchProductsDirect();
      }
    } catch (e) {
      debugPrint('[BillingService] Failed to fetch offerings: $e');
      // Fall back to direct product fetching
      await _fetchProductsDirect();
    }
  }

  /// Direct product fetching (fallback when offerings are unavailable)
  Future<void> _fetchProductsDirect() async {
    try {
      final storeProducts = await Purchases.getProducts(allProductIds);
      _availableProductIds.clear();
      _productsCache.clear();

      for (final product in storeProducts) {
        _availableProductIds.add(product.identifier);
        _productsCache[product.identifier] = product;
      }

      debugPrint(
        '[BillingService] Loaded ${_availableProductIds.length} products '
        'directly: $_availableProductIds',
      );
    } catch (e) {
      debugPrint('[BillingService] Failed to fetch products: $e');
    }
  }

  /// Get a store product by product ID
  StoreProduct? getProduct(String productId) {
    return _productsCache[productId];
  }

  /// Get all available products
  Map<String, StoreProduct> get availableProducts {
    return Map.fromEntries(
      _productsCache.entries.where(
        (e) => _availableProductIds.contains(e.key),
      ),
    );
  }

  /// Check if a product ID is available
  bool isProductAvailable(String productId) {
    return _availableProductIds.contains(productId);
  }

  /// Get formatted price for a product
  String getFormattedPrice(String productId) {
    final product = _productsCache[productId];
    if (product == null) return '\$—';
    return product.priceString;
  }

  // =========================================================================
  // PURCHASE FLOWS
  // =========================================================================

  /// Purchase a subscription
  ///
  /// Uses the new [Purchases.purchase] API with [PurchaseParams].
  ///
  /// [planId] — product ID (e.g., [productAnnual])
  /// [isFamily] — whether this is a family plan
  ///
  /// Returns a map with 'success' boolean and relevant details.
  Future<Map<String, dynamic>> purchase({
    required String planId,
    bool isFamily = false,
  }) async {
    try {
      // Verify product is available
      if (!isProductAvailable(planId)) {
        return {
          'success': false,
          'error': 'Product not available: $planId',
          'planId': planId,
        };
      }

      final storeProduct = _productsCache[planId];
      if (storeProduct == null) {
        return {
          'success': false,
          'error': 'Product not found: $planId',
          'planId': planId,
        };
      }

      // Build PurchaseParams for the store product
      final params = PurchaseParams.storeProduct(storeProduct);

      // Perform the purchase using the new unified API
      final result = await Purchases.purchase(params);

      // Update customer info from the result
      _cachedInfo = _parseCustomerInfo(result.customerInfo);

      debugPrint(
        '[BillingService] Purchase successful: product=${storeProduct.identifier}',
      );

      return {
        'success': true,
        'productIdentifier': storeProduct.identifier,
        'planId': planId,
        'isFamily': isFamily,
        'transactionId': result.storeTransaction.transactionIdentifier,
      };
    } on PurchasesError catch (e) {
      // User cancelled — not an error
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        return {
          'success': false,
          'error': 'Purchase cancelled by user',
          'planId': planId,
          'cancelled': true,
        };
      }

      return {
        'success': false,
        'error': e.message,
        'code': e.code.name,
        'planId': planId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'planId': planId,
      };
    }
  }

  /// Purchase a subscription with specific product ID
  ///
  /// Convenience wrapper around [purchase].
  Future<Map<String, dynamic>> purchaseByProductId({
    required String productId,
  }) {
    return purchase(planId: productId);
  }

  /// Upgrade/downgrade subscription
  ///
  /// Uses [GoogleProductChangeInfo] for proration mode on Android.
  ///
  /// [newProductId] — new product ID
  /// [oldProductId] — current product ID
  Future<Map<String, dynamic>> upgradeSubscription({
    required String newProductId,
    String? oldProductId,
  }) async {
    try {
      if (!isProductAvailable(newProductId)) {
        return {
          'success': false,
          'error': 'Product not available: $newProductId',
          'newProductId': newProductId,
        };
      }

      final storeProduct = _productsCache[newProductId];
      if (storeProduct == null) {
        return {
          'success': false,
          'error': 'Product not found: $newProductId',
          'newProductId': newProductId,
        };
      }

      // Build change info for the subscription switch
      final changeInfo = oldProductId != null
          ? GoogleProductChangeInfo(oldProductId)
          : null;

      final params = PurchaseParams.storeProduct(
        storeProduct,
        googleProductChangeInfo: changeInfo,
      );

      final result = await Purchases.purchase(params);
      _cachedInfo = _parseCustomerInfo(result.customerInfo);

      return {
        'success': true,
        'productIdentifier': storeProduct.identifier,
        'newProductId': newProductId,
        'transactionId': result.storeTransaction.transactionIdentifier,
      };
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        return {
          'success': false,
          'error': 'Upgrade cancelled by user',
          'newProductId': newProductId,
          'cancelled': true,
        };
      }

      return {
        'success': false,
        'error': e.message,
        'code': e.code.name,
        'newProductId': newProductId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'newProductId': newProductId,
      };
    }
  }

  // =========================================================================
  // RESTORE
  // =========================================================================

  /// Restore previous purchases
  ///
  /// Calls [Purchases.restorePurchases] and updates cached customer info.
  Future<Map<String, dynamic>> restore() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _cachedInfo = _parseCustomerInfo(customerInfo);

      return {
        'success': true,
        'restored': true,
      };
    } on PurchasesError catch (e) {
      return {
        'success': false,
        'error': e.message,
        'code': e.code.name,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // =========================================================================
  // ENTITLEMENT CHECKING
  // =========================================================================

  /// Check if user has active premium subscription
  Future<bool> hasPremium() async {
    if (!_initialized) {
      await _initialize();
    }

    final info = await Purchases.getCustomerInfo();
    _cachedInfo = _parseCustomerInfo(info);
    return _cachedInfo!.isActivePremium;
  }

  /// Check if user has active family subscription
  Future<bool> hasFamily() async {
    if (!_initialized) {
      await _initialize();
    }

    final info = await Purchases.getCustomerInfo();
    _cachedInfo = _parseCustomerInfo(info);
    return _cachedInfo!.isActiveFamily;
  }

  /// Get comprehensive customer info
  Future<CustomerInfoData> getCustomerInfo() async {
    if (!_initialized) {
      await _initialize();
    }

    final info = await Purchases.getCustomerInfo();
    _cachedInfo = _parseCustomerInfo(info);
    return _cachedInfo!;
  }

  /// Get current plan info as map
  Future<Map<String, dynamic>> getPlanInfo() async {
    final info = await getCustomerInfo();
    return info.toMap();
  }

  // =========================================================================
  // CUSTOMER INFO PARSING
  // =========================================================================

  /// Parse RevenueCat CustomerInfo into our data model
  ///
  /// RevenueCat v9 uses [StoreProduct] with [identifier] instead of
  /// SKProduct's productIdentifier. Dates are stored as ISO 8601 strings.
  CustomerInfoData _parseCustomerInfo(CustomerInfo info) {
    final activeProductIds = info.activeSubscriptions.toList();
    String? currentProductIdStr;
    DateTime? expiresAt;
    DateTime? purchaseDate;

    // Parse expiration date from latestExpirationDate
    final latestExp = info.latestExpirationDate;
    if (latestExp != null) {
      expiresAt = DateTime.tryParse(latestExp);
    }

    // Parse purchase date from originalPurchaseDate
    final origPurchase = info.originalPurchaseDate;
    if (origPurchase != null) {
      purchaseDate = DateTime.tryParse(origPurchase);
    }

    // Find current product in our cache
    for (final productId in activeProductIds) {
      if (_productsCache.containsKey(productId)) {
        currentProductIdStr = productId;
        break;
      }
    }

    // If not found in cache, use last active subscription
    if (currentProductIdStr == null && activeProductIds.isNotEmpty) {
      currentProductIdStr = activeProductIds.last;
    }

    return CustomerInfoData(
      userId: info.originalAppUserId,
      isActivePremium: activeProductIds.any(
        (id) => id == productMonthly || id == productAnnual,
      ),
      isActiveFamily: activeProductIds.contains(productFamily),
      currentProductId: currentProductIdStr,
      currentProductExpires: expiresAt,
      currentProductPurchase: purchaseDate,
      activeProductIds: activeProductIds,
      productsCache: _productsCache,
      raw: info,
    );
  }

  /// Handle customer info update from RevenueCat listener
  ///
  /// Signature: [CustomerInfoUpdateListener] = void Function(CustomerInfo)
  void _onCustomerInfoUpdate(CustomerInfo info) {
    _cachedInfo = _parseCustomerInfo(info);

    // Notify listeners
    for (final listener in _listeners) {
      listener(_cachedInfo!);
    }

    debugPrint(
      '[BillingService] Customer info updated — '
      'premium: ${_cachedInfo!.isActivePremium}, '
      'family: ${_cachedInfo!.isActiveFamily}, '
      'products: ${_cachedInfo!.activeProductIds}',
    );
  }

  /// Add customer info update listener
  void addCustomerInfoListener(Function(CustomerInfoData) listener) {
    _listeners.add(listener);
  }

  /// Remove customer info update listener
  void removeCustomerInfoListener(Function(CustomerInfoData) listener) {
    _listeners.remove(listener);
  }

  // =========================================================================
  // FREEMIUM LIMITS
  // =========================================================================

  /// Check freemium pet limit
  ///
  /// Free users: 1 pet. Premium users: unlimited.
  Future<bool> canAddPet({int currentPetCount = 0, bool? isPremium}) async {
    final premium = isPremium ?? (await hasPremium());
    if (premium) return true;
    return currentPetCount < 1; // Free: 1 pet
  }

  /// Check freemium family member limit
  ///
  /// Free users: 2 members. Family plan: unlimited.
  Future<bool> hasFamilyMemberLimit({
    int memberCount = 0,
    bool? isFamily,
  }) async {
    final family = isFamily ?? (await hasFamily());
    if (family) return true;
    return memberCount < 2; // Free: 2 members
  }

  // =========================================================================
  // APP USER ID / IDENTITY
  // =========================================================================

  /// Link anonymous user to authenticated identity
  ///
  /// Call this when a user signs up or signs in to link their
  /// anonymous RevenueCat identity to their permanent identity.
  /// Uses [Purchases.logIn] which returns a [LogInResult].
  Future<void> setAppUserId(String appUserId) async {
    try {
      final result = await Purchases.logIn(appUserId);
      _cachedInfo = _parseCustomerInfo(result.customerInfo);
      debugPrint(
        '[BillingService] App user ID set: $appUserId '
        '(created=${result.created})',
      );
    } catch (e) {
      debugPrint('[BillingService] Failed to set app user ID: $e');
    }
  }

  /// Reset to anonymous identity (sign out)
  ///
  /// Uses [Purchases.logOut] which generates a new random appUserID.
  Future<void> reset() async {
    try {
      final info = await Purchases.logOut();
      _cachedInfo = _parseCustomerInfo(info);
      debugPrint('[BillingService] Reset to anonymous identity');
    } catch (e) {
      debugPrint('[BillingService] Failed to reset: $e');
    }
  }

  // =========================================================================
  // STATUS
  // =========================================================================

  /// Check if RevenueCat is initialized
  bool get isInitialized => _initialized;

  /// Get last initialization error (if any)
  String? get lastError => _error;

  /// Get cached customer info
  CustomerInfoData? getCachedInfo() => _cachedInfo;
}

// =========================================================================
// RIVERPOD PROVIDERS
// =========================================================================

/// Billing service singleton provider
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService();
});

/// Premium status provider
final premiumStatusProvider = FutureProvider<bool>((ref) async {
  final billing = ref.watch(billingServiceProvider);
  return billing.hasPremium();
});

/// Family status provider
final familyStatusProvider = FutureProvider<bool>((ref) async {
  final billing = ref.watch(billingServiceProvider);
  return billing.hasFamily();
});

/// Available subscription plans provider
final subscriptionPlansProvider = Provider<List<PlanInfo>>((ref) {
  return PlanInfo.all;
});

/// Current plan provider
final currentPlanProvider = FutureProvider<PlanInfo?>((ref) async {
  final billing = ref.read(billingServiceProvider);
  final info = await billing.getCustomerInfo();
  if (info.currentPlan == null) return null;

  return PlanInfo.all.firstWhere(
    (p) => p.plan == info.currentPlan,
    orElse: () => PlanInfo.all.first,
  );
});

/// Is subscribed provider
final isSubscribedProvider = FutureProvider<bool>((ref) async {
  final billing = ref.read(billingServiceProvider);
  return billing.getCustomerInfo().then((info) => info.isSubscribed);
});

/// Customer info stream provider
final customerInfoStreamProvider = StreamProvider.autoDispose<CustomerInfoData>(
  (ref) async* {
    final billing = ref.read(billingServiceProvider);

    // Emit current info immediately
    final currentInfo = await billing.getCustomerInfo();
    yield currentInfo;

    // Set up listener and emit updates
    final streamController = StreamController<CustomerInfoData>();

    void listener(CustomerInfoData data) {
      streamController.add(data);
    }

    billing.addCustomerInfoListener(listener);

    // Remove listener when provider is disposed
    ref.onDispose(() {
      billing.removeCustomerInfoListener(listener);
      streamController.close();
    });
  },
);
