import 'dart:convert';
import 'package:docs/constants.dart';
import 'package:docs/models/error_model.dart';
import 'package:docs/repository/local_storage_repository.dart';
import 'package:http/http.dart' as http;
import 'package:docs/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      googleSignIn: GoogleSignIn(),
      client: http.Client(),
      localStorageRepository: LocalStorageRepository()),
);

final userProvider = StateProvider<User?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final http.Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required http.Client client,
      required LocalStorageRepository localStorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel errorModel = ErrorModel(error: '', data: null);
    try {
      final userData = await _googleSignIn.signIn();

      if (userData != null) {
        final user = User(
            email: userData.email,
            uid: userData.id,
            name: userData.displayName != null
                ? userData.displayName.toString()
                : '',
            profilePicture:
                userData.photoUrl != null ? userData.photoUrl.toString() : '',
            token: '');
        var response = await _client.post(Uri.parse(Constants.LOGIN_URL),
            body: user.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            });
        if (response.statusCode == 200) {
          final newUser = user.copyWith(
              uid: jsonDecode(response.body)['user']['_id'],
              token: jsonDecode(response.body)['token']);
          _localStorageRepository.setToken(newUser.token);
          return ErrorModel(error: null, data: user);
        }
      }
    } catch (e) {
      return ErrorModel(error: e.toString(), data: null);
    }

    return errorModel;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel errorModel = ErrorModel(error: '', data: null);
    try {
      String? token = await _localStorageRepository.getToken();
      if (token != null && token != '') {
        var response = await _client.get(Uri.parse(Constants.GET_USER_URL),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token
            });

        if (response.statusCode == 200) {
          final User user =
              User.fromJson(jsonEncode(jsonDecode(response.body)['user']))
                  .copyWith(token: jsonDecode(response.body)['token']);
          _localStorageRepository.setToken(user.token);
          return ErrorModel(error: null, data: user);
        }
      }
    } catch (e) {
      return ErrorModel(error: e.toString(), data: null);
    }

    return errorModel;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
