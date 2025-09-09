/// Models for Nigeria States and LGAs API responses

class StateModel {
  final String name;
  final String? code;
  final String? capital;
  final int? population;
  final String? region;

  StateModel({
    required this.name,
    this.code,
    this.capital,
    this.population,
    this.region,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      name: json['name'] ?? json['state'] ?? '',
      code: json['code'] ?? json['state_code'],
      capital: json['capital'],
      population: json['population'],
      region: json['region'] ?? json['geo_zone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'capital': capital,
      'population': population,
      'region': region,
    };
  }

  @override
  String toString() => name;
}

class LGAModel {
  final String name;
  final String? code;
  final String? state;
  final String? region;

  LGAModel({
    required this.name,
    this.code,
    this.state,
    this.region,
  });

  factory LGAModel.fromJson(Map<String, dynamic> json) {
    return LGAModel(
      name: json['name'] ?? json['lga'] ?? '',
      code: json['code'] ?? json['lga_code'],
      state: json['state'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'state': state,
      'region': region,
    };
  }

  @override
  String toString() => name;
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final List<T>? data;
  final T? singleData;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.singleData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final data = json['data'];
    if (data is List) {
      return ApiResponse(
        success: json['success'] ?? true,
        message: json['message'],
        data: data.map((item) => fromJson(item)).toList(),
      );
    } else if (data is Map<String, dynamic>) {
      return ApiResponse(
        success: json['success'] ?? true,
        message: json['message'],
        singleData: fromJson(data),
      );
    } else {
      return ApiResponse(
        success: json['success'] ?? true,
        message: json['message'],
      );
    }
  }
}
