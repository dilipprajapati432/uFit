import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String androidWidgetName = 'WaterWidgetProvider';
  static const String iosWidgetName = 'WaterWidget';

  static Future<void> updateWaterWidget(int total, int goal) async {
    try {
      await HomeWidget.saveWidgetData<int>('water_total', total);
      await HomeWidget.saveWidgetData<int>('water_goal', goal);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );
    } catch (e) {
      print('Error updating home widget: $e');
    }
  }
}
