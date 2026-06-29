import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/core/constants/api_constants.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadProgress = 0.0;

  // Retrieve route arguments passed from CheckoutController
  late final Map<String, dynamic> args;
  late final String gateway;
  late final String reference;
  late final Map<String, dynamic> initData;
  late final String fullName;
  late final String email;
  late final String phone;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>;
    gateway = args['gateway'] as String;
    reference = args['reference'] as String;
    initData = Map<String, dynamic>.from(args['initData'] as Map);
    fullName = args['fullName'] as String;
    email = args['email'] as String;
    phone = args['phone'] as String;

    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            logger.e('[PaymentWebView] Resource error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      );

    _loadPaymentPage();
  }

  void _loadPaymentPage() {
    final html = _buildHtmlContent();
    _controller.loadHtmlString(
      html,
      baseUrl: ApiConstants.baseUrl,
    );
  }

  void _handleJavaScriptMessage(String messageJson) {
    try {
      logger.i('[PaymentWebView] JS message: $messageJson');
      final data = jsonDecode(messageJson) as Map<String, dynamic>;
      final status = data['status']?.toString().toLowerCase();

      if (status == 'success') {
        Get.back(result: {
          'success': true,
          'transactionId': data['transactionId']?.toString(),
          'orderId': data['orderId']?.toString(),
        });
      } else if (status == 'cancel') {
        Get.back(result: {
          'success': false,
        });
      } else if (status == 'error') {
        final errorMsg = data['message']?.toString() ?? 'An unknown error occurred during payment.';
        SnackbarHelper.showError(errorMsg);
        Get.back(result: {
          'success': false,
        });
      }
    } catch (e, st) {
      logger.e('[PaymentWebView] Failed to parse JS message: $messageJson', error: e, stackTrace: st);
      Get.back(result: {
        'success': false,
      });
    }
  }

  String _buildHtmlContent() {
    switch (gateway.toLowerCase()) {
      case 'stripe':
        final pubKey = initData['publishable_key']?.toString() ?? '';
        final clientSecret = initData['client_secret']?.toString() ?? '';
        return _generateStripeHtml(pubKey, clientSecret, fullName, email, phone);
      case 'paypal':
        final clientId = initData['client_id']?.toString() ?? '';
        final orderId = initData['order_id']?.toString() ?? '';
        final amount = initData['amount']?.toString() ?? '';
        final currency = initData['currency']?.toString() ?? 'USD';
        return _generatePayPalHtml(clientId, orderId, amount, currency);
      case 'flutterwave':
        final pubKey = initData['public_key']?.toString() ?? '';
        final txRef = initData['tx_ref']?.toString() ?? reference;
        final amount = initData['amount']?.toString() ?? '';
        final currency = initData['currency']?.toString() ?? 'NGN';
        return _generateFlutterwaveHtml(pubKey, txRef, amount, currency, email, phone, fullName);
      default:
        return '<html><body><h3>Unsupported payment gateway: $gateway</h3></body></html>';
    }
  }

  String _generateStripeHtml(String publishableKey, String clientSecret, String name, String email, String phone) {
    final escapedName = name.replaceAll("'", "\\'");
    final escapedEmail = email.replaceAll("'", "\\'");
    final escapedPhone = phone.replaceAll("'", "\\'");
    return """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://js.stripe.com/v3/"></script>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
      color: #0f172a;
    }
    .container {
      max-width: 480px;
      margin: 0 auto;
      background: #ffffff;
    }
    button {
      background-color: #ff9900;
      color: #ffffff;
      border: none;
      border-radius: 12px;
      padding: 16px 20px;
      font-size: 16px;
      font-weight: 700;
      width: 100%;
      margin-top: 24px;
      cursor: pointer;
      box-shadow: 0 4px 6px -1px rgb(255 153 0 / 0.2);
      transition: all 0.2s;
    }
    button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
    #error-message {
      color: #ef4444;
      font-size: 14px;
      margin-top: 16px;
      text-align: center;
      font-weight: 500;
    }
  </style>
</head>
<body>
  <div class="container">
    <form id="payment-form">
      <div id="payment-element"></div>
      <button id="submit-btn">Pay Safely</button>
      <div id="error-message"></div>
    </form>
  </div>
  <script>
    const stripe = Stripe('$publishableKey');
    const elements = stripe.elements({ clientSecret: '$clientSecret' });
    const paymentElement = elements.create('payment');
    paymentElement.mount('#payment-element');

    document.getElementById('payment-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      const submitBtn = document.getElementById('submit-btn');
      submitBtn.disabled = true;
      submitBtn.innerText = 'Processing Payment...';
      
      const { error } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: 'https://jkworldsserviceslimited.nexcoreit4u.com/payment-success-callback',
          payment_method_data: {
            billing_details: {
              name: '$escapedName',
              email: '$escapedEmail',
              phone: '$escapedPhone',
              address: {
                line1: '123 Main Street',
                city: 'Lagos',
                country: 'NG',
                postal_code: '100001'
              }
            }
          }
        },
        redirect: 'if_required'
      });
      
      if (error) {
        document.getElementById('error-message').innerText = error.message;
        submitBtn.disabled = false;
        submitBtn.innerText = 'Pay Safely';
        window.FlutterChannel.postMessage(JSON.stringify({ status: 'error', message: error.message }));
      } else {
        window.FlutterChannel.postMessage(JSON.stringify({ status: 'success' }));
      }
    });
  </script>
</body>
</html>
    """;
  }

  String _generatePayPalHtml(String clientId, String orderId, String amount, String currency) {
    return """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://www.paypal.com/sdk/js?client-id=$clientId&currency=$currency"></script>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
      color: #0f172a;
      text-align: center;
    }
    .container {
      max-width: 480px;
      margin: 0 auto;
      background: #ffffff;
    }
    #paypal-button-container {
      margin-top: 24px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div id="paypal-button-container"></div>
  </div>
  <script>
    paypal.Buttons({
      createOrder: function(data, actions) {
        return '$orderId';
      },
      onApprove: function(data, actions) {
        window.FlutterChannel.postMessage(JSON.stringify({ status: 'success', orderId: data.orderID }));
      },
      onCancel: function(data) {
        window.FlutterChannel.postMessage(JSON.stringify({ status: 'cancel' }));
      },
      onError: function(err) {
        window.FlutterChannel.postMessage(JSON.stringify({ status: 'error', message: err.toString() }));
      }
    }).render('#paypal-button-container');
  </script>
</body>
</html>
    """;
  }

  String _generateFlutterwaveHtml(String publicKey, String txRef, String amount, String currency, String email, String phone, String name) {
    return """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://checkout.flutterwave.com/v3.js"></script>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
      color: #0f172a;
      text-align: center;
    }
    .container {
      max-width: 480px;
      margin: 0 auto;
      background: #ffffff;
    }
    button {
      background-color: #f5a623;
      color: #ffffff;
      border: none;
      border-radius: 12px;
      padding: 16px 20px;
      font-size: 16px;
      font-weight: 700;
      width: 100%;
      cursor: pointer;
      box-shadow: 0 4px 6px -1px rgb(245 166 35 / 0.2);
    }
  </style>
</head>
<body>
  <div class="container">
    <button onclick="makePayment()">Open Flutterwave</button>
  </div>
  <script>
    function makePayment() {
      FlutterwaveCheckout({
        public_key: "$publicKey",
        tx_ref: "$txRef",
        amount: $amount,
        currency: "$currency",
        payment_options: "card, mobilemoney, ussd",
        customer: {
          email: "$email",
          phone_number: "$phone",
          name: "$name",
        },
        callback: function (data) {
          window.FlutterChannel.postMessage(JSON.stringify({ status: 'success', transactionId: data.transaction_id }));
        },
        onclose: function() {
          window.FlutterChannel.postMessage(JSON.stringify({ status: 'cancel' }));
        },
        customizations: {
          title: "JKWorlds",
          description: "Car Rental Payment",
        },
      });
    }
    // Automatically open the payment form on load
    window.onload = function() {
      makePayment();
    };
  </script>
</body>
</html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Build gateway formatted title
    final gatewayTitle = gateway.isEmpty
        ? 'Payment'
        : '${gateway[0].toUpperCase()}${gateway.substring(1).toLowerCase()}';

    final amountVal = initData['amount']?.toString() ?? '0.00';
    final currencyVal = initData['currency']?.toString() ?? 'USD';

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pay with $gatewayTitle'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(result: false),
          ),
        ),
        body: Column(
          children: [
            // Load progress indicator
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadProgress > 0 ? _loadProgress : null,
                color: cs.primary,
                backgroundColor: cs.surfaceContainerHighest,
              ),

            // Overview summary card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reference: $reference',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Secure Checkout powered by $gatewayTitle',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$currencyVal $amountVal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            // WebView block
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Container(
                  color: Colors.white,
                  child: WebViewWidget(controller: _controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
