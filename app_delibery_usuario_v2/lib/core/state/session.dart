import 'package:shared_preferences/shared_preferences.dart';

/// Estado de sesión y onboarding, persistido localmente con SharedPreferences.
///
/// El Splash lo consulta para decidir el destino inicial:
/// - onboarding no visto  -> /onboarding
/// - visto pero sin sesión -> /login
/// - con sesión            -> /home
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kLoggedIn = 'logged_in';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<bool> get onboardingSeen async =>
      (await _p).getBool(_kOnboardingSeen) ?? false;

  Future<bool> get isLoggedIn async => (await _p).getBool(_kLoggedIn) ?? false;

  Future<void> completeOnboarding() async =>
      (await _p).setBool(_kOnboardingSeen, true);

  Future<void> signIn() async => (await _p).setBool(_kLoggedIn, true);

  Future<void> signOut() async => (await _p).setBool(_kLoggedIn, false);
}
