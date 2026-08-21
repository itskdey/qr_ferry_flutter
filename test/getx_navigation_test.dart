import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qr_ferry_flutter/app.dart';
import 'package:qr_ferry_flutter/features/send/send_controller.dart';

void main() {
  testWidgets('send route creates and disposes its GetX controller', (
    tester,
  ) async {
    Get.testMode = true;
    await tester.pumpWidget(const QrFerryApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Move a file\nthrough the camera.'), findsOneWidget);

    await tester.tap(find.text('Send a file'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Choose a file'), findsOneWidget);
    expect(Get.isRegistered<SendController>(), isTrue);

    Get.back<void>();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Move a file\nthrough the camera.'), findsOneWidget);
    expect(Get.isRegistered<SendController>(), isFalse);
  });
}
