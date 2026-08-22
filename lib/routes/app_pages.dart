import 'package:get/get.dart';

import '../features/details/details_screen.dart';
import '../features/home/home_screen.dart';
import '../features/receive/receive_binding.dart';
import '../features/receive/receive_screen.dart';
import '../features/send/send_binding.dart';
import '../features/send/send_screen.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const _transitionDuration = Duration(milliseconds: 280);

  static final pages = <GetPage<void>>[
    GetPage<void>(name: AppRoutes.home, page: HomeScreen.new),
    GetPage<void>(
      name: AppRoutes.send,
      page: SendScreen.new,
      binding: SendBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
    ),
    GetPage<void>(
      name: AppRoutes.receive,
      page: ReceiveScreen.new,
      binding: ReceiveBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
    ),
    GetPage<void>(
      name: AppRoutes.details,
      page: DetailsScreen.new,
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
    ),
  ];
}
