// ignore_for_file: constant_identifier_names

const localhost =
    'https://1c8f-2405-201-7000-210f-4564-3bf1-9f6e-6053.ngrok.io';

const SERVER_URL = '$localhost/api';

class Constants {
  static const String LOGIN_URL = '$SERVER_URL/login';
  static const String GET_USER_URL = '$SERVER_URL/user';
}
