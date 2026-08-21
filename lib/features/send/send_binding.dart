import 'package:get/get.dart';

import 'send_controller.dart';

class SendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendController>(SendController.new);
  }
}
