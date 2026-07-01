import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:dio/dio.dart';

import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/booking/checkout_view.dart';
import 'package:jkworlds/modules/booking/checkout_controller.dart';
import 'package:jkworlds/modules/booking/checkout_binding.dart';

class MockApiProvider extends ApiProvider {
  final Map<String, dynamic> mockResponses;

  MockApiProvider({required this.mockResponses});

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }

  @override
  Future<Response> postFormData(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }
}

void main() {
  testWidgets('CheckoutView renders prefilled user details, summary, applies promo, and confirms payment', (WidgetTester tester) async {
    // Ensure the assets/ directory exists and create mock license file
    final licenseFile = File('assets/license.png');
    if (!licenseFile.parent.existsSync()) {
      licenseFile.parent.createSync(recursive: true);
    }
    if (!licenseFile.existsSync()) {
      licenseFile.writeAsStringSync('dummy license file content');
    }

    // Set a large screen size to ensure all layout elements build without overflow
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      if (licenseFile.existsSync()) {
        licenseFile.deleteSync();
      }
    });

    // 1. Mock SharedPreferences with user info
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token_123',
      'auth_user_name': 'Chinedu Obi',
      'auth_user_email': 'chinedu@example.com',
      'auth_user_phone': '08031234567',
    });
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // 2. Mock API endpoints
    final mockCheckoutPricingJson = {
      'success': true,
      'message': 'Success',
      'data': {
        'currency': 'NGN',
        'service_type': 'self_drive',
        'rental_days': 2,
        'base': {
          'amount': 110000.0,
          'amount_formatted': '₦110,000',
        },
        'addons_total': {
          'amount': 10000.0,
          'amount_formatted': '₦10,000',
        },
        'protection': {
          'title': 'Basic',
          'amount': 0.0,
          'amount_formatted': '₦0',
        },
        'fees_total': {
          'amount': 5500.0,
          'amount_formatted': '₦5,500',
        },
        'discount': {
          'code': 'WELCOME10',
          'amount': 11000.0,
          'amount_formatted': '₦11,000',
        },
        'total': {
          'amount': 225500.0,
          'amount_formatted': '₦225,500',
        },
        'payable_total': {
          'amount': 214500.0,
          'amount_formatted': '₦214,500',
        },
        'deposit': {
          'amount': 100000.0,
          'amount_formatted': '₦100,000',
        },
        'payment_methods': [
          {
            'key': 'stripe',
            'label': 'Stripe',
            'subtitle': 'Credit / Debit Card',
            'icon': 'http://localhost/stripe.png',
            'public_key': 'pk_test',
            'mode': 'test',
            'currencies': ['NGN', 'USD'],
            'enabled': true
          }
        ]
      }
    };

    final mockBookingsV2Json = {
      'success': true,
      'message': 'Success',
      'data': {
        'reference': 'MOB-20260625120000-AB12CD34',
        'status': 'pending',
        'amount': 214500.0,
        'currency': 'NGN',
        'payment_method': 'stripe',
        'gateway': {
          'type': 'stripe',
          'publishable_key': 'pk_test',
          'mode': 'test',
          'payment_intent_id': 'pi_test',
          'client_secret': 'secret',
          'amount': 214500.0,
          'currency': 'NGN'
        }
      }
    };

    final mockSuccessJson = {
      'success': true,
      'message': 'Success',
      'data': {
        'id': 140,
        'booking_code': 'BK-20260625-AB12CD',
        'status': 'pending',
        'payment_status': 'paid',
        'service_type': 'self_drive',
        'currency': 'NGN',
        'vehicle': {
          'id': 11,
          'title': 'Toyota RAV4 2022',
          'image': 'http://localhost/rav4.png',
          'category': 'SUV'
        },
        'pickup': {
          'address': 'Terminal 1, Dubai Airport',
          'datetime': '2026-06-12T10:00:00+04:00',
          'datetime_formatted': 'Jun 12, 2026 10:00 AM'
        },
        'dropoff': {
          'address': 'Dubai Mall',
          'datetime': '2026-06-14T12:00:00+04:00',
          'datetime_formatted': 'Jun 14, 2026 12:00 PM'
        },
        'pricing': {
          'base_amount': 110000.0,
          'deposit_amount': 100000.0,
          'payable_amount': 214500.0,
          'total_amount': 214500.0
        },
        'payment': {
          'reference': 'MOB-20260625120000-AB12CD34',
          'gateway': 'stripe',
          'status': 'paid',
          'amount': 214500.0,
          'currency': 'NGN',
          'paid_at': '2026-06-25T12:01:30+00:00'
        }
      }
    };

    final mockCheckCoverageJson = {
      'success': true,
      'status': true,
      'data': {
        'covered': true,
      }
    };

    final mockAirportDistanceJson = {
      'success': true,
      'status': true,
      'data': {
        'currency': 'NGN',
        'distance': {
          'method': 'haversine',
          'raw_km': 10.8,
          'billable_km': 10.8,
          'min_billable_km': 1
        }
      }
    };

    final mockCouponJson = {
      'success': true,
      'status': true,
      'data': {
        'code': 'WELCOME10',
        'name': 'Welcome Discount',
        'discount_type': 'percent',
        'discount_value': 10,
        'discount': {
          'amount': 0.0,
          'amount_formatted': '₦0'
        },
        'total': {
          'amount': 214500.0,
          'amount_formatted': '₦214,500'
        },
        'payable_total': {
          'amount': 214500.0,
          'amount_formatted': '₦214,500'
        },
        'currency': 'NGN'
      }
    };

    final mockApi = MockApiProvider(mockResponses: {
      '/api/checkout': mockCheckoutPricingJson,
      '/api/checkout/coupon': mockCouponJson,
      '/api/bookings': mockBookingsV2Json,
      '/api/payments/stripe/success': mockSuccessJson,
      '/api/location/check-coverage': mockCheckCoverageJson,
      '/api/airport-transfer/distance': mockAirportDistanceJson,
    });
    Get.put<ApiProvider>(mockApi, permanent: true);

    // 3. Initialize global services
    Get.put(AuthService(), permanent: true);
    Get.put(CurrencyService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(BookingService(), permanent: true);

    // 4. Pump the GetMaterialApp with empty scaffold
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    // 5. Create mock arguments from configurator (RAV4, 2 days, GPS addon)
    final testVehicle = mockVehicles[10]; // Toyota RAV4
    final arguments = {
      'vehicle': testVehicle,
      'pickupDate': DateTime(2026, 6, 12),
      'returnDate': DateTime(2026, 6, 14), // 2 days
      'pickupTime': '10:00',
      'returnTime': '12:00',
      'isSelfDrive': true,
      'selectedProtection': 'Basic',
      'gpsAddon': true,
      'additionalDriverAddon': false,
      'childSeatAddon': false,
      'subtotal': 110000.0,
      'protectionCost': 0.0,
      'addonsCost': 10000.0,
      'serviceFee': 5500.0,
      'securityDeposit': 100000.0,
      'total': 225500.0,
    };

    // 6. Navigate to CheckoutView
    Get.to(
      () => const CheckoutView(),
      arguments: arguments,
      binding: CheckoutBinding(),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<CheckoutController>();

    // 7. Verify prefilled user details in Form inputs
    expect(find.text('Chinedu Obi'), findsOneWidget);
    expect(find.text('chinedu@example.com'), findsOneWidget);
    expect(find.text('08031234567'), findsOneWidget);

    // Verify summary breakdown calculations render correctly
    expect(find.text('BOOKING SUMMARY'), findsOneWidget);
    expect(find.textContaining('Base (2d'), findsOneWidget);
    expect(find.text('₦110,000'), findsOneWidget);
    expect(find.text('₦214,500'), findsOneWidget); // Total amount returned by calculation API

    // Verify add-on cost
    expect(find.text('₦10,000'), findsOneWidget);

    // Verify Stripe payment option is visible
    expect(find.text('Stripe'), findsOneWidget);
    expect(find.text('Credit / Debit Card'), findsOneWidget);

    // 8. Test Promo Code application
    final promoInput = find.widgetWithText(TextField, 'Enter promo code');
    expect(promoInput, findsOneWidget);
    await tester.enterText(promoInput, 'WELCOME10');
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(ElevatedButton, 'Apply');
    expect(applyButton, findsOneWidget);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    // Verify promo total price remains correct
    expect(find.text('₦214,500'), findsOneWidget);

    // Verify the Remove button appears and TextField is disabled
    final removeButton = find.byIcon(Icons.close);
    expect(removeButton, findsOneWidget);
    final textField = tester.widget<TextField>(find.widgetWithText(TextField, 'Enter promo code'));
    expect(textField.enabled, isFalse);

    // Test coupon removal
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    // Verify the Apply button is back and TextField is enabled
    final applyButtonBack = find.widgetWithText(ElevatedButton, 'Apply');
    expect(applyButtonBack, findsOneWidget);
    final textFieldBack = tester.widget<TextField>(find.widgetWithText(TextField, 'Enter promo code'));
    expect(textFieldBack.enabled, isTrue);
    expect(controller.appliedPromoCode.value, isEmpty);

    // Re-apply the promo code for the rest of the flow
    await tester.enterText(find.widgetWithText(TextField, 'Enter promo code'), 'WELCOME10');
    await tester.pumpAndSettle();
    await tester.tap(applyButtonBack);
    await tester.pumpAndSettle();

    // 9. Test Driver License upload validation
    final payButton = find.widgetWithText(FilledButton, 'Confirm & Pay');
    expect(payButton, findsOneWidget);
    await tester.tap(payButton);
    await tester.pumpAndSettle();

    // Check that booking is not created yet
    expect(controller.canPay, isFalse);

    // Mock license path selection
    controller.selectedLicensePath.value = 'assets/license.png';
    await tester.pumpAndSettle();

    // Verify file name display updates
    expect(find.text('license.png'), findsOneWidget);
    expect(controller.canPay, isTrue);

    // 10. Confirm & Complete Checkout
    final initialBookingCount = mockBookings.length;
    await tester.runAsync(() async {
      await tester.tap(payButton);
      // Wait for async operations (File I/O, API responses, etc.) to complete
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
    await tester.pumpAndSettle();

    // Verify a new booking is registered in the mock bookings list database
    expect(mockBookings.length, initialBookingCount + 1);
    expect(mockBookings[0].vehicle?.id ?? mockBookings[0].vehicleId?.toString(), '11');
    expect(mockBookings[0].totalPrice, 214500.0);

    // Clean up
    Get.reset();
  });

  testWidgets('CheckoutView for Chauffeur booking mode allows checkout without uploading driver license', (WidgetTester tester) async {
    // Set a large screen size to ensure all layout elements build without overflow
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Initialize SharedPreferences and write mock token
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token_123',
      'auth_user_name': 'Chinedu Obi',
      'auth_user_email': 'chinedu@example.com',
      'auth_user_phone': '08031234567',
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // 2. Setup mock data responses
    final mockCheckoutPricingJson = {
      'success': true,
      'status': true,
      'data': {
        'currency': 'NGN',
        'service_type': 'chauffeur',
        'rental_days': 2,
        'base': {
          'amount': 110000.0,
          'amount_formatted': '₦110,000'
        },
        'addons_total': {
          'amount': 10000.0,
          'amount_formatted': '₦10,000'
        },
        'protection': {
          'amount': 0.0,
          'amount_formatted': '₦0',
          'title': 'Basic'
        },
        'fees_total': {
          'amount': 5500.0,
          'amount_formatted': '₦5,500'
        },
        'discount': {
          'amount': 0.0,
          'amount_formatted': '₦0'
        },
        'total': {
          'amount': 214500.0,
          'amount_formatted': '₦214,500'
        },
        'payable_total': {
          'amount': 214500.0,
          'amount_formatted': '₦214,500'
        },
        'deposit': {
          'amount': 100000.0,
          'amount_formatted': '₦100,000'
        },
        'addons': [
          {
            'id': 2,
            'title': 'GPS Navigation',
            'amount': 10000.0,
            'amount_formatted': '₦10,000'
          }
        ],
        'fees': [
          {
            'title': 'Service Fee',
            'amount': 5500.0,
            'amount_formatted': '₦5,500'
          }
        ],
        'payment_methods': [
          {
            'key': 'stripe',
            'label': 'Stripe',
            'subtitle': 'Credit / Debit Card',
            'icon': 'http://localhost/stripe.png',
            'public_key': 'pk_test',
            'mode': 'test',
            'currencies': ['NGN', 'USD'],
            'enabled': true
          }
        ]
      }
    };

    final mockBookingsV2Json = {
      'success': true,
      'message': 'Success',
      'data': {
        'reference': 'MOB-20260625120000-AB12CD34',
        'status': 'pending',
        'amount': 214500.0,
        'currency': 'NGN',
        'payment_method': 'stripe',
        'gateway': {
          'type': 'stripe',
          'publishable_key': 'pk_test',
          'mode': 'test',
          'payment_intent_id': 'pi_test',
          'client_secret': 'secret',
          'amount': 214500.0,
          'currency': 'NGN'
        }
      }
    };

    final mockSuccessJson = {
      'success': true,
      'message': 'Success',
      'data': {
        'id': 141,
        'booking_code': 'BK-20260625-AB12CD',
        'status': 'pending',
        'payment_status': 'paid',
        'service_type': 'chauffeur',
        'currency': 'NGN',
        'vehicle': {
          'id': 11,
          'title': 'Toyota RAV4 2022',
          'image': 'http://localhost/rav4.png',
          'category': 'SUV'
        },
        'pickup': {
          'address': 'Terminal 1, Dubai Airport',
          'datetime': '2026-06-12T10:00:00+04:00',
          'datetime_formatted': 'Jun 12, 2026 10:00 AM'
        },
        'dropoff': {
          'address': 'Dubai Mall',
          'datetime': '2026-06-14T12:00:00+04:00',
          'datetime_formatted': 'Jun 14, 2026 12:00 PM'
        },
        'pricing': {
          'base_amount': 110000.0,
          'deposit_amount': 100000.0,
          'payable_amount': 214500.0,
          'total_amount': 214500.0
        },
        'payment': {
          'reference': 'MOB-20260625120000-AB12CD34',
          'gateway': 'stripe',
          'status': 'paid',
          'amount': 214500.0,
          'currency': 'NGN',
          'paid_at': '2026-06-25T12:01:30+00:00'
        }
      }
    };

    final mockCheckCoverageJson = {
      'success': true,
      'status': true,
      'data': {
        'covered': true,
      }
    };

    final mockAirportDistanceJson = {
      'success': true,
      'status': true,
      'data': {
        'currency': 'NGN',
        'distance': {
          'method': 'haversine',
          'raw_km': 10.8,
          'billable_km': 10.8,
          'min_billable_km': 1
        }
      }
    };

    final mockApi = MockApiProvider(mockResponses: {
      '/api/checkout': mockCheckoutPricingJson,
      '/api/bookings': mockBookingsV2Json,
      '/api/payments/stripe/success': mockSuccessJson,
      '/api/location/check-coverage': mockCheckCoverageJson,
      '/api/airport-transfer/distance': mockAirportDistanceJson,
    });
    Get.put<ApiProvider>(mockApi, permanent: true);

    // 3. Initialize global services
    Get.put(AuthService(), permanent: true);
    Get.put(CurrencyService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(BookingService(), permanent: true);

    // 4. Pump the GetMaterialApp with empty scaffold
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    // Create mock arguments (RAV4, 2 days, isSelfDrive = false)
    final testVehicle = mockVehicles[10]; // Toyota RAV4
    final arguments = {
      'vehicle': testVehicle,
      'pickupDate': DateTime(2026, 6, 12),
      'returnDate': DateTime(2026, 6, 14), // 2 days
      'pickupTime': '10:00',
      'returnTime': '12:00',
      'isSelfDrive': false, // Chauffeur selected
      'selectedProtection': 'Basic',
      'gpsAddon': true,
      'additionalDriverAddon': false,
      'childSeatAddon': false,
      'subtotal': 110000.0,
      'protectionCost': 0.0,
      'addonsCost': 10000.0,
      'serviceFee': 5500.0,
      'securityDeposit': 100000.0,
      'total': 225500.0,
    };

    // Navigate to CheckoutView
    Get.to(
      () => const CheckoutView(),
      arguments: arguments,
      binding: CheckoutBinding(),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<CheckoutController>();

    // Verify driver license field label indicates optional
    expect(find.text('DRIVER LICENSE (OPTIONAL)'), findsOneWidget);

    // Verify that since basic info is prefilled and isSelfDrive is false, canPay is immediately true
    expect(controller.canPay, isTrue);

    // Tap confirm & pay
    final payButton = find.widgetWithText(FilledButton, 'Confirm & Pay');
    expect(payButton, findsOneWidget);

    final initialBookingCount = mockBookings.length;
    await tester.runAsync(() async {
      await tester.tap(payButton);
      // Wait for async operations (File I/O, API responses, etc.) to complete
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
    await tester.pumpAndSettle();

    // Verify a new booking is registered in the mock bookings list database
    expect(mockBookings.length, initialBookingCount + 1);

    // Clean up
    Get.reset();
  });
}
