import '../models/qr_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class QRService {
  final ApiService _apiService = ApiService();

  // Generar código QR
  Future<QRResponse> generateQR({
    required String ssid,
    required String password,
    required String authType,
    int? userId,
    DateTime? expiresAt,
    int maxUsage = -1,
    String? description,
  }) async {
    try {
      // MODO DEMO: Simular generación de QR
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final mockQR = QRModel(
        id: DateTime.now().millisecondsSinceEpoch,
        ssid: ssid,
        password: password,
        authType: authType,
        qrData: 'WIFI:T:$authType;S:$ssid;P:$password;H:false;;',
        qrImagePath: '/tmp/qr_${DateTime.now().millisecondsSinceEpoch}.png',
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        status: 'active',
        userId: userId,
        userName: userId != null ? 'Usuario Demo' : null,
        usageCount: 0,
        maxUsage: maxUsage,
        description: description,
        metadata: {
          'generated_by': 'demo_mode',
          'created_at_timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      return QRResponse.success(
        qr: mockQR,
        message: 'Código QR generado exitosamente',
      );
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener lista de códigos QR
  Future<QRsResponse> getQRs({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      final response = await _apiService.get(
        AppConstants.qrEndpoint,
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final qrsData = data['qrs'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        
        final qrs = qrsData
            .map((qrJson) => QRModel.fromJson(qrJson as Map<String, dynamic>))
            .toList();
        
        return QRsResponse.success(
          qrs: qrs,
          pagination: PaginationInfo.fromJson(pagination),
        );
      } else {
        return QRsResponse.error(
          message: response.message ?? 'Error al obtener códigos QR',
        );
      }
    } on ApiException catch (e) {
      return QRsResponse.error(message: e.message);
    } catch (e) {
      return QRsResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener código QR por ID
  Future<QRResponse> getQRById(int qrId) async {
    try {
      final response = await _apiService.get('${AppConstants.qrEndpoint}/$qrId');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final qr = QRModel.fromJson(data);
        
        return QRResponse.success(qr: qr);
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al obtener código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Actualizar código QR
  Future<QRResponse> updateQR({
    required int qrId,
    String? description,
    DateTime? expiresAt,
    int? maxUsage,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (description != null) data['description'] = description;
      if (expiresAt != null) data['expires_at'] = expiresAt.toIso8601String();
      if (maxUsage != null) data['max_usage'] = maxUsage;
      if (status != null) data['status'] = status;

      final response = await _apiService.put(
        '${AppConstants.qrEndpoint}/$qrId',
        data: data,
      );

      if (response.isSuccess) {
        final responseData = response.data as Map<String, dynamic>;
        final qr = QRModel.fromJson(responseData);
        
        return QRResponse.success(
          qr: qr,
          message: 'Código QR actualizado exitosamente',
        );
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al actualizar código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Eliminar código QR
  Future<QRResponse> deleteQR(int qrId) async {
    try {
      final response = await _apiService.delete('${AppConstants.qrEndpoint}/$qrId');

      if (response.isSuccess) {
        return QRResponse.success(
          message: 'Código QR eliminado exitosamente',
        );
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al eliminar código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Desactivar código QR
  Future<QRResponse> deactivateQR(int qrId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.qrEndpoint}/$qrId/deactivate',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final qr = QRModel.fromJson(data);
        
        return QRResponse.success(
          qr: qr,
          message: 'Código QR desactivado exitosamente',
        );
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al desactivar código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Activar código QR
  Future<QRResponse> activateQR(int qrId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.qrEndpoint}/$qrId/activate',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final qr = QRModel.fromJson(data);
        
        return QRResponse.success(
          qr: qr,
          message: 'Código QR activado exitosamente',
        );
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al activar código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Regenerar código QR
  Future<QRResponse> regenerateQR(int qrId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.qrEndpoint}/$qrId/regenerate',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final qr = QRModel.fromJson(data);
        
        return QRResponse.success(
          qr: qr,
          message: 'Código QR regenerado exitosamente',
        );
      } else {
        return QRResponse.error(
          message: response.message ?? 'Error al regenerar código QR',
        );
      }
    } on ApiException catch (e) {
      return QRResponse.error(message: e.message);
    } catch (e) {
      return QRResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener estadísticas de códigos QR
  Future<QRStatsResponse> getQRStats() async {
    try {
      final response = await _apiService.get('${AppConstants.qrEndpoint}/stats');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        
        return QRStatsResponse.success(
          stats: QRStats.fromJson(data),
        );
      } else {
        return QRStatsResponse.error(
          message: response.message ?? 'Error al obtener estadísticas de QR',
        );
      }
    } on ApiException catch (e) {
      return QRStatsResponse.error(message: e.message);
    } catch (e) {
      return QRStatsResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener historial de uso de un código QR
  Future<QRUsageHistoryResponse> getQRUsageHistory(int qrId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.qrEndpoint}/$qrId/usage-history',
      );

      if (response.isSuccess) {
        final data = response.data as List<dynamic>;
        final history = data
            .map((item) => QRUsageRecord.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return QRUsageHistoryResponse.success(history: history);
      } else {
        return QRUsageHistoryResponse.error(
          message: response.message ?? 'Error al obtener historial de uso',
        );
      }
    } on ApiException catch (e) {
      return QRUsageHistoryResponse.error(message: e.message);
    } catch (e) {
      return QRUsageHistoryResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Descargar imagen del código QR
  Future<QRDownloadResponse> downloadQRImage(int qrId) async {
    try {
      // MODO DEMO: Simular descarga de imagen QR
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simular datos de imagen PNG (1x1 pixel transparente)
      final mockImageData = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixel
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, // RGBA, no compression
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
        0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, // compressed data
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, // checksum
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, // IEND chunk
        0x42, 0x60, 0x82 // checksum
      ];
      
      return QRDownloadResponse.success(
        imageData: mockImageData,
        filename: 'qr_code_$qrId.png',
      );
    } catch (e) {
      return QRDownloadResponse.error(message: 'Error inesperado: $e');
    }
  }
}

// Respuesta de código QR
class QRResponse {
  final bool success;
  final String? message;
  final QRModel? qr;

  QRResponse._({
    required this.success,
    this.message,
    this.qr,
  });

  factory QRResponse.success({
    QRModel? qr,
    String? message,
  }) {
    return QRResponse._(
      success: true,
      qr: qr,
      message: message,
    );
  }

  factory QRResponse.error({
    required String message,
  }) {
    return QRResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de códigos QR
class QRsResponse {
  final bool success;
  final String? message;
  final List<QRModel>? qrs;
  final PaginationInfo? pagination;

  QRsResponse._({
    required this.success,
    this.message,
    this.qrs,
    this.pagination,
  });

  factory QRsResponse.success({
    required List<QRModel> qrs,
    required PaginationInfo pagination,
    String? message,
  }) {
    return QRsResponse._(
      success: true,
      qrs: qrs,
      pagination: pagination,
      message: message,
    );
  }

  factory QRsResponse.error({
    required String message,
  }) {
    return QRsResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Información de paginación (reutilizada de users_service)
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      itemsPerPage: json['items_per_page'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );
  }
}

// Estadísticas de códigos QR
class QRStats {
  final int totalQRs;
  final int activeQRs;
  final int expiredQRs;
  final int disabledQRs;
  final int totalUsage;
  final double averageUsagePerQR;
  final Map<String, int> qrsByStatus;

  QRStats({
    required this.totalQRs,
    required this.activeQRs,
    required this.expiredQRs,
    required this.disabledQRs,
    required this.totalUsage,
    required this.averageUsagePerQR,
    required this.qrsByStatus,
  });

  factory QRStats.fromJson(Map<String, dynamic> json) {
    return QRStats(
      totalQRs: json['total_qrs'] as int,
      activeQRs: json['active_qrs'] as int,
      expiredQRs: json['expired_qrs'] as int,
      disabledQRs: json['disabled_qrs'] as int,
      totalUsage: json['total_usage'] as int,
      averageUsagePerQR: (json['average_usage_per_qr'] as num).toDouble(),
      qrsByStatus: Map<String, int>.from(json['qrs_by_status'] as Map),
    );
  }
}

// Respuesta de estadísticas de QR
class QRStatsResponse {
  final bool success;
  final String? message;
  final QRStats? stats;

  QRStatsResponse._({
    required this.success,
    this.message,
    this.stats,
  });

  factory QRStatsResponse.success({
    required QRStats stats,
    String? message,
  }) {
    return QRStatsResponse._(
      success: true,
      stats: stats,
      message: message,
    );
  }

  factory QRStatsResponse.error({
    required String message,
  }) {
    return QRStatsResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Registro de uso de QR
class QRUsageRecord {
  final int id;
  final int qrId;
  final DateTime usedAt;
  final String? deviceInfo;
  final String? ipAddress;
  final String? userAgent;

  QRUsageRecord({
    required this.id,
    required this.qrId,
    required this.usedAt,
    this.deviceInfo,
    this.ipAddress,
    this.userAgent,
  });

  factory QRUsageRecord.fromJson(Map<String, dynamic> json) {
    return QRUsageRecord(
      id: json['id'] as int,
      qrId: json['qr_id'] as int,
      usedAt: DateTime.parse(json['used_at'] as String),
      deviceInfo: json['device_info'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
    );
  }
}

// Respuesta de historial de uso
class QRUsageHistoryResponse {
  final bool success;
  final String? message;
  final List<QRUsageRecord>? history;

  QRUsageHistoryResponse._({
    required this.success,
    this.message,
    this.history,
  });

  factory QRUsageHistoryResponse.success({
    required List<QRUsageRecord> history,
    String? message,
  }) {
    return QRUsageHistoryResponse._(
      success: true,
      history: history,
      message: message,
    );
  }

  factory QRUsageHistoryResponse.error({
    required String message,
  }) {
    return QRUsageHistoryResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de descarga de QR
class QRDownloadResponse {
  final bool success;
  final String? message;
  final List<int>? imageData;
  final String? filename;

  QRDownloadResponse._({
    required this.success,
    this.message,
    this.imageData,
    this.filename,
  });

  factory QRDownloadResponse.success({
    required List<int> imageData,
    required String filename,
    String? message,
  }) {
    return QRDownloadResponse._(
      success: true,
      imageData: imageData,
      filename: filename,
      message: message,
    );
  }

  factory QRDownloadResponse.error({
    required String message,
  }) {
    return QRDownloadResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
