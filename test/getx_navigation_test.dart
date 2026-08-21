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

    expect(find.text('Move files\nthrough light.'), findsOneWidget);

    await tester.tap(find.text('Send a file'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a file to broadcast'), findsOneWidget);
    expect(Get.isRegistered<SendController>(), isTrue);

    Get.back<void>();
    await tester.pumpAndSettle();

    expect(find.text('Move files\nthrough light.'), findsOneWidget);
    expect(Get.isRegistered<SendController>(), isFalse);
  });
}
