import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';


class AuthService {
 
  static const String _keyName = 'user_name';
  static const String _keyRole = 'user_role';
  static const String _keySite = 'user_site';

  Future<void> saveUser(UserModel user) async {
    
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyName, user.name);
    await prefs.setString(_keyRole, user.role);
    await prefs.setString(_keySite, user.site);
  }

  Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(_keyName) ?? '';
    final role = prefs.getString(_keyRole) ?? '';
    final site = prefs.getString(_keySite) ?? '';

    if (name.isEmpty) return UserModel.empty();

    return UserModel(name: name, role: role, site: site);
  }

  Future<bool> isUserSetup() async {
    final user = await getUser();
    return user.isNotEmpty;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyRole);
    await prefs.remove(_keySite);
  }
}