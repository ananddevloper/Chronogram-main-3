import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/main.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/service/connectivity_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageApiClient {
  static final ImageApiClient _instance = ImageApiClient._internal();
  factory ImageApiClient() => _instance;

  late Dio dio;
  bool isRedirecting = false;

  // ✅ Sirf yeh URL change karna hai — 8084 wala ngrok URL daal do
  static const String imageBaseUrl = "http://192.168.1.3:8084/api/";

  ImageApiClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: imageBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        "Accept": "application/json",
        // ⚠️ Content-Type mat dalo — Dio multipart ke liye khud set karta hai
      },
      validateStatus: (status) => true,
    );

    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!ConnectivityService().isOnline) {
            return handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: "No internet connection detected.",
            ));
          }
          final String? token = await TokenHelper.getToken();
          if (token?.isNotEmpty ?? false) {
            options.headers["Authorization"] = "Bearer $token";
          }
          print("[IMAGE-API] REQUEST[${options.method}] => PATH: ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("[IMAGE-API] RESPONSE[${response.statusCode}] => DATA: ${response.data}");
          if (response.statusCode == 401 && !isRedirecting) {
            isRedirecting = true;
            TokenHelper.clear();
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
              (route) => false,
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print("[IMAGE-API] ERROR: ${e.type} | ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      return Response(requestOptions: e.requestOptions, data: _handleError(e), statusCode: e.response?.statusCode ?? 500);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      return Response(requestOptions: e.requestOptions, data: _handleError(e), statusCode: e.response?.statusCode ?? 500);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      return Response(requestOptions: e.requestOptions, data: _handleError(e), statusCode: e.response?.statusCode ?? 500);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await dio.delete(path, data: data);
    } on DioException catch (e) {
      return Response(requestOptions: e.requestOptions, data: _handleError(e), statusCode: e.response?.statusCode ?? 500);
    }
  }

  dynamic _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return {"message": "Connection timed out.", "isNetworkError": true};
    } else if (error.type == DioExceptionType.connectionError) {
      return {"message": "No internet connection.", "isNetworkError": true};
    } else if (error.response?.data != null) {
      return error.response?.data;
    }
    return {"message": "Network error. Please try again.", "isNetworkError": true};
  }



}