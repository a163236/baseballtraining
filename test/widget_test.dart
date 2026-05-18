import 'package:baseball_training/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('タイトル画面が表示される', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BaseballTrainingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('野球部監督'), findsOneWidget);
    expect(find.text('新しく始める'), findsOneWidget);
  });
}
