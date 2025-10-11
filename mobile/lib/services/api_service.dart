import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  // Inicializar el servicio
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseApiUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para agregar token de autenticación
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expirado o inválido
          await _clearToken();
          // Aquí podrías navegar al login o mostrar un diálogo
        }
        handler.next(error);
      },
    ));

    // Cargar token guardado
    await _loadToken();
  }

  // Cargar token desde SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Guardar token en SharedPreferences
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Limpiar token
  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Establecer token de autenticación
  Future<void> setAuthToken(String token) async {
    await _saveToken(token);
  }

  // Obtener token actual
  String? get authToken => _token;

  // Verificar si está autenticado
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Cerrar sesión
  Future<void> logout() async {
    await _clearToken();
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Manejar errores de Dio
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: AppConstants.timeoutErrorMessage,
          statusCode: error.response?.statusCode,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _getErrorMessage(error.response?.data);
        
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: _getExceptionType(statusCode),
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Operación cancelada',
          type: ApiExceptionType.cancel,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: AppConstants.networkErrorMessage,
          type: ApiExceptionType.network,
        );

      default:
        return ApiException(
          message: AppConstants.unknownErrorMessage,
          statusCode: error.response?.statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }

  // Obtener mensaje de error del response
  String _getErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['detail'] ?? 
             AppConstants.serverErrorMessage;
    }
    return AppConstants.serverErrorMessage;
  }

  // Obtener tipo de excepción basado en status code
  ApiExceptionType _getExceptionType(int? statusCode) {
    if (statusCode == null) return ApiExceptionType.unknown;
    
    switch (statusCode) {
      case 400:
        return ApiExceptionType.badRequest;
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
      case 422:
        return ApiExceptionType.validation;
      case 500:
        return ApiExceptionType.server;
      default:
        return ApiExceptionType.unknown;
    }
  }
}

// Excepción personalizada para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;

  ApiException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Type: $type)';
  }
}

// Tipos de excepción de API
enum ApiExceptionType {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancel,
  unknown,
}

// Extensión para manejar respuestas de API
extension ApiResponseExtension on Response {
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isError => !isSuccess;
  
  T? getData<T>() {
    if (data is Map<String, dynamic>) {
      return (data as Map<String, dynamic>)['data'] as T?;
    }
    return data as T?;
  }
  
  String? get message {
    if (data is Map<String, dynamic>) {
      return (data as Map<String, dynamic>)['message'] as String?;
    }
    return null;
  }
}
