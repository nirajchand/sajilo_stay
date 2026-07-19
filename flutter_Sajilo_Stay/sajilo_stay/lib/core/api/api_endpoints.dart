import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Set to true ONLY when running on a real phone. On a physical device the
  // app must reach this PC over the LAN, so update [_ipAddress] to this
  // machine's current WiFi IPv4 (run `ipconfig` / `ifconfig` to find it).
  // For the Android emulator / iOS simulator / web, keep this false so the
  // correct loopback host is chosen automatically below.
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.3.81';
  static const int _port = 3001;

  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    // Android emulator reaches the host machine's localhost via 10.0.2.2.
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1';
  static String get mediaServerUrl => serverUrl;

  // Kept short so an unreachable backend fails fast instead of hanging the UI.
  static const Duration connectionTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 12);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String googleAuth = '/auth/google';

  // Favourite endpoints
  static const String favourites = '/favourites';
  static String favouriteById(String hotelId) => '/favourites/$hotelId';

  // Hotel endpoints
  static const String hotels = '/hotels';
  static String hotelById(String id) => '/hotels/$id';
  static String hotelReviews(String id) => '/hotels/$id/reviews';

  // Review endpoints
  static const String reviews = '/reviews';

  // Booking endpoints
  static const String bookings = '/bookings';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // Payment endpoints (eSewa)
  static const String esewaInitiate = '/payments/esewa/initiate';
  static const String esewaVerify = '/payments/esewa/verify';
  static const String esewaDemoConfirm = '/payments/demo-confirm';

  // WebView intercept paths — must match backend ESEWA_SUCCESS_URL / FAILURE_URL.
  // Uses eSewa's own developer portal (public HTTPS) so the WebView's
  // mixed-content policy doesn't block the redirect from rc-epay.esewa.com.np.
  static const String esewaSuccessPath = 'developer.esewa.com.np/success';
  static const String esewaFailurePath = 'developer.esewa.com.np/failure';
}
