import 'package:dio/dio.dart';
import 'package:expense_tracker_app_fl/services/token_manager.dart';

const String baseUrl = 'http://192.168.1.10:8000';
//  const String baseUrl = 'http://10.0.2.2:8000';
//  const String baseUrl = 'http://172.23.48.1:8000';

final Dio publicDio = Dio(BaseOptions(baseUrl: baseUrl));
final Dio privateDio = Dio(BaseOptions(baseUrl: baseUrl));

// void setupDioInterceptors() {
//   privateDio.interceptors.add(InterceptorsWrapper(
//     onRequest: (options, handler) async {
//       final token = await TokenManager.getAccessToken();
//       if (token != null) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }
//       return handler.next(options);
//     },
//     onError: (error, handler) async {
//       final originalRequest = error.requestOptions;

//       if (error.response?.statusCode == 401 &&
//           !originalRequest.extra.containsKey('_retry')) {
//         originalRequest.extra['_retry'] = true;

//         try {
//           final refreshToken = await TokenManager.getRefreshToken();
//           if (refreshToken == null) throw Exception("No refresh token");

//           final res = await publicDio.post('/auth/refresh-token', data: {
//             'refresh_token': refreshToken,
//           });

//           final newAccessToken = res.data['accessToken'];
//           final newRefreshToken = res.data['refreshToken'];

//           await TokenManager.storeTokens(newAccessToken, newRefreshToken);

//           originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
//           final clonedRequest = await privateDio.fetch(originalRequest);
//           return handler.resolve(clonedRequest);
//         } catch (e) {
//           await TokenManager.clearTokens();
//           return handler.reject(error); // You could trigger logout here
//         }
//       }

//       return handler.next(error);
//     },
//   ));
// }
