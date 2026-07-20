import 'package:flutter/widgets.dart';

/// Global navigator key so non-widget code (e.g. the Dio auth interceptor) can
/// drive navigation — used to bounce the user to the login screen when their
/// session expires.
final navigatorKey = GlobalKey<NavigatorState>();
