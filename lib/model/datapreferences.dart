import 'package:shared_preferences/shared_preferences.dart';

class DataPreferences {
  DataPreferences._privateconstructor();
  //singleton object
  static final DataPreferences instance = DataPreferences._privateconstructor();

  SharedPreferences? prefs ;

  Future get preference async {
    if (prefs == null) {
      return await SharedPreferences.getInstance();
    }
    return prefs;
  }

  setLog(bool value) async {
    SharedPreferences prefs = await instance.preference;
    prefs.setBool('LoggedIn', value);
  }

  Future<bool> getLog() async {
    SharedPreferences prefs = await instance.preference;
    if (prefs.getBool('LoggedIn') == null) {
      return false;
    } else {
      return prefs.getBool('LoggedIn')!;
    }
  }

  setAdmin(bool value) async {
    SharedPreferences prefs = await instance.preference;
    prefs.setBool('Admin', value);
  }

  Future<bool> getAdmin() async {
    SharedPreferences prefs = await instance.preference;
    if (prefs.getBool('Admin') == null) {
      return false;
    } else {
      return prefs.getBool('Admin')!;
    }
  }

  clearPref() async {
    SharedPreferences prefs = await instance.preference;
    prefs.clear();
  }
}
