// ignore_for_file: constant_identifier_names

const localhost =
    'https://4b03-2405-201-7000-210f-41b7-de6b-f98c-a68c.ngrok.io';

const SERVER_URL = '$localhost/api';

class Constants {
  static const String LOGIN_URL = '$SERVER_URL/login';
  static const String GET_USER_URL = '$SERVER_URL/user';

  static const String CREATE_DOC = '$SERVER_URL/doc/create';
  static const String GET_DOCS = '$SERVER_URL/docs/me';
  static const String UPDATE_DOC = '$SERVER_URL/doc';
  static const String UPDATE_TITLE = '$SERVER_URL/doc/title';
}
