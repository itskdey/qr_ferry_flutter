import 'package:get/get.dart';

import 'receive_controller.dart';

class ReceiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiveController>(ReceiveController.new);
  }
}
