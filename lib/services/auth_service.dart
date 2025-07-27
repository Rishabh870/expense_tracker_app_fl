
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:expense_tracker_app_fl/utils/RequestMethod.dart';

class AuthService {


  Future<Response> login(String identifier, String password) async {
    final Response response = await publicDio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    log(response.data.toString());
    return response;
  }

  Future<Response> signup(String name, String email, String password) async {
    return await publicDio.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await publicDio.post('/auth/refresh', data: {
      'refresh': refreshToken,
    });
  }
}
