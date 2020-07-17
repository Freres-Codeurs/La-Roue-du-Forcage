import 'package:la_roue_du_forcage/static_classes/Common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SavedData { list_items }

enum TypeValue { stringValue, doubleValue, intValue, boolValue }

class SharedPreferencesDevice {
  static SharedPreferencesDevice _instance;
  List<dynamic> items = [];

  static SharedPreferencesDevice get instance {
    if (_instance == null) _instance = new SharedPreferencesDevice();
    return _instance;
  }

  List<dynamic> getItems() {
    return this.items;
  }

  void setItems(List<dynamic> items) {
    this.items = items;
  }

  Future<void> loadPrefs() async {
    String tmpInfo = await loadInfo('items');
    if (tmpInfo != null && tmpInfo.length > 0)
      this.items = json.decode(tmpInfo);
    else {
      this.items = defaultItems;
      await saveItems(defaultItems);
    }
  }

  Future<void> saveItems(List<dynamic> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setItems(items);
    await prefs.setString('items', json.encode(items));
  }

  Future<dynamic> loadInfo(String dataName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(dataName);
  }

  Future<void> resetListItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("items");
  }
}
