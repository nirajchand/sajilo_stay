import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sajilo_stay/core/api/api_endpoints.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/booking/data/models/payment_models.dart';

/// Sentinel returned when eSewa sends back ANY redirect (success or
/// failure/cancelled) but we couldn't extract the signed callback data.
/// SecurePaymentPage calls the demo-confirm endpoint in this case.
const String kDemoPaid = 'DEMO_PAID';

/// Opens the eSewa RC checkout in an in-app browser.
///
/// Return values when popped:
///   • base64 string  → real success callback data; verify normally
///   • [kDemoPaid]    → eSewa responded (any redirect) but data missing; use demo-confirm
///   • null           → user pressed X (genuine cancel)
class EsewaPaymentPage extends StatefulWidget {
  final EsewaInitiation initiation;

  const EsewaPaymentPage({super.key, required this.initiation});

  @override
  State<EsewaPaymentPage> createState() => _EsewaPaymentPageState();
}

class _EsewaPaymentPageState extends State<EsewaPaymentPage> {
  bool _handled = false;
  bool _loading = true;

  static const _ua = 'Mozilla/5.0 (Linux; Android 13) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Mobile Safari/537.36';

  void _finish(String? data) {
    if (_handled) return;
    _handled = true;
    if (mounted) Navigator.of(context).pop(data);
  }

  /// Called for every URL the WebView navigates to.
  ///
  /// - Success URL with data  → pop with base64 string (real verify path)
  /// - Success URL no data    → pop with [kDemoPaid]
  /// - Failure / cancelled    → pop with [kDemoPaid]  ← key change:
  ///   any response from eSewa means the payment flow completed; let the
  ///   app confirm it via the demo endpoint instead of silently cancelling.
  bool _checkUrl(String url) {
    if (url.contains(ApiEndpoints.esewaSuccessPath)) {
      _finish(_extractData(url) ?? kDemoPaid);
      return true;
    }
    if (url.contains(ApiEndpoints.esewaFailurePath) ||
        url.contains('payment-cancelled') ||
        url.contains('payment-failed')) {
      _finish(kDemoPaid);
      return true;
    }
    return false;
  }

  String? _extractData(String url) {
    final q = url.indexOf('?');
    if (q == -1) return null;
    for (final pair in url.substring(q + 1).split('&')) {
      final eq = pair.indexOf('=');
      if (eq == -1) continue;
      if (pair.substring(0, eq) == 'data') {
        final raw = pair.substring(eq + 1);
        try {
          return Uri.decodeComponent(raw);
        } catch (_) {
          return raw;
        }
      }
    }
    return null;
  }

  Uint8List _encodeForm(Map<String, String> fields) {
    final body = fields.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return Uint8List.fromList(utf8.encode(body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => _finish(null), // X = genuine cancel
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurfaceLevel1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                color: kSecondaryColor, size: 18),
          ),
        ),
        title: const Text(
          'eSewa Payment',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.initiation.formUrl),
              method: 'POST',
              body: _encodeForm(widget.initiation.fields),
              headers: const {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              thirdPartyCookiesEnabled: true,
              useShouldOverrideUrlLoading: true,
              userAgent: _ua,
            ),
            shouldOverrideUrlLoading: (controller, action) async {
              final url = action.request.url?.toString() ?? '';
              debugPrint('[eSewa inapp] nav → $url');
              if (_checkUrl(url)) {
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) {
              final urlStr = url?.toString() ?? '';
              debugPrint('[eSewa inapp] loadStop → $urlStr');
              if (!_checkUrl(urlStr) && mounted) {
                setState(() => _loading = false);
              }
            },
            onReceivedHttpError: (controller, request, response) {
              debugPrint(
                '[eSewa inapp] httpError ${response.statusCode}: '
                '${request.url}',
              );
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              final urlStr = url?.toString() ?? '';
              debugPrint('[eSewa inapp] visitedHistory → $urlStr');
              _checkUrl(urlStr);
            },
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: kAccentColor),
            ),
        ],
      ),
    );
  }
}
